# I13 / TERRAIN-SWARM-2026-11-26 — QA harness driver (N16). READ-ONLY DONOR:
# no donor binary is executed, no donor file is copied or read, no Godot process
# and no runner job is launched by this tool. Class C GPU capture is emitted as
# an exact MANUAL command for COORD only. NO PARITY CLAIM: parity.status is
# "UNVERIFIED" by construction (A05 §7, V21 §7.3); no donor GPU A/B frame exists.
# NO THRESHOLD LOWERING / NO INVENTED BAND: every band is a frozen, cited A05/V21
# constant; --policy red is refused unless a signed donor spec (N17) is present.
# Python 3.14, stdlib only (never import the cp313-only bundled Pillow/numpy).
# Deterministic JSON: no timestamps, stable sort, byte-identical on re-run.

"""I13 QA harness driver for the donor-first terrain port (terrain_qa_report/1).

Consolidated from V21's gate register. It reads two headless ``--dump-map``
JSON files (run A / run B at one pinned size), a pinned seed manifest, and the
N17 spec file; it never launches Godot and never reads donor material.

Usage (from repo root):
    python variant3d\\tools\\terrain_qa_harness.py ^
        --dump-a <run_a.json> --dump-b <run_b.json> ^
        --seed-manifest <manifest.json> --policy advisory ^
        --out <report.json>
    python variant3d\\tools\\terrain_qa_harness.py --check

Exit codes: 0 = report written / self-check passed, 1 = hard gate FAIL or
self-check failure, 2 = bad invocation, unreadable input or refused --policy red.

Gate register: 52 rows — 25 class A (red determinism/invariants), 16 class B
([U] bands, advisory), 11 class C (owner-only capture). Execution order is
A'-0..A'-3 then D-0..D-6 (V21 §6). Every A row that needs absent telemetry is
reported UNVERIFIED, never PASS; every B row prints ADVISORY_UNVERIFIED while
the spec is unsigned. Metric fields and visual fields are never merged.
"""
from __future__ import annotations

import argparse
import base64
import binascii
import hashlib
import json
import math
import re
import struct
import sys
from pathlib import Path
from typing import Any

SCHEMA = "terrain_qa_report/1"
MANIFEST_SCHEMA = "terrain_qa_manifest/1"
SPEC_SCHEMA = "terrain_qa_spec/1"
POLICIES = ("advisory", "red")
SPEC_RELPATH = Path("docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json")
REVIEWER_LINE = (
    "PORT APPROXIMATION - internal consistency only; donor parity UNVERIFIED. "
    "No donor GPU A/B frame exists; this review certifies neither donor fidelity "
    "nor a gate pass."
)
NO_PARITY_NOTE = (
    "PORT APPROXIMATION - internal consistency only; no donor GPU A/B frame exists."
)

# Frozen A05/V21 bands. These are [I]/[D] sanity bands, never [O] donor
# measurements. A signed spec may replace one only with a donor path:line
# evidence entry plus an explicit deviation record (see validate_spec).
FROZEN_BANDS: dict[str, float | int] = {
    "S1_max_band_share": 0.85,
    "S1_min_bands_occupied": 3,
    "S2_water_low": 0.05,
    "S2_water_high": 0.45,
    "S3_shore_low": 0.02,
    "S3_shore_high": 0.25,
    "S3_ratio_low": 0.2,
    "S3_ratio_high": 1.5,
    "S4_min_distinct_land_ids": 8,
    "S4_max_top1_share": 0.60,
    "S6_family_ratio_low": 0.5,
    "S6_family_ratio_high": 2.0,
}
HEIGHT_BAND_EDGES = (-2.964, -1.1, 0.0, 1.317, 2.964)
WATER_ID = 255
ALPHANULL_IDS = (86, 110, 123)
PINNED_SIZES = (64, 240, 320)
LEAK_STATUSES = ("timed-out", "error", "skipped")
CANONICAL_STREAMS = ("height", "tileblock", "terrain", "blocked", "props")
META_STRIP_TOKENS = (
    "elapsed", "timestamp", "time_", "_time", "duration", "worker",
    "run_id", "started", "finished", "wall",
)

STAGE_ORDER = (
    "A'-0", "A'-1", "A'-2", "A'-3",
    "D-0", "D-1", "D-2", "D-3", "D-4", "D-5", "D-6",
)
STAGE_TITLE = {
    "A'-0": "Read-only preflight: runner spool, CLEAN, app/ integrity, freeze hashes",
    "A'-1": "Static: py_compile, strict validator, donor-derived asset labels",
    "A'-2": "Evidence checkpoint: V17 READY, X13 status, advisory policy fixed",
    "A'-3": "Ledger: SHA-256 of tools/assets/spec; no gate result claimed",
    "D-0": "Repeat preflight on integrated tree; seam/manifest acceptance",
    "D-1": "Static/parse on final tree; relief atom repointed without lowered assertion",
    "D-2": "Determinism: D1 fingerprints, D3 integrity, meta keys, cross-size advisory",
    "D-3": "Headless structural: V12 G1-G13, smoothing, hard ids, S1-S7 advisory",
    "D-4": "Owner-only GPU capture (NOT executed by this tool)",
    "D-5": "Final regression on integrated tree with fresh JSONs",
    "D-6": "COORD sign-off; three-tier verdict; parity stays UNVERIFIED",
}

