#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Production decoder for the seven Cossacks 3 donor generation configs (I01).

Owner file of ticket I01 in the 2026-11-26 DONOR-FIRST terrain swarm.  Ported
from X20's validated read-only prototype (temp/opencode/cfg_decode/
decode_donor_cfg.py) under spec/09 + spec/11 and reports/F03_gen_config.md.

The donor install is READ ONLY.  This tool reads text bytes only (latin-1,
CRLF preserved), never executes a donor binary and never copies donor bytes
into the repository.  It emits three derived, labelled JSON documents:

    constants.json      every active key -> value, with exact donor path:line
    config_strings.json every non-constant line, value:null + UNVERIFIED
    manifest.json       source hashes, F03 count checks, contradictions,
                        determinism proof, provenance and parity flag

Labels: [O] observed literal, [D] derived, [I] inferred, [U] UNVERIFIED.
PORT APPROXIMATION only.  visual_parity_claim is always false; no donor
visual-parity claim is made.  Dry-run is the default; writes need --out.

Two donor contradictions are preserved verbatim with donor path:line and are
never "fixed": TileSmoothPasses=6 vs script SmoothTileMap(...,3), and
TileSmoothListFileName=tilesmooth.cfg vs the script's tilesmooth_scripts.cfg.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from decimal import Decimal

SCHEMA_VERSION = "1.0"
TOOL_ID = "decode_donor_cfg.py/I01"
NO_PARITY_CLAIM = False  # manifest flag: visual_parity_claim must stay false

# ---------------------------------------------------------------------------
# Ground truth from F03 section 2: donor bytes and SHA-256 of untouched bytes.
# These are cited observations, not invented constants.  A mismatch is
# reported as FAIL; the donor file is never rewritten to make a check pass.
# ---------------------------------------------------------------------------
FILE_SPECS = [
    {
        "key": "globalparams",
        "rel": r"data\gen\globalparams.cfg",
        "bytes": 537,
        "lines": 22,
        "sha256": "15a8dc64a91dc4e72f45a997d6f6a5b770b2b77786518f48a75e04ab95727a51",
        "structure": "1 section, 20 flat keys (:1-21)",
    },
    {
        "key": "localparams",
        "rel": r"data\gen\localparams.cfg",
        "bytes": 508,
        "lines": 20,
        "sha256": "8d174830c47388e28ed80ad434ad591943a7d69616fb89697e68175b0934a12d",
        "structure": "LocalTerrainParams -> 1 record, 13 keys (:3-16)",
    },
    {
        "key": "mapcover",
        "rel": r"data\gen\mapcover.cfg",
        "bytes": 1196,
        "lines": 40,
        "sha256": "ff0a7bf43314af53c93dd14f992fa4e6b866cd5acf07b95abdb2404ed9fa43f2",
        "structure": "ClimaticZones -> HeightTileZones -> Tiles + empty PatternCovers / LightPatterns (:2-37)",
    },
    {
        "key": "tilesmooth",
        "rel": r"data\gen\tilesmooth.cfg",
        "bytes": 2796,
        "lines": 129,
        "sha256": "1753533e7984c2319c3c5fdbc519728e0937905c4cc5117846432ce008b89c7d",
        "structure": "8 consecutive section.begin blocks, 30 plain tile names (:1-129)",
    },
    {
        "key": "tilesmooth_scripts",
        "rel": r"data\gen\tilesmooth_scripts.cfg",
        "bytes": 64017,
        "lines": 1863,
        "sha256": "b82c88844160c0451696951466a72bcd1dff64079388c0ad0b3b0a07a531b433",
        "structure": "TileSmoothLists -> 22 chains, 130 groups, 310 entries (:1-1863)",
    },
    {
        "key": "generator",
        "rel": r"data\game\var\generator.cfg",
        "bytes": 70074,
        "lines": 2367,
        "sha256": "f8a5cd2e08952565290adf4da888017467097c9b6e7666a45cf141827a974cc3",
        "structure": "TerrainTypes (6), TerrainTypesDLC5 (9), Patterns (64 records, 493 pairs) (:2-2366)",
    },
    {
        "key": "startingsettings",
        "rel": r"data\game\var\startingsettings.cfg",
        "bytes": 116920,
        "lines": 3424,
        "sha256": "17d4aeddaf4496594bda74e5f1fcc4f8ff0e149a5b2a53211c8f1eba200c111f",
        "structure": "startingsettings -> 19 presets, 61 countries, 61 masks, 61 legends, 276 legend entries (:87-3423)",
    },
]

# Donor script quoted read-only for the two preserved contradictions (F03 F3/F4).
CONTRADICTION_SCRIPT = r"data\scripts\common.inc\smoothtiles.inc"

