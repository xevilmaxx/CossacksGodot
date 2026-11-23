#!/usr/bin/env python3
"""T6 piece-verdict registry / aggregator (ticket T6-Q01).

Plain Python 3, standard library only. No Pillow, no Godot, no third-party
modules, no runner jobs.

Inputs (all read-only):
  docs/t6/*_LANE.md             declared tickets + lane states
  docs/t6/reports/*.md          per-worker claim tables / acceptance verdicts
  app/shots/pieces/*.manifest.json  piece outputs

Output (generated):
  docs/t6/DASHBOARD.md          one row per known ticket + one per manifest

Honesty rules (SWARM_OPS.md 5b-QUALITY):
  * a missing report is NOT_RUN / UNVERIFIED, never PASS;
  * an ambiguous criterion verdict is UNVERIFIED;
  * evidence paths are copied from the source files, never guessed;
  * a lane row that claims PASS without a report is NOT promoted to PASS.

Run from the project root:  python app\\tools\\t6_registry.py [--out PATH]
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

# app/tools/t6_registry.py -> parents[0]=app/tools, [1]=app, [2]=project root
ROOT = Path(__file__).resolve().parents[2]
T6_DIR = ROOT / "docs" / "t6"
REPORTS_DIR = T6_DIR / "reports"
MANIFESTS_DIR = ROOT / "app" / "shots" / "pieces"
DEFAULT_OUT = T6_DIR / "DASHBOARD.md"
BACKUP_DIR = ROOT / "inbox" / "backup"
WORKER_ID = "T6-Q01"

TICKET_RE = re.compile(r"^T6-[A-Z]\d{2,3}$")
SEPARATOR_RE = re.compile(r":?-{2,}:?")
VERDICT_RE = re.compile(r"\b(PASS|FAIL|UNVERIFIED)\b", re.IGNORECASE)
LABEL_RE = re.compile(r"\b(observed|derived|inferred|unverified)\b", re.IGNORECASE)
VERDICT_COL_RE = re.compile(
    r"verdict|result|status|pass\s*[/\\-]\s*fail", re.IGNORECASE
)
ACCEPT_COL_RE = re.compile(
    r"gate|criterion|criteria|acceptance|test|check", re.IGNORECASE
)
HEADER_DATE_RE = re.compile(
    r"^\s*(?:date|updated|last[-_ ]?updated)\s*:\s*(\S+)", re.IGNORECASE | re.MULTILINE
)
PIECE_RE = re.compile(r"\b([a-z][a-z0-9_]*)\s+mini-?baker\b", re.IGNORECASE)
PATH_TOKEN_RE = re.compile(
    r"[A-Za-z0-9_./\\-]+\.(?:md|json|png|gd|gdshader|log|txt)\b", re.IGNORECASE
)

STATES = ("PASS", "FAIL", "UNVERIFIED", "IN_PROGRESS", "IDLE", "BLOCKED")


# --------------------------------------------------------------------------- #
# small helpers
# --------------------------------------------------------------------------- #
def rel(path: Path) -> str:
    """Project-relative, forward-slash path (never an invented path)."""
    try:
        return path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def mtime(path: Path) -> datetime:
    return datetime.fromtimestamp(path.stat().st_mtime, tz=timezone.utc)


def iso(dt: datetime | None) -> str:
    if dt is None:
        return "UNVERIFIED"
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def md_cell(text: str) -> str:
    """Make arbitrary text safe inside one markdown table cell."""
    return str(text).replace("|", "\\|").replace("\n", " ").strip()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def split_md_row(line: str) -> list[str] | None:
    """Split a markdown table row, honouring escaped pipes (\\|)."""
    stripped = line.strip()
    if not stripped.startswith("|"):
        return None
    body = stripped.replace(r"\|", "\x00")
    if body.endswith("|"):
        body = body[:-1]
    return [c.strip().replace("\x00", "|") for c in body[1:].split("|")]


def is_separator(cells: list[str]) -> bool:
    nonempty = [c for c in cells if c.strip()]
    return bool(nonempty) and all(
        SEPARATOR_RE.fullmatch(c.strip()) for c in nonempty
    )


def parse_tables(text: str) -> list[tuple[list[str], list[list[str]]]]:
    """Return [(header_cells, data_rows), ...] for every markdown table."""
    tables: list[tuple[list[str], list[list[str]]]] = []
    group: list[str] = []

    def flush() -> None:
        if not group:
            return
        rows = []
        for line in group:
            cells = split_md_row(line)
            if cells is not None and not is_separator(cells):
                rows.append(cells)
        if len(rows) >= 2:
            tables.append((rows[0], rows[1:]))
        group.clear()

    for line in text.splitlines():
        if split_md_row(line) is not None:
            group.append(line)
        else:
            flush()
    flush()
    return tables


def extract_paths(cell: str) -> list[str]:
    """Only single path-like tokens actually present in the cell.

    Deliberately rejects shell commands, directory fragments and templates so
    that command text is never promoted into an "evidence path".
    """
    found: list[str] = []
    bare_re = re.compile(
        r"(?<![A-Za-z0-9_./\\><-])"
        r"[A-Za-z0-9_./\\-]+\.(?:md|json|png|gd|gdshader|log|txt)\b",
        re.IGNORECASE,
    )

    def add(value: str) -> None:
        value = value.strip().strip("*").strip()
        if not value or len(value) > 180:
            return
        base = re.sub(r":\d+(?:-\d+)?$", "", value)  # drop :line or :a-b suffix
        if (
            re.search(r"\s", base)
            or base.endswith(("/", "\\"))
            or any(c in base for c in "<>|*")
            or ".." in base
            or "--" in base
        ):
            return
        if not (
            PATH_TOKEN_RE.fullmatch(base)
            or ("/" in base or "\\" in base) and PATH_TOKEN_RE.search(base)
        ):
            return
        if base not in found:
            found.append(base)

    for token in re.findall(r"`([^`]+)`", cell):
        add(token)
    for token in bare_re.findall(cell):
        add(token)
    return found


# --------------------------------------------------------------------------- #
# lane tickets
# --------------------------------------------------------------------------- #
def normalize_lane_state(raw: str, whole_row: str) -> str:
    """Map a declared lane state to the dashboard enum. Never invents PASS."""
    s = raw.lower()
    row = whole_row.lower()

    # Gated/blocked first: e.g. "BLOCKED on W01 verification + W02 PASS"
    if any(k in s for k in ("blocked", "gated", "not open", "do not start")):
        return "BLOCKED"
    if re.search(r"\bnot\s+(?:started|spawned|done)\b", s) or "n/a" in s:
        return "IDLE"
    if re.search(r"\bfail(?:ed)?\b", s):
        return "FAIL"
    if re.search(r"\b(?:pass(?:ed)?|done|complete)\b", s) and "fail" not in s:
        return "PASS"
    if "idle" in s:
        return "IDLE"
    if any(
        k in s
        for k in (
            "in_progress",
            "in progress",
            "spawn",
            "assigned",
            "granted",
            "queued",
            "waiting",
            "pending",
            "started",
            "running",
            "active",
            "working",
        )
    ):
        return "IN_PROGRESS"
    if any(k in s for k in ("not started", "not spawned", "n/a", "—", "-")):
        return "IDLE"
    # Integration rows carry the gate in the task cell, not the state cell.
    if "integration" in row and "gated" in row:
        return "BLOCKED"
    if "integration" in row:
        return "BLOCKED"
    return "UNVERIFIED"


def parse_lane_tickets() -> dict[str, dict]:
    tickets: dict[str, dict] = {}
    for lane_path in sorted(T6_DIR.glob("*_LANE.md")):
        lane = lane_path.name[: -len("_LANE.md")]
        text = read_text(lane_path)
        for header, rows in parse_tables(text):
            lower = [h.lower() for h in header]
            if not lower or lower[0] not in ("id", "ticket"):
                continue
            state_idx = next(
                (i for i, h in enumerate(lower) if "state" in h), None
            )
            if state_idx is None:
                continue
            task_idx = next(
                (
                    i
                    for i, h in enumerate(lower)
                    if any(k in h for k in ("micro-task", "piece", "family", "question", "task"))
                ),
                None,
            )
            owned_idx = [
                i for i, h in enumerate(lower) if "owned" in h or "output" in h
            ]
            for row in rows:
                if not row:
                    continue
                tid = row[0].strip().strip("`* ")
                if not TICKET_RE.fullmatch(tid):
                    continue
                raw_state = row[state_idx] if state_idx < len(row) else ""
                whole_row = " ".join(row)
                task = row[task_idx] if task_idx is not None and task_idx < len(row) else ""
                owned = " ".join(row[i] for i in owned_idx if i < len(row))
                piece_match = PIECE_RE.search(task)
                rec = {
                    "ticket": tid,
                    "lane": lane,
                    "state_raw": raw_state.strip(),
                    "state_norm": normalize_lane_state(raw_state, whole_row),
                    "task": task.strip(),
                    "owned": owned.strip(),
                    "piece": piece_match.group(1) if piece_match else None,
                    "lane_doc": rel(lane_path),
                    "lane_mtime": mtime(lane_path),
                }
                if tid in tickets:
                    rec.setdefault("anomalies", []).append(
                        f"duplicate lane declaration in {rec['lane_doc']}"
                    )
                tickets[tid] = rec
    return tickets


# --------------------------------------------------------------------------- #
# reports
# --------------------------------------------------------------------------- #
def report_ticket_id(path: Path, text: str) -> str | None:
    match = re.search(r"^\s*ticket\s*:\s*(T6-[A-Z]\d{2,3})\b", text, re.IGNORECASE | re.MULTILINE)
    if match:
        return match.group(1)
    match = re.search(r"^#\s+(T6-[A-Z]\d{2,3})\b", text, re.IGNORECASE | re.MULTILINE)
    if match:
        return match.group(1)
    match = re.search(r"\b(T6-[A-Z]\d{2,3})\b", path.stem)
    return match.group(1) if match else None


def report_timestamp(path: Path, text: str) -> tuple[datetime, str]:
    head = "\n".join(text.splitlines()[:60])
    match = HEADER_DATE_RE.search(head)
    if match:
        try:
            parsed = datetime.fromisoformat(match.group(1).strip().rstrip("Z"))
            if parsed.tzinfo is None:
                parsed = parsed.replace(tzinfo=timezone.utc)
            return parsed, f"header '{match.group(1)}'"
        except ValueError:
            pass
    return mtime(path), "file mtime"


def verdict_from_row(row: list[str], header: list[str]) -> str:
    """Read a criterion verdict only from verdict-like columns."""
    idxs = [i for i, h in enumerate(header) if VERDICT_COL_RE.search(h)]
    cells = [row[i] for i in idxs if i < len(row)] if idxs else []
    if not cells:
        # No explicit verdict column in this table: do NOT infer PASS/FAIL.
        return "UNVERIFIED"
    found = {
        m.group(1).upper()
        for cell in cells
        for m in VERDICT_RE.finditer(cell)
    }
    if "PASS" in found and "FAIL" in found:
        return "UNVERIFIED"  # ambiguous
    if "PASS" in found and "UNVERIFIED" not in found:
        return "PASS"
    if "FAIL" in found and "UNVERIFIED" not in found:
        return "FAIL"
    return "UNVERIFIED"


def parse_reports() -> list[dict]:
    reports: list[dict] = []
    if not REPORTS_DIR.is_dir():
        return reports
    for path in sorted(REPORTS_DIR.glob("*.md")):
        text = read_text(path)
        ts, ts_source = report_timestamp(path, text)
        tid = report_ticket_id(path, text)
        counts = {"observed": 0, "derived": 0, "inferred": 0, "unverified": 0}
        claim_rows = 0
        criteria: list[dict] = []
        evidence: list[str] = []
        anomalies: list[str] = []

        for header, rows in parse_tables(text):
            lower = [h.lower() for h in header]
            is_claim = any("claim" in h for h in lower) and any(
                k in h for h in lower for k in ("status", "verdict", "label", "result")
            )
            is_accept = (
                any(ACCEPT_COL_RE.search(h) for h in lower)
                and not any("claim" in h for h in lower)
            )
            if is_claim:
                evid_idx = [i for i, h in enumerate(lower) if "evidence" in h]
                label_idx = [
                    i
                    for i, h in enumerate(lower)
                    if any(k in h for k in ("status", "verdict", "label", "result"))
                ]
                for row in rows:
                    claim_rows += 1
                    labelled = [
                        m.group(1).lower()
                        for i in label_idx
                        if i < len(row)
                        for m in LABEL_RE.finditer(row[i])
                    ]
                    if not labelled:
                        labelled = [
                            m.group(1).lower() for m in LABEL_RE.finditer(" ".join(row))
                        ]
                    for label in labelled:
                        key = "unverified" if label == "unverified" else label
                        if key in counts:
                            counts[key] += 1
                    for i in evid_idx:
                        if i < len(row):
                            for p in extract_paths(row[i]):
                                if p not in evidence:
                                    evidence.append(p)
            elif is_accept:
                id_idx = 0
                for i, row in enumerate(rows, start=1):
                    verdict = verdict_from_row(row, header)
                    cid_cell = row[id_idx] if id_idx < len(row) else ""
                    cid = re.sub(r"[^A-Za-z0-9-]", "", cid_cell) or f"row{i}"
                    criteria.append({"id": cid, "verdict": verdict})
                    for p in extract_paths(" ".join(row)):
                        if p not in evidence:
                            evidence.append(p)

        n_pass = sum(1 for c in criteria if c["verdict"] == "PASS")
        n_fail = sum(1 for c in criteria if c["verdict"] == "FAIL")
        n_unver = sum(1 for c in criteria if c["verdict"] == "UNVERIFIED")
        if n_fail:
            verdict = "FAIL"
        elif criteria and n_pass == len(criteria):
            verdict = "PASS"
        else:
            verdict = "UNVERIFIED"
        if not criteria:
            anomalies.append("no acceptance-criterion verdict rows parsed")
        if not tid:
            anomalies.append("no ticket id found (file name used)")
            tid = path.stem

        reports.append(
            {
                "ticket": tid,
                "path": rel(path),
                "timestamp": ts,
                "timestamp_source": ts_source,
                "claim_rows": claim_rows,
                "claim_counts": counts,
                "criteria": criteria,
                "n_pass": n_pass,
                "n_fail": n_fail,
                "n_unver": n_unver,
                "verdict": verdict,
                "evidence": evidence,
                "anomalies": anomalies,
            }
        )
    return reports


# --------------------------------------------------------------------------- #
# manifests
# --------------------------------------------------------------------------- #
def parse_manifests() -> list[dict]:
    out: list[dict] = []
    if not MANIFESTS_DIR.is_dir():
        return out
    for path in sorted(MANIFESTS_DIR.glob("*.manifest.json")):
        try:
            data = json.loads(read_text(path))
        except (ValueError, OSError) as exc:
            out.append(
                {
                    "manifest": rel(path),
                    "name": path.name[: -len(".manifest.json")],
                    "spec": "UNVERIFIED",
                    "output": "UNVERIFIED",
                    "sha256": "UNVERIFIED",
                    "mtime": mtime(path),
                    "anomalies": [f"manifest parse error: {exc}"],
                }
            )
            continue
        # Two observed schemas: flat {"output": "..."} and nested
        # {"outputs": {"piece": "...", "compare": "..."}}. Use what exists.
        output = data.get("output")
        extra_outputs: list[str] = []
        outputs = data.get("outputs")
        if not output and isinstance(outputs, dict):
            output = outputs.get("piece")
            extra_outputs = [
                str(v) for k, v in outputs.items() if k != "piece" and isinstance(v, str)
            ]
        png_path = None
        if isinstance(output, str) and output:
            candidate = Path(output)
            if not candidate.is_absolute():
                candidate = ROOT / candidate
            png_path = candidate if candidate.is_file() else None
        if not output:
            extra_outputs.append("no output path field in manifest")
        out.append(
            {
                "manifest": rel(path),
                "name": data.get("name") or path.name[: -len(".manifest.json")],
                "spec": data.get("spec") or "UNVERIFIED",
                "output": output or "UNVERIFIED",
                "extra_outputs": extra_outputs,
                "generator": data.get("generator") or "UNVERIFIED",
                "png_exists": png_path is not None,
                "sha256": data.get("sha256") or "UNVERIFIED",
                "mtime": mtime(path),
                "anomalies": [],
            }
        )
    return out


# --------------------------------------------------------------------------- #
# join + render
# --------------------------------------------------------------------------- #
def derive_state(ticket: dict | None, report: dict | None) -> tuple[str, list[str]]:
    notes: list[str] = []
    if report is not None:
        if report["verdict"] in ("PASS", "FAIL"):
            return report["verdict"], notes
        notes.append(
            f"report verdict UNVERIFIED ({report['n_pass']}P/{report['n_fail']}F/"
            f"{report['n_unver']}U); showing lane lifecycle state"
        )
        if ticket is not None and ticket["state_norm"] in ("PASS", "FAIL"):
            notes.append(
                f"lane declares {ticket['state_norm']} but report verdict is "
                "UNVERIFIED; not promoted"
            )
        return (
            ticket["state_norm"]
            if ticket is not None and ticket["state_norm"] in ("IN_PROGRESS", "IDLE", "BLOCKED")
            else "UNVERIFIED"
        ), notes
    if ticket is None:
        return "UNVERIFIED", notes
    norm = ticket["state_norm"]
    if norm == "BLOCKED":
        return "BLOCKED", notes
    if norm == "IDLE":
        return "IDLE", notes
    if norm in ("PASS", "FAIL"):
        notes.append(
            f"lane declares {norm} but no report backs it; not promoted"
        )
        return "UNVERIFIED", notes
    if norm == "IN_PROGRESS":
        return "IN_PROGRESS", notes
    return "UNVERIFIED", notes


def build_rows(
    tickets: dict[str, dict], reports: list[dict], manifests: list[dict]
) -> tuple[list[dict], list[dict], list[dict], list[str]]:
    by_ticket_report: dict[str, dict] = {}
    for report in reports:
        if report["ticket"] in by_ticket_report:
            report["anomalies"].append(
                f"multiple reports for {report['ticket']}; newest kept"
            )
            if report["timestamp"] > by_ticket_report[report["ticket"]]["timestamp"]:
                by_ticket_report[report["ticket"]] = report
        else:
            by_ticket_report[report["ticket"]] = report
    by_name: dict[str, dict] = {m["name"]: m for m in manifests}
    by_generator: dict[str, list[dict]] = {}
    for manifest in manifests:
        gen = manifest.get("generator", "UNVERIFIED")
        if gen != "UNVERIFIED":
            by_generator.setdefault(gen, []).append(manifest)

    rows: list[dict] = []
    used_manifests: set[str] = set()
    for tid in sorted(tickets):
        ticket = tickets[tid]
        report = by_ticket_report.get(tid)
        # Join keys are taken only from source files: the declared piece name
        # in the lane table, and the manifest's generator string appearing in
        # the ticket's owned-files/task cell. No path is constructed here.
        matched: list[dict] = []
        if ticket["piece"] and ticket["piece"] in by_name:
            matched.append(by_name[ticket["piece"]])
        for gen, group in by_generator.items():
            if gen in ticket["owned"] or gen in ticket["task"]:
                for manifest in group:
                    if manifest not in matched:
                        matched.append(manifest)
        manifest = matched[0] if matched else None
        for m in matched:
            used_manifests.add(m["manifest"])
        state, notes = derive_state(ticket, report)
        notes.extend(ticket.get("anomalies", []))
        if report is not None:
            verdict_text = report["verdict"]
        elif manifest is not None:
            verdict_text = "NOT_RUN (manifest only)"
        else:
            verdict_text = "NOT_RUN"
        evidence: list[str] = []
        if report:
            evidence.append(report["path"])
            evidence.extend(p for p in report["evidence"] if p not in evidence)
        for m in matched:
            evidence.append(m["manifest"])
            evidence.append(m["output"])
            for extra in m.get("extra_outputs", []):
                if extra not in evidence:
                    evidence.append(extra)
        times = [ticket["lane_mtime"]]
        if report:
            times.append(report["timestamp"])
        for m in matched:
            times.append(m["mtime"])
        rows.append(
            {
                "ticket": tid,
                "lane": ticket["lane"],
                "state": state,
                "raw_state": ticket["state_raw"] or "—",
                "report_verdict": verdict_text,
                "pass": report["n_pass"] if report else 0,
                "fail": report["n_fail"] if report else 0,
                "unverified": report["n_unver"] if report else 0,
                "claims": (
                    "{observed}/{derived}/{inferred}/{unverified}".format(
                        **report["claim_counts"]
                    )
                    if report
                    else "—"
                ),
                "evidence": evidence,
                "last_update": iso(max(times)),
                "notes": notes,
            }
        )

    manifest_rows: list[dict] = []
    for manifest in manifests:
        key = manifest["manifest"]
        if key in used_manifests:
            continue
        report = by_ticket_report.get(manifest["name"])
        state, notes = derive_state(None, report)
        verdict_text = report["verdict"] if report else "NOT_RUN (no lane ticket)"
        evidence = [manifest["manifest"], manifest["output"]]
        evidence.extend(
            p for p in manifest.get("extra_outputs", []) if p not in evidence
        )
        if report:
            evidence.insert(0, report["path"])
            evidence.extend(p for p in report["evidence"] if p not in evidence)
        manifest_rows.append(
            {
                "ticket": f"(none: {manifest['name']})",
                "lane": "(unmapped manifest)",
                "state": state,
                "raw_state": "—",
                "report_verdict": verdict_text,
                "pass": report["n_pass"] if report else 0,
                "fail": report["n_fail"] if report else 0,
                "unverified": report["n_unver"] if report else 0,
                "claims": (
                    "{observed}/{derived}/{inferred}/{unverified}".format(
                        **report["claim_counts"]
                    )
                    if report
                    else "—"
                ),
                "evidence": evidence,
                "last_update": iso(
                    max([manifest["mtime"]] + ([report["timestamp"]] if report else []))
                ),
                "notes": notes,
            }
        )

    unmatched_reports = [
        r for r in reports if r["ticket"] not in tickets
    ]
    anomalies: list[str] = []
    for r in reports:
        for a in r["anomalies"]:
            anomalies.append(f"{r['path']}: {a}")
    for m in manifests:
        for a in m["anomalies"]:
            anomalies.append(f"{m['manifest']}: {a}")
    for row in rows + manifest_rows:
        for a in row["notes"]:
            anomalies.append(f"{row['ticket']}: {a}")
    return rows + manifest_rows, manifest_rows, unmatched_reports, anomalies


def render_dashboard(
    rows: list[dict],
    manifest_rows: list[dict],
    unmatched_reports: list[dict],
    anomalies: list[str],
    tickets: dict[str, dict],
    reports: list[dict],
    manifests: list[dict],
) -> str:
    now = iso(datetime.now(timezone.utc))
    state_counts = {s: 0 for s in STATES}
    for row in rows:
        state_counts[row["state"]] = state_counts.get(row["state"], 0) + 1

    report_verdicts = {"PASS": 0, "FAIL": 0, "UNVERIFIED": 0, "NOT_RUN": 0}
    for row in rows:
        v = row["report_verdict"]
        if v.startswith("NOT_RUN"):
            report_verdicts["NOT_RUN"] += 1
        elif v in report_verdicts:
            report_verdicts[v] += 1

    lines: list[str] = []
    add = lines.append
    add("# T6 Registry Dashboard (generated)")
    add("")
    add(f"- **Generated:** `{now}`")
    add(
        "- **Generator:** `app/tools/t6_registry.py` "
        f"(ticket {WORKER_ID}, stdlib-only; regenerate with "
        "`python app\\tools\\t6_registry.py`)"
    )
    add(
        f"- **Inputs scanned:** {len(tickets)} lane tickets, "
        f"{len(reports)} reports, {len(manifests)} piece manifests"
    )
    add(f"- **Rows emitted:** {len(rows)}")
    add("")
    add("## Summary — counts by dashboard state")
    add("")
    add("| State | Rows |")
    add("|---|---:|")
    for state in STATES:
        add(f"| {state} | {state_counts.get(state, 0)} |")
    add("")
    add("Report verdicts (independent of the lifecycle state column):")
    add("")
    add("| Report verdict | Rows |")
    add("|---|---:|")
    for key in ("PASS", "FAIL", "UNVERIFIED", "NOT_RUN"):
        add(f"| {key} | {report_verdicts[key]} |")
    add("")
    add("## State rules (honesty contract)")
    add("")
    add(
        "- A report whose parsed criteria are all PASS and none FAIL gives "
        "`State = PASS`; any FAIL gives `FAIL`; mixed/empty/ambiguous gives "
        "`UNVERIFIED`."
    )
    add(
        "- With **no report**, `Report verdict = NOT_RUN` and `PASS/FAIL = 0/0`. "
        "The `State` column then shows only the lane lifecycle "
        "(`IN_PROGRESS` / `IDLE` / `BLOCKED`); a lane row that says PASS "
        "without a report is **not** promoted."
    )
    add(
        "- A manifest with no matching lane ticket gets `State = UNVERIFIED`. "
        "Evidence paths are copied verbatim from the lane doc, report or "
        "manifest; none are generated by this tool."
    )
    add(
        "- `Claims` = observed/derived/inferred/unverified label counts read "
        "from the report's claim table. `Last update` = newest of report "
        "header date/mtime, manifest mtime and lane-doc mtime."
    )
    add("")
    add("## Ticket + manifest rows")
    add("")
    add(
        "| Ticket | Lane | State | Raw lane state | Report verdict | PASS | FAIL | "
        "UNVER | Claims (o/d/i/u) | Evidence (report / manifest / PNG) | Last update |"
    )
    add(
        "|---|---|---|---|---|---:|---:|---:|---|---|---|"
    )
    for row in rows:
        evidence = "<br>".join(md_cell(p) for p in row["evidence"]) or "—"
        add(
            "| {ticket} | {lane} | {state} | {raw} | {verdict} | {p} | {f} | {u} | "
            "{claims} | {evidence} | {lu} |".format(
                ticket=md_cell(row["ticket"]),
                lane=md_cell(row["lane"]),
                state=md_cell(row["state"]),
                raw=md_cell(row["raw_state"]),
                verdict=md_cell(row["report_verdict"]),
                p=row["pass"],
                f=row["fail"],
                u=row["unverified"],
                claims=md_cell(row["claims"]),
                evidence=evidence,
                lu=row["last_update"],
            )
        )
    add("")
    add("## Reports with no matching lane ticket")
    add("")
    if unmatched_reports:
        add("| Report | Ticket ID | Verdict | Evidence |")
        add("|---|---|---|---|")
        for report in unmatched_reports:
            add(
                "| {path} | {tid} | {verdict} | {evidence} |".format(
                    path=md_cell(report["path"]),
                    tid=md_cell(report["ticket"]),
                    verdict=report["verdict"],
                    evidence="<br>".join(md_cell(p) for p in report["evidence"]) or "—",
                )
            )
    else:
        add("None — every report maps to a declared lane ticket.")
    add("")
    add("## Manifest coverage")
    add("")
    add(
        f"{len(manifests)} manifests scanned; {len(manifests) - len(manifest_rows)} "
        f"matched a lane ticket by declared piece name; {len(manifest_rows)} "
        "manifest-only rows listed above."
    )
    add("")
    add("## Parse anomalies")
    add("")
    if anomalies:
        for item in anomalies:
            add(f"- {md_cell(item)}")
    else:
        add("None detected.")
    add("")
    return "\n".join(lines)


def write_dashboard(out: Path, content: str) -> str | None:
    """Back up an existing owned file before overwriting it."""
    backup: str | None = None
    if out.exists():
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)
        backup_path = BACKUP_DIR / f"{out.name}.bak-{WORKER_ID}"
        shutil.copy2(out, backup_path)
        backup = rel(backup_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(content, encoding="utf-8", newline="\n")
    return backup


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Regenerate the T6 piece-verdict dashboard (stdlib only)."
    )
    parser.add_argument(
        "--out",
        default=str(DEFAULT_OUT),
        help=f"output path (default: {rel(DEFAULT_OUT)})",
    )
    args = parser.parse_args(argv)
    out = Path(args.out)
    if not out.is_absolute():
        out = ROOT / out

    tickets = parse_lane_tickets()
    reports = parse_reports()
    manifests = parse_manifests()
    rows, manifest_rows, unmatched, anomalies = build_rows(
        tickets, reports, manifests
    )
    content = render_dashboard(
        rows, manifest_rows, unmatched, anomalies, tickets, reports, manifests
    )
    backup = write_dashboard(out, content)

    print(f"OK: wrote {rel(out)}")
    print(
        f"tickets={len(tickets)} reports={len(reports)} manifests={len(manifests)} "
        f"rows={len(rows)} unmatched_reports={len(unmatched)} "
        f"anomalies={len(anomalies)}"
    )
    if backup:
        print(f"backup={backup}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