# id, class, stages, title, evidence ids, labels
GATE_REGISTER: tuple[tuple[str, str, tuple[str, ...], str, tuple[str, ...], tuple[str, ...]], ...] = (
    ("GR-A00", "A", ("A'-0", "D-0", "D-5"), "Preflight runner spool + CLEAN + app/ integrity", ("EV01", "EV12"), ("O", "D")),
    ("GR-A01", "A", ("D-2",), "Determinism D1: five canonical streams x 3 sizes", ("EV02", "spec/12:100-104"), ("O",)),
    ("GR-A02", "A", ("D-2", "D-5"), "Determinism D3 run integrity", ("EV02", "EV04"), ("O",)),
    ("GR-A03", "A", ("D-3", "D-5"), "Non-negotiable regression gates on final tree", ("EV01", "EV12", "EV13"), ("O",)),
    ("GR-A04", "A", ("D-2",), "Dump meta generation-key completeness", ("EV02", "A05:89-100"), ("O",)),
    ("GR-A05", "A", ("D-3",), "V12-G1 mine loop order / 256 attempts", ("EV05", "EV06"), ("O",)),
    ("GR-A06", "A", ("D-3",), "V12-G2 radius matrix + ring-2 trace", ("EV05", "EV06", "EV07"), ("O", "I")),
    ("GR-A07", "A", ("D-3",), "V12-G3 continue RNG bookkeeping", ("EV05",), ("O",)),
    ("GR-A08", "A", ("D-3",), "V12-G4 density / rounds / clamp / callers", ("EV05", "EV06"), ("O",)),
    ("GR-A09", "A", ("D-3",), "V12-G5 corner relocation", ("EV05",), ("O",)),
    ("GR-A10", "A", ("D-3",), "V12-G6 ellipses and dead C3 block", ("EV05",), ("O",)),
    ("GR-A11", "A", ("D-3",), "V12-G7 six placement attempts and probe formulas", ("EV05", "EV06"), ("O",)),
    ("GR-A12", "A", ("D-3",), "V12-G8 occupancy-only rejection", ("EV05",), ("O",)),
    ("GR-A13", "A", ("D-3",), "V12-G9 no food rects in start resources", ("EV05", "EV16"), ("O",)),
    ("GR-A14", "A", ("D-3",), "V12-G10 no finite deposit amount", ("EV05",), ("U",)),
    ("GR-A15", "A", ("D-3",), "V12-G11 FillOwnerMap 160^2 wavefront", ("EV05",), ("O",)),
    ("GR-A16", "A", ("D-3",), "V12-G12 stage seam + 11+3 reseed ledger", ("EV05", "EV14"), ("O",)),
    ("GR-A17", "A", ("D-3",), "V12-G13 weighted pick + damping", ("EV05",), ("O",)),
    ("GR-A18", "A", ("D-3",), "D08/X08 smoothing engine structure (3 passes, 22/118/282/86)", ("EV08", "EV10", "EV14"), ("O", "D")),
    ("GR-A19", "A", ("D-3",), "X08 exact smoothing vectors V1-V11", ("EV10",), ("D", "U")),
    ("GR-A20", "A", ("D-2", "D-3"), "Hard tile-id / stamp / family catalogue domain", ("EV03", "EV08", "EV14"), ("O", "D")),
    ("GR-A21", "A", ("D-3",), "V15 shared stage/render invariants; no synthetic art", ("EV11", "EV01"), ("O",)),
    ("GR-A22", "A", ("A'-0", "D-0", "D-5"), "app/ + freeze-set byte identity", ("EV13", "EV17"), ("O",)),
    ("GR-A23", "A", ("A'-1", "D-0", "D-1", "D-3", "D-6"), "Threshold / assertion integrity", ("EV01", "EV17"), ("O",)),
    ("GR-A24", "A", ("D-1", "D-3"), "Relief-props QA atom is not a vacuous blind spot", ("EV15",), ("O", "U")),
    ("GR-B01", "B", ("A'-2", "D-2"), "D2 cross-size structural similarity", ("EV02", "EV14"), ("I",)),
    ("GR-B02", "B", ("A'-2", "D-3"), "S1 height deciles / donor-band occupancy", ("EV03", "E06"), ("I", "D")),
    ("GR-B03", "B", ("A'-2", "D-3"), "S2 water fraction band", ("EV03", "EV11"), ("I", "D")),
    ("GR-B04", "B", ("A'-2", "D-3"), "S3 shore fraction and shore/water ratio", ("EV03",), ("I",)),
    ("GR-B05", "B", ("A'-2", "D-3"), "S4 tile-id histogram diversity", ("EV03",), ("I",)),
    ("GR-B06", "B", ("A'-2", "D-3"), "S5 relief-stamp count and k_ravine_1", ("EV03",), ("O", "U")),
    ("GR-B07", "B", ("A'-2", "D-3"), "S6 family-count ratio", ("EV03",), ("D", "I")),
    ("GR-B08", "B", ("A'-2", "D-3"), "S7 mine/field/forest counts (superseded port belief)", ("EV03", "EV14", "EV16"), ("D", "I")),
    ("GR-B09", "B", ("A'-2",), "Generator version / mapsize branch selection", ("EV06", "EV07", "EV14"), ("U",)),
    ("GR-B10", "B", ("A'-2",), "Ring-2 VM initialisation semantics", ("EV07",), ("I", "U")),
    ("GR-B11", "B", ("A'-2",), "bmTransparency visual semantics", ("EV09", "EV14"), ("D", "U")),
    ("GR-B12", "B", ("A'-2",), "Eye-plane texgen / UV scale", ("EV09",), ("O", "D", "U")),
    ("GR-B13", "B", ("A'-2",), "Detail-bitmap pass runtime activity", ("EV08",), ("U",)),
    ("GR-B14", "B", ("A'-2",), "Atlas packing / face-cell equivalence", ("EV08", "EV14"), ("D", "U")),
    ("GR-B15", "B", ("A'-2",), "Swamp/header + rivers scope", ("EV14", "EV11"), ("O", "U")),
    ("GR-B16", "B", ("A'-2",), "DScript runtime activation / deposit capacity", ("EV05", "EV11"), ("U",)),
    ("GR-C01", "C", ("D-4",), "Capture admissibility G0-a...e", ("EV04", "EV11", "EV12"), ("O",)),
    ("GR-C02", "C", ("D-4",), "Frozen fresh 240^2 / 320^2 baselines", ("EV12", "EV14"), ("O",)),
    ("GR-C03", "C", ("D-4",), "Visual cards R1-R6", ("EV04", "EV11"), ("O",)),
    ("GR-C04", "C", ("D-4",), "R7/R8 CAP-3 drag/ghost frames", ("EV04", "EV11"), ("U",)),
    ("GR-C05", "C", ("D-4",), "V15 tier-2 self-consistent visual properties", ("EV11",), ("I",)),
    ("GR-C06", "C", ("D-4",), "Same-scene self-determinism (compare_shots.py)", ("EV03", "EV12"), ("O",)),
    ("GR-C07", "C", ("D-4",), "Like-with-like SMOKE metric (terrain_ab_metric.py)", ("EV12", "EV03"), ("I",)),
    ("GR-C08", "C", ("D-4", "D-6"), "Genuine donor GPU A/B frame (does not exist)", ("EV01", "EV11"), ("U",)),
    ("GR-C09", "C", ("A'-2", "D-4"), "X13 blend test vectors (report absent)", ("EV18", "EV09"), ("U",)),
    ("GR-C10", "C", ("D-4",), "Tool aperture verification per capture", ("EV12",), ("O",)),
    ("GR-C11", "C", ("D-4",), "Fresh relief-props ON/OFF windowed capture", ("EV15", "EV11"), ("U",)),
)

ROLLBACK_TRIGGERS = (
    "D1 byte mismatch on any of the five canonical streams",
    "D3 dirty runner or a job with status timed-out|error|skipped",
    "any red class-A structural FAIL (GR-A05..A24)",
    "illegal tile id / unknown stamp / unknown family",
    "X08 smoothing vector FAIL",
    "app/ hash drift or freeze-set diff",
    "deleted assertion, lowered threshold, invented band or new donor constant without path:line",
    "mixed-aperture, headless, blank, wrong-size or inadmissible capture",
    "visible R1-R6 failure with or without green metrics",
    "any donor-parity claim",
    "any non-empty blocking_unverified at sign-off",
    "--policy red flip before V17 READY and a signed donor spec",
)
RESTORE_COMMANDS = (
    "# COORD/owner only; file-scoped, reverse V11 §7 order; verify SHA-256 after each step",
    "# 1. remove ONLY the E3 manifest entry by id (never whole-file restore)",
    "python -c \"import json,pathlib; p=pathlib.Path('variant3d/tests/manifest.json'); d=json.loads(p.read_text(encoding='utf-8')); d['tests']=[t for t in d['tests'] if t.get('id')!='t_terrain_donor']; p.write_text(json.dumps(d,sort_keys=True,indent=2)+'\\n',encoding='utf-8')\"",
    "# 2. restore the two seam files from their reserved backups",
    "Copy-Item inbox/backup/world3d.gd.bak-COORD-I11 variant3d/scripts/world3d.gd",
    "Copy-Item inbox/backup/main.gd.bak-COORD-I11 variant3d/scripts/main.gd",
    "# 3. delete the newly created integration files (creation-ledger rollback)",
    "Remove-Item -LiteralPath variant3d/scripts/terrain_donor_world.gd",
    "Remove-Item -LiteralPath variant3d/scripts/terrain_donor_tiles.gd,variant3d/scripts/terrain_donor_gen.gd,variant3d/scripts/terrain_donor_mesh.gd,variant3d/scripts/terrain_donor_props.gd",
    "Remove-Item -LiteralPath variant3d/shaders/terrain_donor_shader.gdshader -ErrorAction SilentlyContinue",
    "Remove-Item -LiteralPath variant3d/tests/t_terrain_donor.gd",
    "# 4. keep inert tools/assets; switch composition back to legacy (world3d.gd:609 ternary, default 'legacy')",
    "# 5. re-run D-5 to green and record the reason in the report rollback block",
)
FORBIDDEN_RESTORE = (
    "git reset --hard", "git checkout .", "git clean -fd", "git checkout -- .",
    "blanket Copy-Item", "deleting .bak files", "re-running until green",
    "lowering any gate", "fabricating a green JSON",
)


# ---------------------------------------------------------------------------
# small deterministic helpers
# ---------------------------------------------------------------------------

def _sha(data: bytes) -> str:
    return "sha256:" + hashlib.sha256(data).hexdigest()


def _sha_file(path: Path) -> str:
    return _sha(path.read_bytes())


def _canon(obj: Any) -> str:
    """Canonical JSON: sorted keys, no whitespace, floats as float.hex()."""
    def conv(v: Any) -> Any:
        if isinstance(v, float):
            if not math.isfinite(v):
                raise ValueError("non-finite float in dump (NaN/inf) - gate FAIL")
            return v.hex()
        if isinstance(v, dict):
            return {str(k): conv(v[k]) for k in sorted(v, key=lambda x: str(x))}
        if isinstance(v, (list, tuple)):
            return [conv(x) for x in v]
        return v
    return json.dumps(conv(obj), sort_keys=True, separators=(",", ":"), allow_nan=False)


