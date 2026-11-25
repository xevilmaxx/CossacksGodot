---
id: DENV-02
task: "Independent verification of the FogMode / sky-label reversals (CORRECTIONS rows 28 and 52)"
date: 2026-11-25
status: DELIVERED__AUDIT_ONLY__NO_DONOR_COPY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Fresh read-only donor byte/text verification only. This report is the ONLY file written; no code/asset/config/test/git edit, no runner job, no donor file copied, unpacked or executed."
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 read_bytes + latin-1; bytes.find over raw bytes, never string indexers alone)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/DENV_02.md"
labels: "observed = literal donor bytes | derived = arithmetic/control-flow from observed | inferred = plausible reading with caveat | UNVERIFIED = not provable from readable data"
verdicts: "CONFIRMED | PARTIAL | REFUTED"
visual_parity_claim: false
corrections_md_edited: false
---

# DENV-02 — Independent verification of the FogMode / sky-label reversals

## 0. Goal

Re-check, from fresh donor reads and without trusting the prior lane's prose, the two reversals
indexed at `CORRECTIONS.md` rows **28** and **52**:

1. donor RTTI fog enum is **0-based with `fmLinear = 0`**;
2. the binary maps fog-mode byte **0 → `GL_LINEAR`**;
3. the fragment shader's `fogMode` uniform is **1-based** (`1/2/3`, `0` = off);
4. `startangle = -5` is the **horizon / pale blue** and `stopangle = 90` the **zenith / deep blue**.

No parity claim is made. Unresolved bridges are recorded, not guessed.

---

## 1. Sources and method

### 1.1 Prior documents read this session (context only, not used as authority)

