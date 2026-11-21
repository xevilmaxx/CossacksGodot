#!/usr/bin/env python3
"""Normalize per-action horizontal anchor to the idle action (run after bake).
Per-action ortho/centre keeps world scale exact, but anchoring every action at
its own union centre shifts bodies opposite to weapon swings (attack unions
extend 2 m forward -> body drawn 1 m back = visible pop at transitions).
Idle cx keeps the torso fixed while weapons sweep (donor-like). Feet stay
per-action (lunges/crouches plant correctly). Idempotent."""
import json
IDX = r"C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\app\assets\models\anim\index.json"
idx = json.load(open(IDX, encoding="utf-8"))
n = 0
for key, info in idx.items():
    acts = info.get("actions", {})
    ref = (acts.get("idle") or acts.get("walk") or {})
    if "cx" not in ref:
        continue
    for act, ad in acts.items():
        if "cx" in ad and ad["cx"] != ref["cx"]:
            ad["cx"] = ref["cx"]
            n += 1
json.dump(idx, open(IDX, "w", encoding="utf-8"), indent=1)
print("normalized cx for", n, "actions")