RE_KV = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$")
RE_STRUCT_BEGIN = re.compile(r"^(.*?)\s*:\s*struct\.begin$")
RE_STRUCT_END = re.compile(r"^struct\.end$")
RE_SECTION_BEGIN = re.compile(r"^(.*?)\s*:?\s*section\.begin$")
RE_SECTION_END = re.compile(r"^section\.end$")
RE_ANON = re.compile(r"^\[\*\]\s*=\s*(.*)$")
RE_INT = re.compile(r"^[+-]?\d+$")
RE_FLOAT = re.compile(r"^[+-]?(?:\d+\.\d*|\.\d+|\d+)(?:[eE][+-]?\d+)?$")
RE_PROB = re.compile(r"^Prob\s*=\s*([0-9][0-9.]*)\s*$")
RE_TILE = re.compile(r"^TileName\s*=\s*(.*?)\s*$")



# V93 durability (V78): never emit an absolute donor install path.
_ABS_DONOR_PATH = re.compile(r"[A-Za-z]:[\\/](?:[^\\/\n\"]*[\\/])*Cossacks 3")

def _scrub_donor_paths(obj):
    if isinstance(obj, str):
        return _ABS_DONOR_PATH.sub("$COSSACKS3_DIR", obj)
    if isinstance(obj, dict):
        return {k: _scrub_donor_paths(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_scrub_donor_paths(v) for v in obj]
    return obj

def short_rel(path: str) -> str:
    r"""Donor-relative short form used by F03 (gen\X.cfg / var\X.cfg)."""
    return path.replace("data\\", "", 1)


def typed_value(raw: str):
    """Return (value, value_type, label). Empty literal stays observed [O]."""
    if raw == "":
        return "", "empty", "O"  # observed empty literal, not undecodable
    if raw == "True" or raw == "False":
        return raw == "True", "bool", "O"
    if RE_INT.match(raw):
        return int(raw), "int", "O"
    if RE_FLOAT.match(raw):
        return float(raw), "float", "O"
    return raw, "string", "O"


def classify(core: str) -> str:
    if core == "":
        return "blank"
    if RE_KV.match(core):
        return "kv"
    if RE_STRUCT_BEGIN.match(core):
        return "struct_begin"
    if RE_STRUCT_END.match(core):
        return "struct_end"
    if RE_SECTION_BEGIN.match(core):
        return "section_begin"
    if RE_SECTION_END.match(core):
        return "section_end"
    if RE_ANON.match(core):
        return "anon_assignment"
    return "other"


class Frame:
    __slots__ = ("kind", "name", "index", "label")

    def __init__(self, kind, name, index=None):
        self.kind = kind
        self.name = name
        self.index = index
        self.label = name if index is None else "%s#%d" % (name, index)


def path_of(stack, leaf=None):
    parts = [f.label for f in stack]
    if leaf is not None:
        parts.append(leaf)
    return "/".join(parts)


def unparsed_record(path, spec, lineno, raw_line, category, stack,
                    extra=None):
    """A03 invariant: undecodable = null value + label UNVERIFIED.

    The raw bytes and raw_value are kept verbatim for provenance; the decoded
    `value` is deliberately null rather than guessed.
    """
    rec = {
        "source": path,
        "source_rel": spec["rel"],
        "source_short": short_rel(spec["rel"]),
        "line": lineno,
        "raw": raw_line,
        "value": None,
        "value_type": None,
        "category": category,
        "structural_path": path_of(stack),
        "label": "UNVERIFIED",
    }
    if extra:
        rec.update(extra)
    return rec


def parse_file(game_root: str, spec: dict):
    """Parse one donor config with latin-1 + CRLF preserved.

    Returns dict with raw bytes/hash/line census plus three derived views:
      constants     active key -> value literals (label O)
      strings       every non-constant line (value null, UNVERIFIED)
      tokens        structural tokens with active/commented flags
    """
    path = os.path.join(game_root, spec["rel"])
    with open(path, "rb") as fh:
        blob = fh.read()
    text = blob.decode("latin-1")
    physical_lines = text.splitlines()
    crlf = blob.count(b"\r\n")
    eol = "CRLF" if crlf == len(physical_lines) and crlf == blob.count(b"\n") else "MIXED/OTHER"

    constants = []
    strings = []
    tokens = []
    stack = []
    anon_counters = {}

    for lineno, raw_line in enumerate(physical_lines, start=1):
        stripped = raw_line.strip()
        commented = stripped.startswith("//")
        core = stripped
        while core.startswith("//"):
            core = core[2:].lstrip()
        kind = classify(core)

        if kind == "kv":
            m = RE_KV.match(core)
            key, raw_value = m.group(1), m.group(2)
            value, value_type, label = typed_value(raw_value)
            if commented:
                # Dead / commented-out literal: UNVERIFIED as an active value.
                strings.append(unparsed_record(
                    path, spec, lineno, raw_line, "dead_kv", stack,
                    {"key": key, "raw_value": raw_value,
                     "structural_path": path_of(stack, key)}))
                tokens.append({"kind": "kv", "key": key, "active": False,
                               "line": lineno, "raw_value": raw_value})
                continue
            rec = {
                "key": key, "value": value, "raw_value": raw_value,
                "value_type": value_type, "source": path,
                "source_rel": spec["rel"], "source_short": short_rel(spec["rel"]),
                "line": lineno, "structural_path": path_of(stack, key),
                "label": label, "active": True,
            }
            constants.append(rec)
            tokens.append({"kind": "kv", "key": key, "active": True,
                           "line": lineno, "raw_value": raw_value})
            continue

        if kind == "section_begin":
            name_match = RE_SECTION_BEGIN.match(core)
            name = (name_match.group(1).strip() if name_match else "") or "<root>"
            stack = [Frame("section", name)]
        elif kind == "struct_begin":
            sm = RE_STRUCT_BEGIN.match(core)
            name = sm.group(1).strip() if sm else "?"
            idx = None
            if name == "[*]":
                parent = path_of(stack)
                ck = (parent, "anon_struct")
                anon_counters[ck] = anon_counters.get(ck, 0) + 1
                idx = anon_counters[ck]
            stack.append(Frame("struct", name, idx))
        elif kind in ("struct_end", "section_end"):
            if stack:
                stack.pop()
        elif kind == "anon_assignment":
            m = RE_ANON.match(core)
            strings.append(unparsed_record(
                path, spec, lineno, raw_line, "anon_assignment", stack,
                {"raw_value": m.group(1),
                 "structural_path": path_of(stack, "[*]")}))
        else:
            category = "blank" if kind == "blank" else ("comment" if commented else "other")
            strings.append(unparsed_record(
                path, spec, lineno, raw_line, category, stack))

        if kind in ("struct_begin", "struct_end", "section_begin", "section_end"):
            tokens.append({"kind": kind, "name": core, "active": not commented,
                           "line": lineno, "raw": raw_line})
            strings.append(unparsed_record(
                path, spec, lineno, raw_line, "structural", stack,
                {"structural_token": kind}))

    return {
        "key": spec["key"], "rel": spec["rel"], "short": short_rel(spec["rel"]),
        "source": path, "sha256": hashlib.sha256(blob).hexdigest(),
        "expected_sha256": spec["sha256"], "bytes": len(blob),
        "expected_bytes": spec["bytes"],
        "physical_lines": len(physical_lines), "expected_lines": spec["lines"],
        "eol": eol, "crlf_count": crlf, "constants": constants,
        "strings": strings, "tokens": tokens, "raw_text": text, "blob": blob,
    }


# ---------------------------------------------------------------------------
# Counting: three independent passes, then a fourth targeted pass on mismatch.
# ---------------------------------------------------------------------------
def token_count(parsed, kind, active=None, name=None):
    out = 0
    for t in parsed["tokens"]:
        if t["kind"] != kind:
            continue
        if active is not None and t["active"] != active:
            continue
        if name is not None and name not in t.get("raw", t.get("name", "")):
            continue
        out += 1
    return out


def kv_count(parsed, key, active=None):
    out = 0
    for t in parsed["tokens"]:
        if t["kind"] == "kv" and t["key"] == key:
            if active is None or t["active"] == active:
                out += 1
    return out


def raw_line_count(parsed, pattern, active_only=False, strip_comments=True):
    out = 0
    for line in parsed["raw_text"].splitlines():
        s = line.strip()
        commented = s.startswith("//")
        if strip_comments:
            while s.startswith("//"):
                s = s[2:].lstrip()
        if active_only and commented:
            continue
        if re.search(pattern, s):
            out += 1
    return out


def byte_substr_count(parsed, needle: bytes):
    return parsed["blob"].count(needle)


def byte_regex_count(parsed, pattern: bytes):
    """Independent pass-3 instrument: anchored regex over raw latin-1 bytes."""
    return len(re.findall(pattern, parsed["blob"]))


def active_prob_sum_decimal(parsed):
    total = Decimal("0")
    n = 0
    for line in parsed["raw_text"].splitlines():
        s = line.strip()
        if s.startswith("//"):
            continue
        m = RE_PROB.match(s)
        if m:
            total += Decimal(m.group(1))
            n += 1
    return total, n


def active_names(parsed):
    names = []
    for line in parsed["raw_text"].splitlines():
        s = line.strip()
        if s.startswith("//"):
            continue
        m = RE_TILE.match(s)
        if m:
            names.append(m.group(1))
    return names


# Independent instruments for C11/C12.  X20's prototype repeated the SAME
# expression three times, which is a tautological self-check (it can never
# fail).  These three passes use different evidence paths: parsed raw text,
# structural token stream, and anchored byte regex over the untouched bytes.
RE_ACTIVE_TILENAME_BYTES = rb"(?m)^[ \t]*(?!//)TileName[ \t]*=[ \t]*(.*?)[ \t]*\r?$"
RE_ACTIVE_PROB_BYTES = rb"(?m)^[ \t]*(?!//)Prob[ \t]*=[ \t]*([0-9][0-9.]*)[ \t]*\r?$"


def tilenames_from_tokens(parsed):
    return set(t["raw_value"].strip() for t in parsed["tokens"]
               if t["kind"] == "kv" and t["key"] == "TileName" and t["active"])


def tilenames_from_bytes(parsed):
    return set(m.group(1).decode("latin-1").strip()
               for m in re.finditer(RE_ACTIVE_TILENAME_BYTES, parsed["blob"]))


def prob_sum_from_tokens(parsed):
    total = Decimal("0")
    for t in parsed["tokens"]:
        if t["kind"] == "kv" and t["key"] == "Prob" and t["active"]:
            total += Decimal(t["raw_value"].strip())
    return total


def prob_sum_from_bytes(parsed):
    total = Decimal("0")
    for m in re.finditer(RE_ACTIVE_PROB_BYTES, parsed["blob"]):
        total += Decimal(m.group(1).decode("ascii"))
    return total


def compute_evidence(parsed_by_key):
    gp = parsed_by_key["globalparams"]
    lp = parsed_by_key["localparams"]
    mc = parsed_by_key["mapcover"]
    ts = parsed_by_key["tilesmooth"]
    tss = parsed_by_key["tilesmooth_scripts"]
    gen = parsed_by_key["generator"]
    ss = parsed_by_key["startingsettings"]

    prob_total, prob_n = active_prob_sum_decimal(tss)
    names = active_names(tss)

    checks = []

    def add(cid, label, expected, p1, p2, p3, unit="count", note=""):
        vals = [p1, p2, p3]
        ok = all(v == expected for v in vals)
        checks.append({
            "id": cid, "label": label,
            "expected": str(expected) if unit == "decimal" else expected,
            "pass1_structural": str(p1) if unit == "decimal" else p1,
            "pass2_regex": str(p2) if unit == "decimal" else p2,
            "pass3_bytes": str(p3) if unit == "decimal" else p3,
            "unit": unit, "result": "PASS" if ok else "FAIL", "note": note,
        })

    # 1-3: flat key counts.  COORD directive (2026-11-26): C01 validates against
    # the OBSERVED 19 keys, not F03's summary headline "20".  Four independent
    # passes agree on 19; F03's own §3.1 dump / §4 table also list 19 rows.
    # The mismatch is recorded as a labelled documented exception (MP-1);
    # no 20th key is invented.
    add("C01", "globalparams.cfg active key=value lines", 19,
        len(gp["constants"]),
        raw_line_count(gp, RE_KV.pattern, active_only=True),
        byte_regex_count(gp, rb"(?m)^[ \t]*[A-Za-z_]\w*[ \t]*="),
        note=("F03 summary 20 vs observed 19; F03 table lists 19. Validated against "
              "observed 19 — documented exception MP-1, no key invented"))
    add("C02", "localparams.cfg active key=value lines", 13,
        len(lp["constants"]),
        raw_line_count(lp, RE_KV.pattern, active_only=True),
        len([l for l in lp["raw_text"].splitlines() if "=" in l and not l.strip().startswith("//")]),
        note="F03 §5.1: localparams.cfg:4-16")
    add("C03", "mapcover.cfg active key=value lines", 15,
        len(mc["constants"]),
        raw_line_count(mc, RE_KV.pattern, active_only=True),
        len([l for l in mc["raw_text"].splitlines() if "=" in l and not l.strip().startswith("//")]),
        note="F03 §5.2: mapcover.cfg:4-30 (15 parameter rows)")

    # 4-5: plain tilesmooth.cfg.
    add("C04", "tilesmooth.cfg section.begin blocks", 8,
        token_count(ts, "section_begin", name="section.begin"),
        raw_line_count(ts, r"section\.begin"),
        byte_substr_count(ts, b"section.begin"),
        note="F03 §6.1: lines 1,15,29,46,63,80,97,114 (supersedes prior '10')")
    add("C05", "tilesmooth.cfg TileName entries", 30,
        kv_count(ts, "TileName", active=True),
        raw_line_count(ts, RE_TILE.pattern, active_only=True),
        byte_substr_count(ts, b"TileName ="),
        note="F03 §2/§6.1: 3+3+4x6 = 30, no Prob key")

    # 6-12: weighted tilesmooth_scripts.cfg.
    add("C06", "tilesmooth_scripts.cfg chains (SmoothTiles structs)", 22,
        token_count(tss, "struct_begin", name="SmoothTiles"),
        raw_line_count(tss, r"SmoothTiles\s*:\s*struct\.begin"),
        byte_substr_count(tss, b"SmoothTiles : struct.begin"),
        note="F03 §6.3: C00..C21; C10/C21 all-commented terminators")
    add("C07", "tilesmooth_scripts.cfg groups (TileNames structs, all)", 130,
        token_count(tss, "struct_begin", name="TileNames"),
        raw_line_count(tss, r"TileNames\s*:\s*struct\.begin"),
        byte_substr_count(tss, b"TileNames : struct.begin"),
        note="F03 §6.3/§6.6: 118 active + 12 commented")
    add("C08", "tilesmooth_scripts.cfg active groups", 118,
        token_count(tss, "struct_begin", active=True, name="TileNames"),
        raw_line_count(tss, r"TileNames\s*:\s*struct\.begin", active_only=True),
        byte_regex_count(tss, rb"(?m)^[ \t]*TileNames[ \t]*:[ \t]*struct\.begin[ \t]*\r?$"),
        note="F03 §6.3")
    add("C09", "tilesmooth_scripts.cfg entries (TileName lines, all)", 310,
        kv_count(tss, "TileName", active=True) + kv_count(tss, "TileName", active=False),
        raw_line_count(tss, RE_TILE.pattern),
        byte_substr_count(tss, b"TileName ="),
        note="F03 §6.3/§6.6: 282 active + 28 commented")
    add("C10", "tilesmooth_scripts.cfg active entries", 282,
        kv_count(tss, "TileName", active=True),
        raw_line_count(tss, RE_TILE.pattern, active_only=True),
        byte_regex_count(tss, rb"(?m)^[ \t]*TileName[ \t]*=[ \t]*"),
        note="F03 §6.3")
    add("C11", "tilesmooth_scripts.cfg distinct active TileName values", 86,
        len(set(names)), len(tilenames_from_tokens(tss)), len(tilenames_from_bytes(tss)),
        note=("F03 §6.3/§6.5: three INDEPENDENT passes — raw text, structural "
              "tokens, anchored byte regex; no tautological re-use"))
    add("C12", "tilesmooth_scripts.cfg sum of active Prob", Decimal("174.0168"),
        prob_total, prob_sum_from_tokens(tss), prob_sum_from_bytes(tss),
        unit="decimal",
        note=("F03 §6.3: three INDEPENDENT Decimal passes — raw text, structural "
              "tokens, anchored byte regex; //Prob alternatives excluded; "
              "active Prob lines=%d" % prob_n))

    # 13-14: generator.cfg.
    add("C13", "generator.cfg pattern families (Name = records)", 64,
        kv_count(gen, "Name", active=True),
        raw_line_count(gen, r"^Name\s*=", active_only=True),
        byte_regex_count(gen, rb"(?m)^[ \t]*Name[ \t]*=[ \t]*"),
        note="F03 §7.3: generator.cfg:69-2314; 4 duplicate names -> index key required")
    add("C14", "generator.cfg Pattern/Freq pairs", 493,
        kv_count(gen, "Pattern", active=True),
        raw_line_count(gen, r"^Pattern\s*=", active_only=True),
        byte_substr_count(gen, b"Pattern ="),
        note="F03 §7.2: Freq lines independently counted = %d" % kv_count(gen, "Freq", active=True))

    # 15-19: startingsettings.cfg.
    add("C15", "startingsettings.cfg presets (startid =)", 19,
        kv_count(ss, "startid", active=True),
        raw_line_count(ss, r"^startid\s*=", active_only=True),
        byte_substr_count(ss, b"startid ="),
        note="F03 §8: startingsettings.cfg:87-3423")
    add("C16", "startingsettings.cfg countries (allowedcountries structs)", 61,
        token_count(ss, "struct_begin", name="allowedcountries"),
        raw_line_count(ss, r"allowedcountries\s*:\s*struct\.begin"),
        byte_substr_count(ss, b"allowedcountries : struct.begin"),
        note="F03 §2: '61 countries[]'. The token 'countries : struct.begin' occurs 79x; see MP-2")
    add("C17", "startingsettings.cfg mask structs", 61,
        token_count(ss, "struct_begin", name="mask"),
        raw_line_count(ss, r"mask\s*:\s*struct\.begin"),
        byte_substr_count(ss, b"mask : struct.begin"),
        note="F03 §8: 61 mask blocks")
    add("C18", "startingsettings.cfg legends structs", 61,
        token_count(ss, "struct_begin", name="legends"),
        raw_line_count(ss, r"legends\s*:\s*struct\.begin"),
        byte_substr_count(ss, b"legends : struct.begin"),
        note="F03 §8: 61 legends blocks")
    add("C19", "startingsettings.cfg legend entries (key =)", 276,
        kv_count(ss, "key", active=True),
        raw_line_count(ss, r"^key\s*=", active_only=True),
        byte_substr_count(ss, b"key ="),
        note="F03 §8: 276 key/role/countrysid/basename quadruples")

    return checks, prob_total, names


def multi_pass_audit(checks, parsed_by_key):
    """Fourth, targeted pass on FAILs; records what was attempted."""
    audit = []
    owner = {
        "C01": "globalparams", "C02": "localparams", "C03": "mapcover",
        "C04": "tilesmooth", "C05": "tilesmooth",
        "C06": "tilesmooth_scripts", "C07": "tilesmooth_scripts",
        "C08": "tilesmooth_scripts", "C09": "tilesmooth_scripts",
        "C10": "tilesmooth_scripts", "C11": "tilesmooth_scripts",
        "C12": "tilesmooth_scripts", "C13": "generator", "C14": "generator",
        "C15": "startingsettings", "C16": "startingsettings",
        "C17": "startingsettings", "C18": "startingsettings",
        "C19": "startingsettings",
    }
    for row in checks:
        if row["result"] == "PASS":
            continue
        parsed = parsed_by_key[owner[row["id"]]]
        cited = set(line.strip() for line in parsed["raw_text"].splitlines())
        detail = {
            "check": row["id"],
            "pass4": "targeted raw-line re-read + F03 line-range cross-check",
            "distinct_nonblank_lines": len(cited),
        }
        if row["id"] == "C01":
            detail.update({
                "pass4_verbatim": [
                    "%d:%s" % (i, l) for i, l in enumerate(parsed["raw_text"].splitlines(), 1)
                ],
                "pass4_result": "19 key=value lines (2..20 inclusive); line 21 is section.end, line 22 empty",
                "passes_1_2_3_4_agree": "19",
                "verdict": "F03 summary 20 vs observed 19; F03 table lists 19. F03's own "
                           "§3.1 file dump and §4 table both list 19 rows. Validate against "
                           "observed 19 and record MP-1; do not guess a 20th key. [O]/[D]",
            })
        else:
            detail["verdict"] = "ESCALATE — do not declare error until F03 line range re-read by a human"
        audit.append(detail)
    return audit


def build_contradictions(game_root):
    """Both donor contradictions preserved verbatim (F03 F3/F4; spec 09 §4)."""
    out = []
    gp = os.path.join(game_root, r"data\gen\globalparams.cfg")
    scr = os.path.join(game_root, CONTRADICTION_SCRIPT)
    gp_lines = open(gp, "rb").read().decode("latin-1").splitlines()
    have_script = os.path.isfile(scr)
    sc_lines = open(scr, "rb").read().decode("latin-1").splitlines() if have_script else []
    sc_blob = open(scr, "rb").read() if have_script else b""
    sc_hash = hashlib.sha256(sc_blob).hexdigest() if have_script else None

    def line_obj(path, rel, lines, one_based):
        if len(lines) >= one_based:
            return {"source": path, "source_rel": rel, "source_short": short_rel(rel),
                    "line": one_based, "text": lines[one_based - 1], "label": "O"}
        return {"source": path, "source_rel": rel, "source_short": short_rel(rel),
                "line": one_based, "text": None, "label": "UNVERIFIED"}

    out.append({
        "id": "C2", "label": "[D] donor contradiction — preserve, do not fix",
        "cfg_side": line_obj(gp, r"data\gen\globalparams.cfg", gp_lines, 9),
        "script_side": dict(
            line_obj(scr, CONTRADICTION_SCRIPT, sc_lines, 237),
            **{"sha256": sc_hash}),
        "f03_citation": "F03 §4 F3 / §9 F3; spec/09 §4",
        "port_rule": "skirmish uses 3; keep cfg literal 6 as provenance only (PORT APPROXIMATION)",
    })
    out.append({
        "id": "C3", "label": "[D] donor contradiction — preserve, do not fix",
        "cfg_side": line_obj(gp, r"data\gen\globalparams.cfg", gp_lines, 10),
        "script_side": dict(
            line_obj(scr, CONTRADICTION_SCRIPT, sc_lines, 5),
            **{"sha256": sc_hash}),
        "f03_citation": "F03 §4 F4 / §9 F4; spec/09 §4",
        "port_rule": "runtime loads tilesmooth_scripts.cfg; keep cfg path literal as provenance only",
    })
    return out


def serialize(obj):
    """Deterministic UTF-8 JSON: stable sort, no timestamps, explicit LF."""
    return (json.dumps(_scrub_donor_paths(obj), indent=2, sort_keys=True, ensure_ascii=False) + "\n").encode("utf-8")


def run_parse(game_root):
    parsed = {}
    for spec in FILE_SPECS:
        parsed[spec["key"]] = parse_file(game_root, spec)

    hash_rows = []
    for spec in FILE_SPECS:
        p = parsed[spec["key"]]
        hash_rows.append({
            "rel": spec["rel"], "source": p["source"],
            "bytes_expected": spec["bytes"], "bytes_observed": p["bytes"],
            "lines_expected": spec["lines"], "lines_observed": p["physical_lines"],
            "sha256_expected": spec["sha256"], "sha256_observed": p["sha256"],
            "sha256_match": p["sha256"] == spec["sha256"],
            "eol": p["eol"], "crlf_count": p["crlf_count"],
            "result": "PASS" if (p["sha256"] == spec["sha256"]
                                 and p["bytes"] == spec["bytes"]
                                 and p["physical_lines"] == spec["lines"]
                                 and p["eol"] == "CRLF") else "FAIL",
        })

    checks, prob_total, names = compute_evidence(parsed)
    audit = multi_pass_audit(checks, parsed)
    contradictions = build_contradictions(game_root)

    constants_doc = {
        "schema_version": SCHEMA_VERSION, "tool": TOOL_ID,
        "label": "[O] active literal; commented-out literals are UNVERIFIED in config_strings.json",
        "visual_parity_claim": NO_PARITY_CLAIM,
        "note": "PORT APPROXIMATION only. Every entry carries exact donor path + 1-based line.",
        "preserved_contradictions": contradictions,
        "constants": [c for p in parsed.values() for c in p["constants"]],
    }
    strings_doc = {
        "schema_version": SCHEMA_VERSION, "tool": TOOL_ID,
        "label": "[U] UNVERIFIED — not an active key->value constant",
        "visual_parity_claim": NO_PARITY_CLAIM,
        "note": ("Includes blank lines, comments, structural tokens, [*] assignments, "
                 "dead_kv lines. Every entry has value:null + label:UNVERIFIED."),
        "entries": [s for p in parsed.values() for s in p["strings"]],
    }
    manifest = {
        "schema_version": SCHEMA_VERSION, "tool": TOOL_ID,
        "game_root": game_root, "visual_parity_claim": NO_PARITY_CLAIM,
        "check_basis": ("observed donor facts only; F03 summary 20 vs observed 19 is "
                        "recorded as MP-1 and is NOT a pass criterion; no key invented"),
        "source_hashes": hash_rows,
        "count_checks": checks,
        "multi_pass_audit": audit,
        "preserved_contradictions": contradictions,
        "documented_exceptions": [{
            "id": "MP-1",
            "label": ("[D] documented count mismatch — F03 summary 20 vs observed 19; "
                      "F03 table lists 19"),
            "check": "C01",
            "source": r"data\gen\globalparams.cfg:2-20",
            "f03_summary_count": 20,
            "observed_count": 19,
            "passes": "structural / regex / anchored byte-regex / verbatim re-read all = 19",
            "resolution": ("--check validates against OBSERVED 19; F03 §3.1 dump and §4 "
                           "table also list 19 rows. No 20th key invented. [O]/[D]"),
        }],
        "derived": {
            "active_prob_sum": str(prob_total),
            "active_prob_line_count": len([
                1 for p in [parsed["tilesmooth_scripts"]]
                for l in p["raw_text"].splitlines()
                if not l.strip().startswith("//") and RE_PROB.match(l.strip())
            ]),
            "distinct_active_tilenames": len(set(names)),
            "mp_notes": {
                "MP-1": ("F03 summary 20 vs observed 19; F03 table lists 19 at "
                         "globalparams.cfg:2-20. Four passes (structural / regex / "
                         "anchored byte-regex / full verbatim line re-read) all give 19. "
                         "--check validates against observed 19 with this documented "
                         "exception; do not invent a 20th key. [O]/[D]"),
                "MP-2": ("'61 countries' in F03 §2 is reproduced by 61 `allowedcountries : "
                         "struct.begin` blocks; the literal token `countries : struct.begin` "
                         "occurs 79x (all active). Definitional ambiguity, not a count "
                         "error; I01 keys on allowedcountries blocks. [D]/[U]"),
            },
        },
        "summary": {
            "hash_checks_pass": sum(1 for h in hash_rows if h["result"] == "PASS"),
            "hash_checks_total": len(hash_rows),
            "count_checks_pass": sum(1 for c in checks if c["result"] == "PASS"),
            "count_checks_total": len(checks),
        },
    }
    return constants_doc, strings_doc, manifest, parsed


def determinism_check(game_root):
    a = run_parse(game_root)
    b = run_parse(game_root)
    # Only the three emitted documents; the 4th element is the in-memory
    # parse census (contains raw bytes) and is never serialised or written.
    outs = [[serialize(doc) for doc in docset[:3]] for docset in (a, b)]
    names = ["constants.json", "config_strings.json", "manifest.json"]
    result = []
    for i, name in enumerate(names):
        ha = hashlib.sha256(outs[0][i]).hexdigest()
        hb = hashlib.sha256(outs[1][i]).hexdigest()
        result.append({
            "file": name, "run1_sha256": ha, "run2_sha256": hb,
            "byte_identical": outs[0][i] == outs[1][i], "bytes": len(outs[0][i]),
        })
    return result


def arrow():
    """Use U+2192 where the console supports it, ASCII fallback otherwise."""
    enc = getattr(sys.stdout, "encoding", None) or "utf-8"
    try:
        "→".encode(enc)
        return "→"
    except (UnicodeEncodeError, LookupError):
        return "->"


def dry_run_report(constants_doc, strings_doc):
    a = arrow()
    for c in constants_doc["constants"]:
        digest = hashlib.sha256(serialize(c)).hexdigest()
        print("%s:%d %s constants.json/%s %s %s %s %s" % (
            c["source_short"], c["line"], a, c["key"], a, digest, a, c["label"]))
    for s in strings_doc["entries"]:
        digest = hashlib.sha256(serialize(s)).hexdigest()
        target = s.get("key") or s.get("structural_token") or s["category"]
        print("%s:%d %s config_strings.json/%s %s %s %s %s" % (
            s["source_short"], s["line"], a, target, a, digest, a, s["label"]))
    print("dry-run: %d constants + %d unverified lines; no files written" % (
        len(constants_doc["constants"]), len(strings_doc["entries"])))


def is_inside(path, root):
    """True if `path` equals or lies under `root` (case-insensitive Windows)."""
    p = os.path.normcase(os.path.abspath(path))
    r = os.path.normcase(os.path.abspath(root))
    try:
        return os.path.commonpath([p, r]) == r
    except ValueError:
        return False


def default_out_dir():
    """variant3d/assets/terrain_new/cfg relative to this tool's repo root."""
    tool_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(os.path.dirname(tool_dir))
    return os.path.join(repo_root, "variant3d", "assets", "terrain_new", "cfg")


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="I01 donor cfg decoder (read-only donor; dry-run default)")
    ap.add_argument("--game", default=r"C:\Games\Cossacks 3",
                    help="donor install root, read only (default: C:\\Games\\Cossacks 3)")
    ap.add_argument("--out", default=None,
                    help="output dir; writes only when given (default: variant3d/assets/terrain_new/cfg)")
    ap.add_argument("--check", action="store_true",
                    help=("verify 7 donor SHA-256 + count checks against OBSERVED donor "
                          "facts (19 global keys; F03 summary 20 is a recorded exception) "
                          "+ determinism; exit 0 only when all observed checks pass"))
    ap.add_argument("--dry-run", action="store_true",
                    help="print plan and checks, write nothing (default when --out omitted)")
    args = ap.parse_args(argv)

    game_root = os.path.abspath(args.game)
    if not os.path.isdir(game_root):
        print("ERROR: --game not a directory: %s" % game_root, file=sys.stderr)
        return 2

    out_dir = os.path.abspath(args.out) if args.out else default_out_dir()
    if is_inside(out_dir, game_root):
        print("ERROR: --out must not be inside the donor root (spec/11 §11.1): %s" % out_dir,
              file=sys.stderr)
        return 2

    write = bool(args.out) and not args.dry_run
    dry = not write

    try:
        constants_doc, strings_doc, manifest, _ = run_parse(game_root)
    except (OSError, UnicodeError) as exc:
        print("ERROR: donor read failed: %s" % exc, file=sys.stderr)
        return 2

    rc = 0
    det = None
    if args.check:
        det = determinism_check(game_root)
        manifest["determinism"] = det
    ok_hash = manifest["summary"]["hash_checks_pass"] == manifest["summary"]["hash_checks_total"]
    ok_count = manifest["summary"]["count_checks_pass"] == manifest["summary"]["count_checks_total"]
    ok_det = det is None or all(d["byte_identical"] for d in det)
    if not (ok_hash and ok_count and ok_det):
        rc = 1

    if dry:
        dry_run_report(constants_doc, strings_doc)

    print("check: hashes %s counts %s determinism %s" % (
        "PASS" if ok_hash else "FAIL", "PASS" if ok_count else "FAIL",
        "PASS" if ok_det else ("FAIL" if det is not None else "NOT RUN")))
    print("basis: %s" % manifest["check_basis"])
    for h in manifest["source_hashes"]:
        if h["result"] != "PASS":
            print("  HASH FAIL %s expected=%s observed=%s" % (
                h["rel"], h["sha256_expected"], h["sha256_observed"]))
    for c in manifest["count_checks"]:
        if c["result"] != "PASS":
            print("  COUNT FAIL %s expected=%s observed=%s/%s/%s — %s" % (
                c["id"], c["expected"], c["pass1_structural"],
                c["pass2_regex"], c["pass3_bytes"], c["note"]))
    for exc in manifest["documented_exceptions"]:
        print("  NOTE %s %s (source %s; %s)" % (
            exc["id"], exc["label"], exc["source"], exc["resolution"]))
    if det is not None:
        for d in det:
            print("  determinism %s run1=%s run2=%s (%d bytes)" % (
                "PASS" if d["byte_identical"] else "FAIL",
                d["run1_sha256"], d["run2_sha256"], d["bytes"]))
    print("summary: %d/%d hashes, %d/%d count checks" % (
        manifest["summary"]["hash_checks_pass"], manifest["summary"]["hash_checks_total"],
        manifest["summary"]["count_checks_pass"], manifest["summary"]["count_checks_total"]))

    if dry:
        print("dry-run: no files written (pass --out to write)")
        return rc

    payloads = {
        "constants.json": serialize(constants_doc),
        "config_strings.json": serialize(strings_doc),
        "manifest.json": serialize(manifest),
    }
    os.makedirs(out_dir, exist_ok=True)
    for name, blob in sorted(payloads.items()):
        dest = os.path.join(out_dir, name)
        with open(dest, "wb") as fh:
            fh.write(blob)
        print("wrote %s (%d bytes, sha256=%s)" % (
            dest, len(blob), hashlib.sha256(blob).hexdigest()))
    return rc


if __name__ == "__main__":
    sys.exit(main())