| Doc | Role |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md` | origin of the reversals: §2.10 mode ambiguity, §6 C1/C4, §7 Q1 |
| `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md` | old sky labels at §4.4 lines 231–232 (the claim under test), light constants §4.3 |
| `docs/coord_swarm_2026-11-25/CORRECTIONS.md` | rows 28, 29, 52 and the row 28/52 duplicate-chain notice (line 111–115) |
| `docs/coord_swarm_2026-11-24/reports/DEEPDEC_04_fog_light_sky.md` | read only to obtain VA→file mapping and the fog-writer address to re-verify independently; its conclusions were *not* taken on trust |

### 1.2 Fresh donor reads (Python 3.14, `read_bytes()`, latin-1 for text, raw `bytes.find()` loops for the binary)

| Donor path (`C:\Games\Cossacks 3\`) | Bytes | SHA-256 prefix | Lines read |
|---|---:|---|---|
| `data\env\colors\colors.lib` | 3,496 | `5f7ea22d86e7828b` | 18–43, 68–93 (targets: `:23`, `:34-43`, `:83-92`) |
| `data\env\lights\light.cfg` | 902 | `923940d1cd5658e8` | 1–40 (full) |
| `data\env\skydome\skydome.cfg` | 1,454 | `884ab6473394561e` | 1–56 (full) |
| `data\shaders\obj\hf.pvl.smx3.frag` | 1,584 | `9a35b0d23315a773` | 28–50 (targets: `:34-46`) |
| `cossacks.exe` | 5,768,048 | `87f0f3c130b027e7` | raw byte scan + hex windows at `0xC7C3C..`, `0xD00C0..0xD01E0`, `0x184070..0x184180`, `0x1848C1..` |

All hashes match the values recorded in DENV-01 §1.3 for the shared files, so these are the same
donor bytes, freshly re-read.

**Binary offset convention.** DEEPDEC-04's `CODE VA − 0x400C00` mapping was re-derived and used:
`cossacks.exe:0xC7C3E` ↔ VA `0x4C883E` (the RTTI address it cites); `cossacks.exe:0xD00F0` ↔ VA
`0x4D0CF0`. File offsets below are **0-based**; text `path:line` values are **1-based**.

---

## 2. Verification table

| # | Claim under test | Verdict | Evidence (`path:offset`) | Note |
|---:|---|---|---|---|
| (a) | Donor RTTI `TFogMode` is 0-based, `fmLinear = 0` | **CONFIRMED** | `cossacks.exe:0xC7C3C` (VA `0x4C883C`) raw slice `03 08 54 46 6f 67 4d 6f 64 65 01 00 00 00 00 02 00 00 00 38 88 4c 00 08 66 6d 4c 69 6e 65 61 72 05 66 6d 45 78 70 06 66 6d 45 78 70 32` | `03` = tkEnumeration, `08` + `"TFogMode"` (`:0xC7C3E` = VA `0x4C883E`), suffix contains MinValue `00` / MaxValue `02` before pointer `38 88 4c 00` (VA `0x4C8838`), then Pascal shortstrings `08 "fmLinear"`, `05 "fmExp"`, `06 "fmExp2"` **in that order** → ordinals 0/1/2. Three names, no fourth. |
| (b) | Binary maps fog-mode byte 0 → `GL_LINEAR` | **CONFIRMED** | `cossacks.exe:0xD00E1` (VA `0x4D0CE1`) `8a 47 28` = `mov al,[edi+0x28]`; `:0xD00E4` `2c 01` = `sub al,1`; `:0xD00E6` `72 08` → `:0xD00F0`; `:0xD00F0` (VA `0x4D0CF0`) `68 01 26 00 00` = `push 0x2601`; `:0xD00F5` `68 65 0b 00 00` = `push 0x0B65`; `:0xD00FA` `e8 fd ef fd ff` → thunk VA `0x4AFCFC` (`glFogi`) | Direct control flow: byte 0 takes the `jb` branch and pushes `0x2601` = `GL_LINEAR` with pname `0x0B65` = `GL_FOG_MODE`. Mode 1 branch `:0xD0101` pushes `0x0800`; mode 2 branch `:0xD0122` pushes `0x0801` — see correction K3. |
| (c) | Shader `fogMode` uniform is 1-based | **CONFIRMED** | `data\shaders\obj\hf.pvl.smx3.frag:34` `if(fogMode>0)`; `:38` `if (fogMode==1) //LINEAR`; `:41` `//EXP`; `:44` `//EXP2`; `:46` `mix(...)` | `0` fails the guard → no fog; the three implemented modes are 1/2/3. This is the *opposite* numeric convention to (a). |
| (d) | `startangle=-5` = horizon / pale blue; `stopangle=90` = zenith / deep blue | **CONFIRMED** (derived) | `data\env\skydome\skydome.cfg:8` `startangle = -5`; `:9` `stopangle = 90`; `:11-14` start RGB `(0.6, 0.776470601558685, 0.992156863212585)`; `:17-20` stop RGB `(0, 0.141176477074623, 0.807843148708344)`; `:28-29` down band `-90 → -5`; `:31-40` down start **and** stop colours both the pale triple | Band continuity is decisive: the down band terminates at `-5` with the **pale** colour and the up band begins at `-5` with the **same pale** colour — so `-5` is the horizon seam; the up band's other end (`90`, straight up) is the deep blue stop colour. Numeric labels are correct; only the old prose labels were inverted. |
| (e) | `CORRECTIONS.md` row 29 — DEC-03 sky labels inverted, values correct | **CONFIRMED** | `decomp/DEC_03_configs.md:231` calls `startcolor` "pale zenith blue"; `:232` calls `stopcolor` "saturated blue at horizon"; vs `skydome.cfg:8-20` as in (d) | Row 29/52 stands. Do not swap the numbers; swap only the semantic labels. |
| (f) | `CORRECTIONS.md` row 28/52 — "donor fog is off by default (`FogMode=0`)" | **REFUTED** as an unqualified statement | `colors.lib:23,34-36` (`Fog=60,100,150,1`, `FogStart=390`, `FogEnd=490`, `FogMode=0`) + `cossacks.exe:0xD00F0` (b) | On the fixed-function path mode 0 **enables LINEAR** fog at 390–490. The statement survives *only* for the shader uniform reading in (c). Keep port `fog_mode=0`, but never write "donor fog off" flatly. |
| (g) | Active sun constants match the prior record (no reversal) | **CONFIRMED** | `light.cfg:3-6,10-13,20-23,26-30` = ambient `(0.196078434586525, 0.184313729405403, 0.129411771893501)`, diffuse `(0.811764717102051, 0.780392169952393, 0.694117665290833)`, specular `(0.278431385755539, 0.266666680574417, 0.211764708161354)`, `Position=(-0.344731152057648, 0.938701450824738, 0, 1)`, `LightStyle=lsParallel` | Re-read for context; no correction arose. `light.cfg` is loaded by `env.cfg:22` per DENV-01. |
| (h) | `colors.lib:83-92` dark-palette fog values match the prior record | **CONFIRMED** | `colors.lib:72` `Fog=64,128,255,1`; `:83` `FogStart=90`; `:84` `FogEnd=490`; `:85` `FogMode=2`; `:92` `FogExpDepthFactor=0.7` | Dark table uses mode **2**, not 0 — consistent with DENV-01 §2.5. Its meaning on the shader path would be EXP (3 on the 1-based shader) if the +1 bridge holds; bridge itself UNVERIFIED. |
| (i) | DEEPDEC-04 B3's labels `0x800=GL_EXP`, `0x801=GL_EXP2` for modes 1/2 | **PARTIAL** | `cossacks.exe:0xD0101` = `68 00 08 00 00` (`0x0800`); `:0xD0122` = `68 01 08 00 00` (`0x0801`) | The immediates are **observed**; the canonical OpenGL constants are `GL_EXP = 0x2600` and `GL_EXP2 = 0x2601`, so those labels are not supported by the raw bytes alone. No GL header/import cross-check was performed in this lane. Does **not** affect verdict (b). |