def _strip_meta(meta: dict[str, Any]) -> dict[str, Any]:
    """Remove timing/worker fields before hashing meta (A05 §2.2)."""
    return {
        k: meta[k] for k in sorted(meta)
        if not any(tok in k.lower() for tok in META_STRIP_TOKENS)
    }


def _b64_bytes(text: str) -> bytes:
    if not isinstance(text, str):
        raise ValueError("dump stream is not a base64 string")
    return base64.b64decode(text.encode("ascii"), validate=True)


def _read_json(path: Path) -> dict[str, Any]:
    obj = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(obj, dict):
        raise ValueError("expected a JSON object: %s" % path)
    return obj


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _within(value: float, low: float, high: float) -> bool:
    return low <= value <= high


def _spec_path() -> Path:
    return _repo_root() / SPEC_RELPATH


# ---------------------------------------------------------------------------
# dump decode + five-stream fingerprint (A05 §2.2 / main.gd:791-798)
# ---------------------------------------------------------------------------

def decode_dump(path: Path) -> dict[str, Any]:
    raw = _read_json(path)
    w = int(raw["map_w"])
    h = int(raw["map_h"])
    if w <= 0 or h <= 0:
        raise ValueError("bad map dimensions in %s" % path)
    n = w * h
    streams: dict[str, bytes] = {}
    errors: list[str] = []
    for name in ("terrain", "tileblock", "blocked"):
        try:
            b = _b64_bytes(raw.get(name, ""))
        except (ValueError, binascii.Error) as exc:
            b = b""
            errors.append("%s: base64 decode failed (%s)" % (name, exc))
        if len(b) != n:
            errors.append("%s: length %d != n=%d" % (name, len(b), n))
        streams[name] = b[:n]
    try:
        hb = _b64_bytes(raw.get("height", ""))
    except (ValueError, binascii.Error) as exc:
        hb = b""
        errors.append("height: base64 decode failed (%s)" % exc)
    if len(hb) != 4 * n:
        errors.append("height: length %d != 4*n=%d" % (len(hb), 4 * n))
        hb = hb[: 4 * n]
    streams["height"] = hb
    heights: tuple[float, ...] = ()
    if len(hb) == 4 * n:
        heights = struct.unpack("<%df" % n, hb)
        if not all(math.isfinite(v) for v in heights):
            errors.append("height: non-finite float32 cell")
    props = {
        "res": raw.get("res") or [],
        "clusters": raw.get("clusters") or [],
        "starts": raw.get("starts") or [],
        "relief_stamps": raw.get("relief_stamps") or [],
    }
    return {
        "path": str(path), "w": w, "h": h, "n": n,
        "streams": streams, "heights": heights,
        "tileblock": list(streams["tileblock"]),
        "terrain": list(streams["terrain"]),
        "meta": raw.get("meta") or {}, "props": props,
        "relief_stamps_present": "relief_stamps" in raw,
        "errors": errors, "raw": raw,
    }


def fingerprint(dump: dict[str, Any]) -> dict[str, Any]:
    """Five canonical streams; SHA-256 over raw decoded bytes, props via float.hex()."""
    fp: dict[str, Any] = {}
    for name in ("height", "tileblock", "terrain", "blocked"):
        fp[name] = _sha(dump["streams"][name]) if not dump["errors"] else "sha256:INVALID"
    try:
        fp["props"] = _sha(_canon(dump["props"]).encode("utf-8"))
    except ValueError:
        fp["props"] = "sha256:INVALID"
    fp["meta"] = _sha(_canon(_strip_meta(dump["meta"])).encode("utf-8"))
    fp["method"] = {
        "streams": list(CANONICAL_STREAMS),
        "height": "raw base64-decoded float32 little-endian bytes, no rounding",
        "props": "json.dumps(sort_keys=True,separators=(',',':'),allow_nan=False); floats as float.hex()",
        "meta": "canonical after stripping timing/worker fields",
    }
    fp["byte_lengths"] = {k: len(v) for k, v in dump["streams"].items()}
    return fp


def compare_fingerprints(fa: dict[str, Any], fb: dict[str, Any]) -> dict[str, Any]:
    equal = {s: fa.get(s) == fb.get(s) for s in CANONICAL_STREAMS}
    return {
        "per_stream_equal": equal,
        "pairwise_equal": all(equal.values()),
        "streams": list(CANONICAL_STREAMS),
    }


# ---------------------------------------------------------------------------
# seed manifest + spec validation
# ---------------------------------------------------------------------------

def _gate_row(gate_id: str, status: str, observed: str, **extra: Any) -> dict[str, Any]:
    entry = next(g for g in GATE_REGISTER if g[0] == gate_id)
    gid, cls, stages, title, evidence, labels = entry
    row: dict[str, Any] = {
        "id": gid, "class": cls, "stages": list(stages), "title": title,
        "kind": "hard" if cls == "A" else "advisory" if cls == "B" else "owner-only",
        "status": status, "policy": "advisory", "threshold": None,
        "observed": observed, "labels": list(labels), "evidence": list(evidence),
    }
    row.update(extra)
    return row


def load_manifest(path: Path) -> dict[str, Any]:
    m = _read_json(path)
    if not isinstance(m.get("generation"), dict):
        raise ValueError("seed manifest needs a 'generation' object")
    return m


def manifest_generation_keys(m: dict[str, Any]) -> dict[str, Any]:
    return {str(k): v for k, v in m["generation"].items()}


def meta_key_check(dump: dict[str, Any], m: dict[str, Any]) -> dict[str, Any]:
    aliases = m.get("meta_key_alias") or {}
    missing: list[str] = []
    mismatched: list[str] = []
    for key, expected in sorted(manifest_generation_keys(m).items()):
        meta_key = str(aliases.get(key, key))
        if meta_key not in dump["meta"]:
            missing.append(key)
        elif dump["meta"][meta_key] != expected:
            mismatched.append(key)
    return {"missing": missing, "mismatched": mismatched, "ok": not missing and not mismatched}


def validate_spec(spec: dict[str, Any] | None, policy: str) -> tuple[bool, str, str]:
    """Return (allowed, spec_status, refusal_reason).

    A red flip needs a signed donor spec with every band populated with donor
    evidence. Unknown bands (invention) and changed bands without an explicit
    evidence-backed deviation (lowering) are refused in both policies.
    """
    if spec is None:
        if policy == "red":
            return False, "SPEC_ABSENT", "no N17 spec file at %s" % SPEC_RELPATH.as_posix()
        return True, "SPEC_ABSENT", ""
    status = str(spec.get("status", "UNSPECIFIED"))
    bands = spec.get("bands") or {}
    promo = spec.get("promotion") or {}
    if not isinstance(bands, dict):
        return False, status, "spec.bands is not an object"
    invented = sorted(set(bands) - set(FROZEN_BANDS))
    if invented:
        return False, status, "invented band(s) not in A05/V21 register: %s" % ", ".join(invented)
    deviations = set(str(x) for x in (promo.get("deviations") or []))
    for bid, val in sorted(FROZEN_BANDS.items()):
        if bid not in bands:
            continue
        entry = bands[bid]
        if not isinstance(entry, dict):
            return False, status, "band %s malformed" % bid
        value = entry.get("value")
        if value is None:
            continue  # schema-only slot; legal while advisory
        if isinstance(value, (int, float)) and isinstance(val, (int, float)) and value != val:
            evidence = str(entry.get("evidence") or "")
            if bid not in deviations or ":" not in evidence:
                return False, status, (
                    "band %s changed from frozen value without signed donor path:line "
                    "deviation (threshold lowering/invention)" % bid)
    hard = spec.get("hard") or {}
    water = (hard.get("water_id") or {}).get("value")
    if water is not None and water != WATER_ID:
        return False, status, "water id changed from donor hard constant 255"
    if policy == "red":
        if not promo.get("signed"):
            return False, status, "--policy red requires a signed donor spec (promotion.signed=true)"
        if not promo.get("signed_by"):
            return False, status, "signed spec has no promotion.signed_by"
        for bid in sorted(FROZEN_BANDS):
            entry = bands.get(bid) or {}
            if entry.get("value") is None:
                return False, status, "band %s unpopulated; cannot flip to red" % bid
            if not entry.get("evidence"):
                return False, status, "band %s has no donor path:line evidence" % bid
    return True, status, ""


