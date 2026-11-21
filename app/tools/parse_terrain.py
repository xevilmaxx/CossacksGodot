#!/usr/bin/env python3
"""Print a slice of the donor's generator include (read-only diagnostic).

Source comes from $COSSACKS3_DIR or C:/Games/Cossacks 3; no OS-specific calls.
"""
import os
from pathlib import Path

GAME = Path(os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")).expanduser()
SRC = GAME / "data" / "scripts" / "common.inc" / "generatemap.inc"
t = SRC.read_text(encoding="utf-8", errors="replace")
print(t[35000:37200])