### 2.1 Config-byte provenance (why the +1 bridge is still UNVERIFIED)

Raw bytes confirm both ends exist but are **different objects**:

- `cossacks.exe:0x1848C1` (VA `0x5854C1`) `ba 40 58 58 00` = `mov edx,0x585840` (key `"FogMode"`), followed at `:0x1848D4` by `88 42 3c` = `mov [edx+0x3C],al` — the parser stores the config byte into the colour/environment record at **offset +0x3C**.
- The GL writer reads its mode byte from a different descriptor: `cossacks.exe:0xD00E1` `8a 47 28` = `mov al,[edi+0x28]`, i.e. **offset +0x28** of the fog-descriptor object.

No copy from record `+0x3C` to descriptor `+0x28` was found in this read-only pass, and no `+1` adjustment to a shader uniform was found. Consistent with DENV-01 §7 Q1 / DEEPDEC-04 "UNVERIFIED".

---

## 3. Corrections

No file outside this report was edited. The items below are **findings to be applied by the coordinator**, not edits made here.

- **K1 — row 29 (DEC-03 sky labels) re-affirmed, no change.** The value/label inversion is real; `skydome.cfg:8-20` and `:28-40` are the authority. Port constants `DONOR_SKY_HORIZON=(0.6,0.7764706,0.9921569)` / `DONOR_SKY_TOP=(0,0.1411765,0.8078431)` already use the correct mapping.
- **K2 — row 28/52 (FogMode) re-affirmed, now with direct byte evidence for mode 0.** `cossacks.exe:0xD00F0` (`push 0x2601`, pname `0x0B65`, `glFogi` thunk `0x4AFCFC`) upgrades the mode-0 mapping from disassembly report to independent raw-byte observation. Status stays **PARTIAL** solely because the config→shader `+1` bridge is UNVERIFIED.
- **K3 — new caveat for DEEPDEC-04 B3 / row 28 wording (not promoted to a new CORRECTIONS row here).** The raw immediates for modes 1 and 2 in the GL writer are `0x0800` and `0x0801`, not the canonical `GL_EXP (0x2600)` / `GL_EXP2 (0x2601)`. Recommend the coordinator re-word row 28's "maps 0/1/2 → `GL_LINEAR/GL_EXP/GL_EXP2`" to name **0 → `0x2601` (`GL_LINEAR`)** as proven and treat the 1/2 symbolic labels as **UNVERIFIED against a GL header**. This caveat does not alter the mode-0 verdict or the row 28/52 status.
- **K4 — flat "fog off by default" is REFUTED.** Refine any remaining occurrence to: "off for the shader uniform (`fogMode=0`); LINEAR 390–490 on the fixed-function path (`FogMode=0` in the 0-based enum)."