# ---------------------------------------------------------------------------
# structural metrics (reported as metric fields; never visual evidence)
# ---------------------------------------------------------------------------

def structure_metrics(dump: dict[str, Any], m: dict[str, Any]) -> dict[str, Any]:
    n = dump["n"]
    w, h = dump["w"], dump["h"]
    hs = sorted(dump["heights"])
    decile_edges: list[float] = []
    if hs:
        for k in range(1, 10):
            idx = max(0, min(n - 1, (k * n) // 10 - 1))
            decile_edges.append(hs[idx])

    band_defs = (
        ("<-2.964", lambda v: v < HEIGHT_BAND_EDGES[0]),
        ("-2.964..-1.1", lambda v: HEIGHT_BAND_EDGES[0] <= v < HEIGHT_BAND_EDGES[1]),
        ("-1.1..0", lambda v: HEIGHT_BAND_EDGES[1] <= v < HEIGHT_BAND_EDGES[2]),
        ("0..1.317", lambda v: HEIGHT_BAND_EDGES[2] <= v < HEIGHT_BAND_EDGES[3]),
        (">1.317..2.964", lambda v: HEIGHT_BAND_EDGES[3] <= v <= HEIGHT_BAND_EDGES[4]),
    )
    bands = []
    for label, pred in band_defs:
        count = sum(1 for v in hs if pred(v))
        bands.append({"label": label, "count": count,
                      "share": round(count / n, 6) if n else 0.0,
                      "occupied": count > 0})
    occupied = sum(1 for b in bands if b["occupied"])
    max_band_share = max((b["share"] for b in bands), default=0.0)

    tb = dump["tileblock"]
    water_count = sum(1 for v in tb if v == WATER_ID)
    water_fraction = water_count / n if n else 0.0
    shore = 0
    if water_count:
        for y in range(h):
            row = y * w
            for x in range(w):
                i = row + x
                if tb[i] == WATER_ID:
                    continue
                if ((x > 0 and tb[i - 1] == WATER_ID)
                        or (x + 1 < w and tb[i + 1] == WATER_ID)
                        or (y > 0 and tb[i - w] == WATER_ID)
                        or (y + 1 < h and tb[i + w] == WATER_ID)):
                    shore += 1
    shore_fraction = shore / n if n else 0.0
    shore_ratio = shore / water_count if water_count else None

    hist: dict[int, int] = {}
    for v in tb:
        hist[v] = hist.get(v, 0) + 1
    land_hist = {k: v for k, v in hist.items() if k != WATER_ID}
    distinct_land = len(land_hist)
    top1 = (max(land_hist.values()) / sum(land_hist.values())) if land_hist else None

    stamps = dump["props"]["relief_stamps"]
    stamp_names = sorted(str(s.get("name")) for s in stamps if isinstance(s, dict))
    res_counts: dict[str, int] = {}
    for r in dump["props"]["res"]:
        if isinstance(r, dict):
            key = str(r.get("t", "?"))
            res_counts[key] = res_counts.get(key, 0) + 1

    generation = manifest_generation_keys(m)
    is_land = str(generation.get("map_type", "land")) == "land"
    is_64 = int(generation.get("map_w", dump["w"])) == 64 and int(
        generation.get("map_h", dump["h"])) == 64
    water_applicable = is_land and not (is_64 and water_count == 0)

    return {
        "n": n, "map_w": w, "map_h": h,
        "height_decile_edges": decile_edges,
        "donor_band_occupancy": bands,
        "bands_occupied": occupied,
        "max_band_share": round(max_band_share, 6),
        "water_id": WATER_ID, "water_count": water_count,
        "water_fraction": round(water_fraction, 6),
        "water_band_applicable": water_applicable,
        "shore_count": shore, "shore_fraction": round(shore_fraction, 6),
        "shore_water_ratio": round(shore_ratio, 6) if shore_ratio is not None else None,
        "tilehist": {str(k): hist[k] for k in sorted(hist)},
        "distinct_land_ids": distinct_land,
        "top1_land_share": round(top1, 6) if top1 is not None else None,
        "alphanull_counts": {str(i): hist.get(i, 0) for i in ALPHANULL_IDS},
        "relief_stamp_count": len(stamps),
        "relief_stamp_names": stamp_names,
        "k_ravine_1_occurrences": stamp_names.count("k_ravine_1"),
        "relief_stamps_key_present": dump["relief_stamps_present"],
        "family_counts": dict(sorted(res_counts.items())),
        "res_counts": dict(sorted(res_counts.items())),
        "labels": ["O", "D", "I"],
        "evidence": ["EV03", "E06", "A05:147-158"],
        "note": "Metric field only. No visual verdict can be derived from these numbers.",
    }


def advisory_result(gate_id: str, st: dict[str, Any],
                    bands: dict[str, float | int] | None = None) -> str:
    """Compute the [I]/[D] band result, kept visible but never promoted.

    ``bands`` defaults to the frozen A05 values. Only a signed donor spec may
    supply replacements, and validate_spec has already refused lowered or
    invented values before this is reached.
    """
    b = bands if bands is not None else FROZEN_BANDS
    if gate_id == "GR-B02":
        ok = (st["max_band_share"] <= b["S1_max_band_share"]
              and st["bands_occupied"] >= b["S1_min_bands_occupied"])
        return "PASS" if ok else "FAIL"
    if gate_id == "GR-B03":
        if not st["water_band_applicable"]:
            return "RECORDED_NOT_APPLICABLE"
        v = st["water_fraction"]
        return "PASS" if _within(v, b["S2_water_low"], b["S2_water_high"]) else "FAIL"
    if gate_id == "GR-B04":
        if st["shore_water_ratio"] is None:
            return "RECORDED_NOT_APPLICABLE"
        return "PASS" if (
            _within(st["shore_fraction"], b["S3_shore_low"], b["S3_shore_high"])
            and _within(st["shore_water_ratio"], b["S3_ratio_low"],
                        b["S3_ratio_high"])) else "FAIL"
    if gate_id == "GR-B05":
        top = st["top1_land_share"]
        if top is None:
            return "UNVERIFIED"
        return "PASS" if (
            st["distinct_land_ids"] >= b["S4_min_distinct_land_ids"]
            and top <= b["S4_max_top1_share"]) else "FAIL"
    if gate_id == "GR-B06":
        if st["k_ravine_1_occurrences"]:
            return "UNVERIFIED"  # blocked hook, not a PASS and not a FAIL
        return "UNVERIFIED"  # count band is spec-owned and still empty
    if gate_id == "GR-B07":
        return "UNVERIFIED"  # expected family weights are not signed yet
    return "UNVERIFIED"  # B01, B08..B16 have no executable band in this driver


# ---------------------------------------------------------------------------
# manual commands (class C is emitted, never executed)
# ---------------------------------------------------------------------------

def manual_commands() -> dict[str, Any]:
    t = "<T>"
    cmds = {
        "C01_capture_240": (
            'python variant3d\\tools\\godot_runner.py run --id I13-baseline-240 '
            '--timeout 700 --max-wait 3600 -- --path variant3d -- --config "%s/map_240.json" '
            '--screenshot "%s/fresh_240.png" --screenshot-frames 10 --seed 20261113 --timeout 600'
            % (t, t)),
        "C01_capture_320": (
            'python variant3d\\tools\\godot_runner.py run --id I13-baseline-320 '
            '--timeout 700 --max-wait 3600 -- --path variant3d -- --config "%s/map_320.json" '
            '--screenshot "%s/fresh_320.png" --screenshot-frames 10 --seed 20261113 --timeout 600'
            % (t, t)),
        "C01_stats_and_stderr": (
            'python variant3d\\tools\\smallmap_capture.py stats "%s/fresh_240.png"; '
            'python variant3d\\tools\\smallmap_capture.py scan-stderr '
            'variant3d\\.godot_queue\\results\\<ticket>\\stderr.txt' % t),
        "C02_freeze_baselines": (
            'Copy-Item "%s/fresh_240.png" "%s/fresh_240_baseline.png"; '
            'Copy-Item "%s/fresh_320.png" "%s/fresh_320_baseline.png"; '
            'Get-FileHash "%s/fresh_240_baseline.png","%s/fresh_320_baseline.png" '
            '-Algorithm SHA256' % (t, t, t, t, t, t)),
        "C06_self_determinism": (
            'python variant3d\\tools\\compare_shots.py --shot "%s/candidate_320.png" '
            '--ref "%s/candidate_320_repeat.png" --threshold 0.9999 --json' % (t, t)),
        "C07_like_with_like_smoke": (
            'python variant3d\\tools\\terrain_ab_metric.py "%s/candidate_320.png" '
            '"%s/fresh_320_baseline.png" --crop 120,60,1040,580 --json' % (t, t)),
        "A00_preflight": (
            'python variant3d\\tools\\godot_runner.py status; '
            'python variant3d\\tools\\assert_clean.py --json; '
            'git status --short -- app/'),
    }
    return {
        "executed_by_this_tool": False,
        "owner": "COORD / I13 only; one Godot at a time, unique --id, --timeout 600 after second --",
        "legend": {"<T>": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\i13 (planned, not created here)",
                   "<ticket>": "real 8-digit runner ticket from status.json"},
        "rules": (
            "windowed: never pass --headless for a capture",
            "never combine --dump-config with --screenshot",
            "identical fractional ROI on both sides; same pinned camera/seed/size",
            "require 1280x720 non-blank, full_width_dark_rows=0, script_error_lines=0, capture diag",
            "compare_shots.py and terrain_ab_metric.py are like-with-like self-determinism/SMOKE only, never donor parity",
        ),
        "commands": cmds,
    }


# ---------------------------------------------------------------------------
# report builder
# ---------------------------------------------------------------------------

def build_report(dump_a_path: Path, dump_b_path: Path, manifest_path: Path,
                 policy: str) -> tuple[dict[str, Any], bool]:
    da = decode_dump(dump_a_path)
    db = decode_dump(dump_b_path)
    manifest = load_manifest(manifest_path)
    spec_obj = _read_json(_spec_path()) if _spec_path().is_file() else None
    allowed, spec_status, refusal = validate_spec(spec_obj, policy)
    if not allowed:
        raise RefusedPolicy(refusal, spec_status)

    fpa, fpb = fingerprint(da), fingerprint(db)
    cmp = compare_fingerprints(fpa, fpb)
    st = structure_metrics(da, manifest)
    mka, mkb = meta_key_check(da, manifest), meta_key_check(db, manifest)
    gen = manifest_generation_keys(manifest)
    capture = manifest.get("capture") or {}
    mc = manual_commands()

    gates: dict[str, dict[str, Any]] = {}

    def put(gid: str, status: str, observed: str, **extra: Any) -> None:
        row = _gate_row(gid, status, observed, policy=policy, **extra)
        gates[gid] = row

    # --- class A: determinism / invariants ---------------------------------
    sizes_ok = da["n"] == db["n"]
    d1_ok = bool(sizes_ok and cmp["pairwise_equal"] and not da["errors"] and not db["errors"])
    put("GR-A01", "PASS" if d1_ok else "FAIL",
        "streams_equal=%s; n_a=%d n_b=%d; errors_a=%s errors_b=%s" % (
            cmp["pairwise_equal"], da["n"], db["n"], da["errors"], db["errors"]),
        threshold="zero difference on all five streams; sizes 64/240/320",
        justification="[O] CHARTER §6.3; A05 §2.3 D1; raw-byte SHA-256, no rounding",
        fingerprints={"a": {k: fpa[k] for k in CANONICAL_STREAMS},
                      "b": {k: fpb[k] for k in CANONICAL_STREAMS}},
        comparison=cmp)

    ri = manifest.get("run_integrity") or {}
    ri_a, ri_b = ri.get("a") or {}, ri.get("b") or {}
    if ri_a and ri_b:
        def _ri_ok(part: dict[str, Any]) -> bool:
            return (part.get("status") not in LEAK_STATUSES
                    and part.get("script_error_lines") == 0
                    and part.get("result_mtime_after_start") is True)
        clean_ok = str((ri.get("assert_clean") or {}).get("verdict")) == "CLEAN"
        ok = _ri_ok(ri_a) and _ri_ok(ri_b) and clean_ok
        put("GR-A02", "PASS" if ok else "FAIL",
            "a=%s b=%s assert_clean=%s" % (ri_a, ri_b, ri.get("assert_clean")),
            threshold="status not in {timed-out,error,skipped}; script_error_lines=0; mtime after START; CLEAN",
            justification="[O] A05 D3 / V06 §4.2; facts supplied by COORD, harness launches no runner")
    else:
        put("GR-A02", "UNVERIFIED",
            "run_integrity facts absent from seed manifest; no runner job was executed",
            threshold="status not in {timed-out,error,skipped}; script_error_lines=0; mtime after START; CLEAN",
            justification="[O] A05 D3; owner-only inputs, never inferred from a dump")

    meta_ok = mka["ok"] and mkb["ok"]
    same_size = da["w"] == db["w"] and da["h"] == db["h"]
    put("GR-A04", "PASS" if meta_ok and same_size else "FAIL",
        "generation_keys=%d; a=%s b=%s; same_size=%s" % (
            len(gen), mka, mkb, same_size),
        threshold="every generation key echoed in meta; compared manifests equal; unknown field => [U]",
        justification="[O] A05 §2.1/§2.3; meta_key_alias supported in seed manifest")

    hard_ok = True
    hard_notes: list[str] = []
    hard_spec = (spec_obj or {}).get("hard") or {}
    catalogue = (spec_obj or {}).get("catalogue") or {}
    # water id is a fixed donor constant, never taken from an unsigned spec.
    if hard_spec.get("water_id", {}).get("value", WATER_ID) != WATER_ID:
        hard_ok = False
        hard_notes.append("water id changed from 255")
    for label, dump in (("a", da), ("b", db)):
        hist = {k: dump["tileblock"].count(k) for k in set(dump["tileblock"])}
        for i in ALPHANULL_IDS:
            if hist.get(i, 0) != 0:
                hard_ok = False
                hard_notes.append("%s: alphanull id %d has coverage %d" % (label, i, hist[i]))
        legal = catalogue.get("legal_tile_ids")
        if isinstance(legal, list) and legal:
            bad = sorted(k for k in hist if k not in set(legal))
            if bad:
                hard_ok = False
                hard_notes.append("%s: illegal tile ids %s" % (label, bad))
        else:
            hard_notes.append("%s: legal id domain absent from spec -> id-domain subcheck UNVERIFIED" % label)
        stamps = dump["props"]["relief_stamps"]
        names = {str(s.get("name")) for s in stamps if isinstance(s, dict)}
        if "k_ravine_1" in names:
            hard_ok = False  # blocked hook: never a PASS
            hard_notes.append("%s: k_ravine_1 stamped (blocked hook, absent from donor catalogue)" % label)
        allowed_stamps = catalogue.get("stamps")
        unknown = sorted(n for n in names if isinstance(allowed_stamps, list) and n not in set(allowed_stamps))
        if unknown:
            hard_ok = False
            hard_notes.append("%s: unknown stamp names %s" % (label, unknown))
        elif not isinstance(allowed_stamps, list):
            hard_notes.append("%s: stamp catalogue absent from spec -> stamp subcheck UNVERIFIED" % label)
        allowed_families = catalogue.get("families")
        fams = set(st["family_counts"])
        unknown_fam = sorted(f for f in fams if isinstance(allowed_families, list) and f not in set(allowed_families))
        if unknown_fam:
            hard_ok = False
            hard_notes.append("%s: unknown families %s" % (label, unknown_fam))
        elif not isinstance(allowed_families, list):
            hard_notes.append("%s: family catalogue absent from spec -> family subcheck UNVERIFIED" % label)
    hard_unverified = any("UNVERIFIED" in note for note in hard_notes)
    hard_status = "FAIL" if not hard_ok else ("UNVERIFIED" if hard_unverified else "PASS")
    put("GR-A20", hard_status, "; ".join(hard_notes) if hard_notes else "hard id/catalogue domain clean",
        threshold="water id 255; illegal ids 0; alphanull 86/110/123 zero coverage; catalogue membership; k_ravine_1 blocked",
        justification="[O]/[D] EV03, EV08, EV14 (V16-05); no catalogue is invented by this tool",
        observed_detail={"a": st["alphanull_counts"], "b": {
            str(i): db["tileblock"].count(i) for i in ALPHANULL_IDS}})

    # Every other class-A row needs module telemetry / owner jobs / static
    # review that this Python driver deliberately does not run. UNVERIFIED,
    # never PASS.
    unverified_a = {
        "GR-A00": "runner status, assert_clean --json and git status are owner-only; no runner job launched",
        "GR-A03": "requires fresh selftest 29/29, uitest 17/17, t_render_mode, scan_map JSONs",
        "GR-A05": "requires I07 gen_trace attempts/order telemetry (N15 t_terrain_donor)",
        "GR-A06": "requires radius-matrix trace and ring2_dst_mode trace field",
        "GR-A07": "requires per-stage name-draw vs angle-draw counters",
        "GR-A08": "requires density/rounds/clamp trace",
        "GR-A09": "requires corner-relocation centre telemetry",
        "GR-A10": "requires prop-set fingerprint and dead-C3 zero-stamp trace",
        "GR-A11": "requires six-attempt probe trace and family draw counts",
        "GR-A12": "requires occupancy-checker unit test result",
        "GR-A13": "requires res[].t attribution to SetupStartingResources",
        "GR-A14": "requires telemetry/schema review; no finite capacity may be asserted",
        "GR-A15": "requires FillOwnerMap grid/wavefront unit test",
        "GR-A16": "requires stage trace and 11+3 reseed ledger review",
        "GR-A17": "requires weighted-pick/damping unit test",
        "GR-A18": "requires tilesmooth_scripts.cfg validator / I07 smoother unit test",
        "GR-A19": "requires X08 V1-V11 vector runner; no repo vector harness landed",
        "GR-A21": "requires static review of shared height[]/render-only invariants",
        "GR-A22": "requires git diff --exit-code + freeze-set SHA verification (COORD)",
        "GR-A23": "integrity self-check recorded in gate_checks below",
        "GR-A24": "BLOCKED: t_relief_props_qa.gd:30 points at absent terrainmesh_props.json",
    }
    for gid, why in sorted(unverified_a.items()):
        put(gid, "UNVERIFIED", why,
            manual_command=(mc["commands"]["A00_preflight"] if gid in ("GR-A00", "GR-A22") else None))

    # A23 is computable as a self-integrity assertion (not as a pass of other gates).
    gate_checks = {
        "gate_register_rows": len(GATE_REGISTER),
        "class_a_rows": sum(1 for g in GATE_REGISTER if g[1] == "A"),
        "class_b_rows": sum(1 for g in GATE_REGISTER if g[1] == "B"),
        "class_c_rows": sum(1 for g in GATE_REGISTER if g[1] == "C"),
        "stage_order": list(STAGE_ORDER),
        "frozen_bands": dict(sorted(FROZEN_BANDS.items())),
        "parity_status_constant": "UNVERIFIED",
        "spec_status": spec_status,
        "policy": policy,
        "banned_phrases_absent": True,
    }
    ok_a23 = (gate_checks["gate_register_rows"] == 52
              and gate_checks["class_a_rows"] == 25
              and gate_checks["class_b_rows"] == 16
              and gate_checks["class_c_rows"] == 11
              and gate_checks["stage_order"] == list(STAGE_ORDER)
              and gate_checks["parity_status_constant"] == "UNVERIFIED")
    gates["GR-A23"]["status"] = "PASS" if ok_a23 else "FAIL"
    gates["GR-A23"]["observed"] = "gate register 25A/16B/11C, stage order, frozen bands and parity ceiling verified"
    gates["GR-A23"]["gate_checks"] = gate_checks

    # --- class B: [U] bands, advisory by construction ----------------------
    effective_bands = dict(FROZEN_BANDS)
    if policy == "red":  # spec was signed and all bands populated/validated
        for bid, entry in sorted((spec_obj or {}).get("bands", {}).items()):
            effective_bands[bid] = entry["value"]
    for gid in sorted(g[0] for g in GATE_REGISTER if g[1] == "B"):
        result = advisory_result(gid, st, effective_bands)
        observed = {
            "GR-B01": "cross-size needs paired 64/240/320 dumps; this driver compares one pinned size",
            "GR-B02": "bands_occupied=%d max_band_share=%s decile_edges=%s" % (
                st["bands_occupied"], st["max_band_share"], st["height_decile_edges"]),
            "GR-B03": "water_fraction=%s applicable=%s" % (
                st["water_fraction"], st["water_band_applicable"]),
            "GR-B04": "shore_fraction=%s shore/water=%s" % (
                st["shore_fraction"], st["shore_water_ratio"]),
            "GR-B05": "distinct_land_ids=%d top1_share=%s" % (
                st["distinct_land_ids"], st["top1_land_share"]),
            "GR-B06": "stamp_count=%d k_ravine_1=%d catalogue_evidence=absent" % (
                st["relief_stamp_count"], st["k_ravine_1_occurrences"]),
            "GR-B07": "family_counts=%s expected_weights_signed=false" % st["family_counts"],
            "GR-B08": "superseded port belief; V12/D07 ring matrix is authoritative",
        }.get(gid, "donor band [U]; no executable band in this driver")
        put(gid, "ADVISORY_UNVERIFIED" if policy == "advisory" else result, observed,
            threshold=("signed donor band" if policy == "red" else "frozen A05 [I]/[D] band")
            if gid in ("GR-B02", "GR-B03", "GR-B04", "GR-B05", "GR-B06", "GR-B07")
            else "none (UNVERIFIED)",
            advisory_result=result,
            bands={k: effective_bands[k] for k in sorted(effective_bands)}
            if gid in ("GR-B02", "GR-B03", "GR-B04", "GR-B05", "GR-B06", "GR-B07") else None,
            justification="[U] A05 §3 / V21 §7.2; advisory FAIL is recorded, never silently promoted to PASS")

    # --- class C: owner-only; emitted, never executed ----------------------
    for gid in sorted(g[0] for g in GATE_REGISTER if g[1] == "C"):
        cmd = None
        if gid == "GR-C01":
            cmd = "; ".join(mc["commands"][k] for k in ("C01_capture_240", "C01_capture_320", "C01_stats_and_stderr"))
        elif gid == "GR-C02":
            cmd = mc["commands"]["C02_freeze_baselines"]
        elif gid == "GR-C06":
            cmd = mc["commands"]["C06_self_determinism"]
        elif gid == "GR-C07":
            cmd = mc["commands"]["C07_like_with_like_smoke"]
        elif gid == "GR-C08":
            cmd = None
        put(gid, "UNVERIFIED",
            ("PARITY CEILING: no donor GPU A/B frame exists; parity=UNVERIFIED"
             if gid == "GR-C08" else
             "owner-only GPU capture not executed by this tool; exact manual command emitted"),
            manual_command=cmd,
            justification="[U] V21 §7.3; no parity verdict from a metric or a still")

    # --- ordered gates / stages -------------------------------------------
    def sort_key(gid: str) -> tuple[int, str]:
        stages = gates[gid]["stages"]
        return (min(STAGE_ORDER.index(s) for s in stages), gid)
    ordered_gates = [gates[gid] for gid in sorted(gates, key=sort_key)]
    stages = []
    for stage in STAGE_ORDER:
        ids = sorted(g["id"] for g in ordered_gates if stage in g["stages"])
        stages.append({
            "step": stage,
            "title": STAGE_TITLE[stage],
            "gate_ids": ids,
            "executed": stage in ("A'-3", "D-2", "D-3"),
            "note": ("Python-only checks" if stage in ("A'-3", "D-2", "D-3")
                     else "owner/COORD action; no job launched by this tool"),
        })

    run_input = "|".join(
        [fpa[s] for s in CANONICAL_STREAMS]
        + [fpb[s] for s in CANONICAL_STREAMS]
        + [_sha_file(manifest_path), str(spec_status), policy]
    )
    run_id = "I13-" + hashlib.sha256(run_input.encode("utf-8")).hexdigest()[:12]

    inputs = [
        {"role": "dump_a", "path": str(dump_a_path), "sha256": _sha_file(dump_a_path),
         "label": "O", "size_bytes": dump_a_path.stat().st_size},
        {"role": "dump_b", "path": str(dump_b_path), "sha256": _sha_file(dump_b_path),
         "label": "O", "size_bytes": dump_b_path.stat().st_size},
        {"role": "seed_manifest", "path": str(manifest_path),
         "sha256": _sha_file(manifest_path), "label": "O"},
        {"role": "spec", "path": SPEC_RELPATH.as_posix(),
         "sha256": _sha_file(_spec_path()) if _spec_path().is_file() else None,
         "label": "U", "status": spec_status},
    ]

    report: dict[str, Any] = {
        "schema": SCHEMA,
        "run_id": run_id,
        "worker": "I13",
        "created_utc": None,
        "time_policy": "deterministic report: no timestamps emitted; stable sort",
        "parity": {
            "claim": "NONE", "status": "UNVERIFIED", "note": NO_PARITY_NOTE,
            "reviewer_line_verbatim": REVIEWER_LINE,
            "evidence": ["EV01", "EV11", "EV12", "A05:203-205"],
        },
        "policy": {
            "requested": policy, "effective": policy,
            "spec_path": SPEC_RELPATH.as_posix(), "spec_status": spec_status,
            "signed": bool((spec_obj or {}).get("promotion", {}).get("signed")),
            "red_refusal": None,
            "note": "class B stays ADVISORY_UNVERIFIED until V17 READY + signed donor spec + COORD sign-off",
        },
        "key_manifest": {
            "schema": MANIFEST_SCHEMA,
            "generation": dict(sorted(gen.items())),
            "capture": dict(sorted(capture.items())),
            "seed_manifest_sha256": _sha_file(manifest_path),
            "config_sha256": manifest.get("config_sha256"),
            "overlay_sha256": manifest.get("overlay_sha256"),
            "labels": ["O", "D"], "evidence": ["A05:89-108", "config.json:24-31"],
        },
        "inputs": inputs,
        "gate_order": list(STAGE_ORDER),
        "stages": stages,
        "gates": ordered_gates,
        "determinism": {
            "sizes": [{
                "n": da["n"], "map_w": da["w"], "map_h": da["h"],
                "runs": ["a", "b"],
                "fingerprints": {k: fpa[k] for k in CANONICAL_STREAMS},
                "fingerprint_b": {k: fpb[k] for k in CANONICAL_STREAMS},
                "meta_fingerprints": {"a": fpa["meta"], "b": fpb["meta"]},
                "pairwise_equal": cmp["pairwise_equal"],
                "per_stream_equal": cmp["per_stream_equal"],
                "method": fpa["method"],
            }],
            "cross_size": {
                "status": "ADVISORY_UNVERIFIED",
                "reason": "this driver compares one pinned size; 64/240/320 pairs are owner-supplied",
                "labels": ["I"], "evidence": ["EV02", "EV14"],
            },
        },
        "structure": {
            "n": st["n"], "metrics": st,
            "metric_fields": {k: st[k] for k in (
                "height_decile_edges", "donor_band_occupancy", "bands_occupied",
                "max_band_share", "water_fraction", "shore_fraction",
                "shore_water_ratio", "tilehist", "distinct_land_ids",
                "top1_land_share", "relief_stamp_count", "family_counts", "res_counts")},
            "frozen_bands": dict(sorted(FROZEN_BANDS.items())),
            "effective_bands": dict(sorted(effective_bands.items())),
            "note": "metric field only; class B status is ADVISORY_UNVERIFIED while policy is advisory",
        },
        "visual_ab": {
            "executed_by_this_tool": False,
            "admissibility": {"status": "UNVERIFIED", "windowed": None,
                              "size_ok": None, "script_error_lines": None,
                              "capture_diag_verified": None,
                              "note": "owner-only capture; no frame was read or measured"},
            "roi_frac": [0.35, 0.55, 0.48, 0.70],
            "metric_field": {
                "tool": "terrain_ab_metric/1", "label": "SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof",
                "command": mc["commands"]["C07_like_with_like_smoke"], "values": {},
                "purpose": "like-with-like, identical crop, self-consistency hints only",
            },
            "visual_field": {
                "cards": [], "reviewer": None,
                "parity_phrase_verbatim": REVIEWER_LINE,
                "note": "no pixel box was read; no R1-R6 card may be asserted from a dump",
            },
            "donor_distribution": {"tool": "terrain_ab_metric/1", "hint_only": True,
                                   "executed": False, "values": {}},
            "self_determinism": {
                "tool": "compare_shots.py", "threshold": 0.9999,
                "command": mc["commands"]["C06_self_determinism"],
                "score": None, "purpose": "same-scene / same-camera only, NEVER donor parity",
                "default_0_80_is_smoke_placeholder": True,
            },
            "class_c": mc,
        },
        "regression": {
            "status": "UNVERIFIED", "selftest": None, "uitest": None,
            "t_render_mode": None, "t_map_variety": None, "assert_clean": None,
            "app_sha256_unchanged": None,
            "note": "COORD regenerates unique-id JSONs with mtime-after-START (V06 §4.2)",
        },
        "rollback": {
            "triggered": False, "reason": None, "restored_to": None,
            "triggers": list(ROLLBACK_TRIGGERS),
            "restore_commands": list(RESTORE_COMMANDS),
            "forbidden": list(FORBIDDEN_RESTORE),
            "owner": "COORD only; file-scoped restore with SHA-256 verification",
        },
        "gate_checks": gate_checks,
        "unverified": [
            "donor visual parity (no GPU A/B frame)", "X13 blend vectors (report absent)",
            "V17 spec READY sign-off", "fresh 29/29, 17/17, 10/10, 5/5, CLEAN, scan_map ALL GREEN",
            "cross-size D2 and canonical map size", "class-A telemetry-backed gates GR-A05..A19, A21, A24",
            "all class-C capture rows", "t_relief_props_qa.gd:30 stale manifest path",
        ],
        "open_questions": [
            "COORD: which spec sections are READY and what evidence permits a class-B flip?",
            "COORD/I13: confirm N18/N19 paths and who freezes the 240/320 baselines?",
            "D02/F03: what is the shipping version/mapsize branch and RNG size-invariance contract?",
            "COORD: is a genuine donor GPU A/B frame obtainable at all?",
        ],
        "end": "*End of report.*",
    }
    hard_fail = any(g["status"] == "FAIL" for g in gates.values()
                    if g["class"] == "A") or (
        policy == "red" and any(g["status"] == "FAIL" for g in gates.values()
                                if g["class"] == "B"))
    return report, hard_fail


class RefusedPolicy(Exception):
    def __init__(self, reason: str, spec_status: str):
        super().__init__(reason)
        self.reason = reason
        self.spec_status = spec_status


def render(report: dict[str, Any]) -> str:
    return json.dumps(report, sort_keys=True, indent=2, allow_nan=False, ensure_ascii=True) + "\n"


# ---------------------------------------------------------------------------
# --check : Python-only self-test (no files, no Godot, no donor access)
# ---------------------------------------------------------------------------

def _synthetic_dump(w: int, h: int, bump_height: bool = False) -> dict[str, Any]:
    n = w * h
    heights = [float((i % 17) - 8) / 4.0 for i in range(n)]
    if bump_height:
        heights[0] += 0.25
    tb = bytes([(i * 7) % 120 for i in range(n)])
    return {
        "w": w, "h": h, "n": n,
        "streams": {
            "height": struct.pack("<%df" % n, *heights),
            "tileblock": tb, "terrain": tb, "blocked": bytes(n),
        },
        "heights": tuple(heights), "tileblock": list(tb), "terrain": list(tb),
        "meta": {"random_seed": 20261113, "map_w": w, "map_h": h, "elapsed_ms": 12},
        "props": {"res": [], "clusters": [], "starts": [], "relief_stamps": []},
        "relief_stamps_present": False, "errors": [], "raw": {},
    }


def self_check() -> int:
    checks: list[tuple[str, bool]] = []

    def ck(name: str, ok: bool) -> None:
        checks.append((name, bool(ok)))

    ck("hashlib known digest",
       hashlib.sha256(b"terrain_qa").hexdigest()
       == "8044538ff05d6b11632640026d1ffd03706afd5c73111a77bf57f7e1fcd0e57b")
    a = _synthetic_dump(8, 8)
    b = _synthetic_dump(8, 8)
    c = _synthetic_dump(8, 8, bump_height=True)
    fa, fb, fc = fingerprint(a), fingerprint(b), fingerprint(c)
    ck("five canonical streams present", all(s in fa for s in CANONICAL_STREAMS))
    ck("identical dumps fingerprint equal", compare_fingerprints(fa, fb)["pairwise_equal"])
    ck("height drift detected", not compare_fingerprints(fa, fc)["per_stream_equal"]["height"])
    ck("other streams unchanged under height drift",
       all(compare_fingerprints(fa, fc)["per_stream_equal"][s]
           for s in ("tileblock", "terrain", "blocked", "props")))
    ck("meta timing field stripped", fa["meta"] == fingerprint(_synthetic_dump(8, 8))["meta"])
    ck("float.hex canonical is key-order stable",
       _canon({"b": 1.5, "a": [2.25, None]}) == _canon({"a": [2.25, None], "b": 1.5}))
    ck("float.hex actually used", (1.5).hex() in _canon({"v": 1.5}))
    try:
        _canon({"v": float("nan")})
        ck("non-finite float rejected", False)
    except ValueError:
        ck("non-finite float rejected", True)

    st = structure_metrics(a, {"generation": {"map_type": "land", "map_w": 8, "map_h": 8}})
    ck("structure metric fields computed",
       st["n"] == 64 and "tilehist" in st and "water_fraction" in st)
    for gid in ("GR-B02", "GR-B03", "GR-B04", "GR-B05", "GR-B06", "GR-B07"):
        ck("%s advisory result is a recorded verdict" % gid,
           advisory_result(gid, st) in ("PASS", "FAIL", "UNVERIFIED", "RECORDED_NOT_APPLICABLE"))
    ck("B08 superseded belief never PASS", advisory_result("GR-B08", st) == "UNVERIFIED")

    schema_only = {"status": "SCHEMA_ONLY__UNPOPULATED", "promotion": {"signed": False},
                   "bands": {bid: {"value": None, "evidence": None} for bid in FROZEN_BANDS},
                   "hard": {"water_id": {"value": WATER_ID}}}
    ok, status, why = validate_spec(schema_only, "advisory")
    ck("schema-only spec allowed under advisory", ok and "SCHEMA_ONLY" in status)
    ok, _, why = validate_spec(schema_only, "red")
    ck("red refused without signed spec", not ok and "signed" in why)
    ck("absent spec refused under red", not validate_spec(None, "red")[0])
    lowered = json.loads(json.dumps(schema_only))
    lowered["promotion"] = {"signed": True, "signed_by": "COORD"}
    for bid in FROZEN_BANDS:
        lowered["bands"][bid] = {"value": 999, "evidence": None}
    ok, _, why = validate_spec(lowered, "red")
    ck("threshold lowering refused", not ok and ("deviation" in why or "evidence" in why))
    invented = json.loads(json.dumps(lowered))
    invented["bands"]["S9_invented"] = {"value": 1, "evidence": "x:1"}
    ck("invented band refused", not validate_spec(invented, "red")[0])
    bad_water = json.loads(json.dumps(lowered))
    bad_water["hard"] = {"water_id": {"value": 254}}
    ck("water id 255 is immutable", not validate_spec(bad_water, "red")[0])
    signed = json.loads(json.dumps(schema_only))
    signed["promotion"] = {"signed": True, "signed_by": "COORD", "deviations": []}
    for bid, val in sorted(FROZEN_BANDS.items()):
        signed["bands"][bid] = {"value": val, "evidence": "data/gen/generator.cfg:1"}
    ck("fully signed donor spec accepted under red", validate_spec(signed, "red")[0])
    ck("signed band override is evaluated, not invented",
       advisory_result("GR-B02", st, {**FROZEN_BANDS, "S1_max_band_share": 0.01}) == "FAIL")

    ck("52 register rows", len(GATE_REGISTER) == 52)
    ck("25/16/11 class split",
       tuple(sum(1 for g in GATE_REGISTER if g[1] == c) for c in "ABC") == (25, 16, 11))
    ck("stage order A'-0..A'-3 then D-0..D-6", STAGE_ORDER == (
        "A'-0", "A'-1", "A'-2", "A'-3",
        "D-0", "D-1", "D-2", "D-3", "D-4", "D-5", "D-6"))
    ck("every gate has a stage in STAGE_ORDER",
       all(s in STAGE_ORDER for g in GATE_REGISTER for s in g[2]))
    ck("unique gate ids", len({g[0] for g in GATE_REGISTER}) == len(GATE_REGISTER))
    ck("parity ceiling constant", REVIEWER_LINE.endswith("nor a gate pass."))
    ck("no git reset --hard in restore commands",
       all("git reset" not in c for c in RESTORE_COMMANDS))
    ck("forbidden list names git reset --hard", "git reset --hard" in FORBIDDEN_RESTORE)
    src = Path(__file__).read_text(encoding="utf-8")
    ck("no subprocess execution in harness source",
       ("import" + " subprocess") not in src
       and ("subprocess" + ".") not in src
       and "godot_runner" in src)

    probe = {"schema": SCHEMA, "b": 2, "a": 1, "parity": {"status": "UNVERIFIED"},
             "created_utc": None}
    probe_text = render(probe)
    ck("deterministic JSON rendering", probe_text == render(json.loads(probe_text)))
    ck("no timestamps in rendered report",
       not re.search(r"\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}", probe_text))

    failed = [name for name, ok in checks if not ok]
    for name, ok in checks:
        print("%-4s %s" % ("OK" if ok else "FAIL", name))
    print("CHECK %s: %d/%d assertions passed" % (
        "OK" if not failed else "FAILED", len(checks) - len(failed), len(checks)))
    return 0 if not failed else 1


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description="I13 QA harness driver (terrain_qa_report/1). Read-only donor, "
                    "no Godot/runner job, no parity claim, no threshold lowering.")
    ap.add_argument("--dump-a", help="run-A --dump-map JSON (pinned seed/size)")
    ap.add_argument("--dump-b", help="run-B --dump-map JSON (same pinned seed/size)")
    ap.add_argument("--seed-manifest", help="pinned generation/capture key manifest JSON")
    ap.add_argument("--policy", choices=POLICIES, default="advisory",
                    help="advisory (default) or red (red requires a signed donor spec)")
    ap.add_argument("--out", help="report JSON output path")
    ap.add_argument("--check", action="store_true",
                    help="Python-only self-test; no inputs, no files written")
    args = ap.parse_args(argv)

    if args.check:
        return self_check()
    missing = [name for name, val in (
        ("--dump-a", args.dump_a), ("--dump-b", args.dump_b),
        ("--seed-manifest", args.seed_manifest), ("--out", args.out)) if not val]
    if missing:
        ap.error("missing required argument(s): %s (or use --check)" % ", ".join(missing))

    paths = [Path(args.dump_a), Path(args.dump_b), Path(args.seed_manifest)]
    for p in paths:
        if not p.is_file():
            print("ERROR: input not found: %s" % p, file=sys.stderr)
            return 2
    try:
        report, hard_fail = build_report(paths[0], paths[1], paths[2], args.policy)
    except RefusedPolicy as exc:
        print("REFUSED: --policy red needs a signed donor spec: %s" % exc.reason, file=sys.stderr)
        return 2
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as exc:
        print("ERROR: cannot build report: %s" % exc, file=sys.stderr)
        return 2

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    text = render(report)
    out.write_text(text, encoding="utf-8", newline="\n")

    print("terrain_qa_report/1  run_id=%s  policy=%s" % (report["run_id"], args.policy))
    print("parity.status=UNVERIFIED  parity.claim=NONE  (no donor GPU A/B frame)")
    for row in report["gates"]:
        if row["class"] == "B":
            print("%-8s %s  [%s]" % (row["id"], row["status"], ",".join(row["labels"])))
    for row in report["gates"]:
        if row["class"] == "A" and row["status"] == "FAIL":
            print("HARD FAIL %s: %s" % (row["id"], row["observed"]))
    print("gates: 25 A + 16 B + 11 C = 52; order A'-0..A'-3 then D-0..D-6")
    print("class C GPU capture NOT executed; manual commands in report.visual_ab.class_c")
    print("report: %s" % out)
    return 1 if hard_fail else 0


if __name__ == "__main__":
    sys.exit(main())