---

## 4. Open questions (UNVERIFIED — do not guess)

1. **Bridge `+1`.** Does `colors.lib` `FogMode` ever reach the shader `fogMode` uniform, and is it `enum+1`? Config byte stored at record `+0x3C` (`cossacks.exe:0x1848D4`), GL writer reads descriptor `+0x28` (`cossacks.exe:0xD00E1`); no static link found. **UNVERIFIED** — keep port fog off.
2. **GL `w` binding.** The shader depth term is `gl_TexCoord[0].w` (`hf.pvl.smx3.frag:39,42,45`); DEEPDEC-04 T14 reports the vertex-side choice `abs(z)` (ATI) vs `length()` at `def.pvl.sm.vert:37-42`, and the GL writer selects a distance mode from byte `+0x29` (`cossacks.exe:0xD0175` `8a 47 29` → pname `0x855A`, values `0x855B`/`0x855C`). The runtime wiring of that varying to GL state, and the source object supplying `gl_Fog.color/start/end`, remain **UNVERIFIED**. The `0x0800`/`0x0801` mode constants of K3 also need a GL-header/import cross-check.
3. **Donor GPU A/B.** No donor frame at a matched camera exists in the project; donor execution was forbidden in this lane and a live GL/native trace is out of scope. Rendered sky/fog parity is **UNVERIFIED**; this report makes **no visual-parity claim**.
4. **Sky/sun precedence.** `skydome.cfg:11-20` blue gradient vs `light.ref:61-94` all-black sky duplicates, and `FocalLength=1` (`skydome.cfg:52`) vs `50` (`light.ref:107`) — precedence **UNVERIFIED**. This does not change verdict (d), which is about `skydome.cfg`'s own internal semantics.
5. **Fixed-function vs shader path selection at runtime.** `shaders.lib` registers `srFogMode` and DEEPDEC-04 T14 reports `fogMode=true` for Heightfield/Default materials, but which path actually renders a given surface, and whether both are active simultaneously, is **UNVERIFIED**.
6. **Dark-palette mode 2** (`colors.lib:85`) would be shader mode 3 (EXP2) only if the bridge in Q1 holds; otherwise its shader meaning is unknown. **UNVERIFIED**.

---

## 5. Summary

All four requested claims were re-verified from fresh donor bytes:

- **(a) CONFIRMED** — `TFogMode` RTTI at `cossacks.exe:0xC7C3C` is 0-based (`fmLinear=0`, `fmExp=1`, `fmExp2=2`).
- **(b) CONFIRMED** — `cossacks.exe:0xD00F0` pushes `0x2601` (`GL_LINEAR`) into `glFogi(GL_FOG_MODE=0x0B65, …)` on the byte-0 branch.
- **(c) CONFIRMED** — `hf.pvl.smx3.frag:34-46` guards with `fogMode>0` and uses 1/2/3 for LINEAR/EXP/EXP2.
- **(d) CONFIRMED** — `skydome.cfg:8-9,11-20,28-40` places the pale blue at `-5°` (horizon seam, shared by both bands) and the deep blue at `90°` (zenith).

Consequently the row 29 sky-label correction is re-affirmed, the row 28/52 fog reversal is re-affirmed (flat "donor fog off" is refuted), and one new caveat is raised about the symbolic labels for modes 1/2 in DEEPDEC-04 B3 (`0x0800`/`0x0801` in raw bytes). The `+1` bridge, GL `w` binding and donor GPU A/B all remain **UNVERIFIED**. No parity claim is made, and this report is the sole file written.

*End of DENV-02.*
