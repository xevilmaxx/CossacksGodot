---
id: DONAVAL-02
owner: DONAVAL-02 (subagent, independent second-pass verifier)
date: 2026-11-25
area: independent verification of DONAVAL-01's seven naval corrections (donor raw-byte/path checks)
mode: "READ-ONLY second pass: fresh Python 3.14 rb/latin-1 file scans + raw struct header unpacks. Counts recomputed twice by independent enumeration methods. Prior reports' numbers NOT trusted as input."
scope: "singleplayer skirmish naval parity only — missions/campaign/network stay deferred (D-12)"
donor: "C:\\Games\\Cossacks 3 (private use; bytes + latin-1 only; never run, copied or modified)"
compliance: "no donor binary copied/executed; no code edit; no Godot/Blender job; no runner job; probe scripts only in C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\ (donaval02_*.py); ONLY this report written in the repo"
target: DONAVAL-01
verdict: "7/7 of the enumerated corrections CONFIRMED; 1 minor transcription slip found in DONAVAL-01 (IDP2 hex literal); several prior docs remain stale. NO parity claim."
labels: observed / derived / inferred / UNVERIFIED used per claim; engine-side semantics remain UNVERIFIED
---

# DONAVAL-02 — Independent second-pass verification of DONAVAL-01

## 0. Verdict up front

- All **seven** corrections enumerated in DONAVAL-01 §7 are independently **CONFIRMED** by fresh raw-byte/path checks of the donor. No correction is REFUTED.
- Every quantitative count (hull header counts, direction/death variants, crew `.oss`, skins, AAF/ACL) was recomputed **twice** with two independent enumeration methods and matched.
- One **minor transcription slip** in DONAVAL-01 was found: the `.osm` magic hex is written `0x32445049` at §2.1, but the literal raw bytes are `b'IDP2'` = `0x32504449`. The ASCII label "IDP2" is correct; only the hex digits are swapped (D/P). This does not affect any correction.
- Stale prior docs are listed in §4. **No parity claim is made** — verification of donor truth is not verification of port equivalence.

---

## 1. Sources

### 1.1 Prior documents read (input context, not trusted for counts)
| # | File | Role |
|---|---|---|
| D1 | `docs/coord_swarm_2026-11-25/reports/DONAVAL_01.md` | Target of verification; seven corrections taken from its §7 summary enumeration |
| D2 | `docs/NAVAL_EVIDENCE.md` | Q3 mesh evidence; 54-mesh/5-`.oss`/24-AAF/9-ACL scope claims |
| D3 | `docs/NAVAL_PORT_PLAN.md` | Feasibility/7-family plan; Q5 material-presence gap, speed/radius estimates |

### 1.2 Fresh donor reads (this task, read-only)
All paths relative to `C:\Games\Cossacks 3\` unless marked PORT. `python` 3.14; `open(p,'rb')` for binaries, `struct.unpack_from('<16i'/'<6i')` for headers, `latin-1` for text. Probes lived in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donaval02_{probe,text,probe3,aaf,pass2}.py` — **not in the repo**.

| Group | Paths checked | Method |
|---|---|---|
| Hull headers | `data\actors\units\<ship>.osm` × 9 | raw bytes 0–63, longs 0/6/7/8/12/13/14/15; magic bytes 0:4 |
| Direction/death variants | `<ship>1..4.osm`, `<ship>_death1/2.osm` × 9 | directory-set membership (2nd pass) |
| Crew | `data\actors\units\<ship>.oss` × 9 | `<6i>` header + SHA-256 byte-identity + directory scan |
| Skins | `data\materials\units\*.dds` | `os.path.getsize` + `DDS ` magic, two passes |
| Tiers | `data\scripts\lib\country.script:3100-3111` | latin-1 line slice |
| Radii/consts | `data\scripts\dmscript.global:168-172,610-622,626-630,664-680` | latin-1 line slice |
| AAF/ACL counts | `data\animations\aaf\*.aaf`, `data\animations\acl\*.acl` | `os.listdir` + `glob`, two passes |
| Gold stop | `data\scripts\lib\unit.script:1855-2049,8183-8212` | latin-1 line slice + `bturnoff` grep |
| Locale | `data\locale\en\units.txt:781,800-803,839,975` | latin-1 line slice |
| Convert comment | PORT `variant3d\tools\convert_models.py:275-285` | latin-1 line slice |
| Port scan | `data\scripts\lib\misc.script:4504-4562` | latin-1 line slice |
| 3 m gate / dummy | `data\scripts\units\building.inc\doprogressorders.inc:14-50,51-116,195-275` | latin-1 line slice |
| Shipyard actors | `data\actors\buildings\**\*por*.{actor,osm}` | `os.walk` + distinct-SID count |

---

## 2. Verification table — the seven corrections

Status key: **CONFIRMED** = fresh independent evidence matches; **REFUTED** = contradicts; **UNVERIFIED** = cannot be settled by raw bytes/plaintext. Each count verified twice.

| # | Correction (as enumerated in DONAVAL-01 §7) | DONAVAL-01 claim | Independent evidence (`path:offset`/header) | Verdict |
|---|---|---|---|---|
| C1 | Skin presence closed (was "frigate/galley/xebec `.dds` unconfirmed", D2/D3 Q5) | `frigate/galley/xebec.dds` = 5,592,560 B each; 10 ship-alias skins incl. `xebeca.dds` 2,796,344 B; `misflagman.dds` 349,680 B | `data\materials\units\frigate.dds`, `galley.dds`, `xebec.dds` = 5,592,560 B, magic `b'DDS '` (pass 1 + pass 2). Full set: battleship/chaika/ferry/frigate/galley/xebec 5,592,560; fishboat 1,398,256; yacht/yachttur 2,796,368; `xebeca` 2,796,344; `misflagman` 349,680 — 10 ship-alias `.dds` counted twice | **CONFIRMED** |
| C2 | Crew count scope clarified | 5 core animated `.oss` within 7 families; 6 total incl. `ferry`; battleship/xebec/chaika absent; all 217,344 B, header `(311,30,20,584,947,793)`, byte-identical | `data\actors\units\{yacht,yachttur,fishboat,frigate,galley,ferry}.oss` present = 6 (pass 1 header, pass 2 directory scan). All 217,344 B, `<6i>` = `(311,30,20,584,947,793)`; SHA-256 `936e8f5d6b483630…` identical for all 6. `battleship/xebec/chaika.oss` ABSENT. Byte length = 217,344 verified twice | **CONFIRMED** |
| C3 | AAF/ACL count scope confirmed | 30 naval AAF / 12 ACL incl. attach parts, shipyard, balloon (vs D2's 24/9 scoped subset) | `data\animations\aaf\`: 194 total files, naval subset = **30** (count1 `os.listdir` = count2 `glob` = 30). `data\animations\acl\`: 28 total, naval subset = **12** (twice). D2's 9 ACL names all present with matching sizes (battleship 1805, fishboat 1056, frigate 1796, galley 2820, shippaddle 750, shipsail 1002, xebec 1790, yacht 1790, yachttur 2828) | **CONFIRMED** |
| C4 | "Tier" reinterpreted as production gates, not texture swaps | `country.script:3100-3111` tiers fishboat 0; yacht/yachttur 1; ferry 2; galley 4; frigate/chaika/xebec 5; battleship 6; gates `<cid>+'art'`, `enablefrigate`, `enablebattleship` | `data\scripts\lib\country.script:3103-3111` read fresh: exact tier literals and access-control args as claimed; member := `commonNamePort{commonName+'por'}` at `:3101`. No texture-swap rule in these lines (engine-side binding remains UNVERIFIED) | **CONFIRMED** (as far as plaintext scope); texture-swap absence **UNVERIFIED** engine-side |
| C5 | Galley gold-stop contradiction confirmed (locale vs script) + `not … < 4` precedence UNVERIFIED | `bturnoff` set at `:1894` (yacht/yachttur) and `:1979` (frigate/xebec/battleship/chaika), **not** galley; gate literal at `:8185`; locale `units.txt:802`; precedence UNVERIFIED | `data\scripts\lib\unit.script`: `bturnoff` grep → `:1894` inside `'yacht','yachttur'` block (`:1873-1921`) and `:1979` inside `'frigate','xebec','battleship','chaika'` block (`:1959-2032`); galley block `:1922-1958` has none; `consume[gold] := 1000` at `:1946`. Gate literal `if (TObjProp(pobjprop).bturnoff) and (not gPlayer[pl].res[gc_resource_type_gold]<4) then` at `:8185`, `cantshootnogold` at `:8200`. `data\locale\en\units.txt:802` = "When out of gold, the galley stops firing." Precedence of `not … < 4` not decidable from plaintext → **UNVERIFIED**, as DONAVAL-01 states | **CONFIRMED** (contradiction real); precedence **UNVERIFIED** (unchanged) |
| C6 | Radii/speed divergence flagged | Radii px fishboat 40, ferry 70, yacht 35, yachttur 50, chaika 45, galley 80, frigate 90, xebec 80, battleship 90; metres 1.31–3.38 via `gc_pixels_to_meter=26.6666666`; speed constants 16–70, assignments commented | `data\scripts\dmscript.global:668-676` = exact px literals; `:170` `gc_pixels_to_meter = 26.6666666` (derived m: 35/26.6667=1.3125 … 90/26.6667=3.375). `:612-620` speeds fishboat 16, ferry 28, yacht 40, yachttur 70, chaika 55, galley 40, frigate 30, xebec 28, battleship 16; commented `objbase.speed := gc_obj_speed_*` at `unit.script:1857,1875,1906,1924,1961,1991,2001,2015,2035` (re-read). `gc_obj_rotatespeed_ships=2` at `:628`. Effective m/s remains **UNVERIFIED** | **CONFIRMED** (constants/divergence); effective speed **UNVERIFIED** |
| C7 | False "no shipyard/dock `.osm`" comment refuted | `convert_models.py:279-280` claim false; 15 `*por*` actor families exist, `eurpor.osm` 341,276 B | PORT `variant3d\tools\convert_models.py:279-280` literal: `no shipyard/dock .osm anywhere under data/actors; "Shipyard" … is a name only, not an actor.` Fresh `os.walk` of `data\actors\buildings`: 32 `*por*.actor` SIDs = **15 base shipyard families** (eurpor, ruspor, turpor, ukrpor, porpor, poraca, porart, porba2, porbar, porbla, porcen, pordip, porhou, porsta, portem) + attach/anim variants; 222 `.osm` with `por` in name; `commoneur\eurpor.osm` = 341,276 B | **CONFIRMED** |

### 2.1 Supplementary fresh checks (supporting the corrections, not counted among the seven)

| Check | Fresh evidence | Verdict |
|---|---|---|
| 9 hull `.osm` header counts | Raw bytes 0:4 = `b'IDP2'`; longs match DONAVAL-01 §2.1 exactly: yacht v9364/uv11490/f7731/o132,92052,277596; yachttur 2649/6545/3898/132,52492,146044; fishboat 1577/2406/1135/132,19380,46620; frigate 19008/24618/15205/132,197076,561996; galley 7522/9468/5294/132,75876,202932; battleship 17072/21650/15671/132,173332,549436; xebec 9188/9832/7550/132,78788,259988; chaika 2619/4163/3844/132,33436,125692; ferry 6912/11553/4269/132,92556,195012. File sizes match; `off14 < filesize` for all 9 (pass 1 + pass 2) | **CONFIRMED** |
| Direction/death variants | `<ship>1..4.osm` + `_death1/_death2.osm` present **7/7** for all nine ships (directory-set scan, pass 2) | **CONFIRMED** |
| 72-angle port resource scan | `data\scripts\lib\misc.script:4533` `const cPresiseCalc = 72;` `:4534` `tries := cPresiseCalc;` `:4538` `cCollisionRad = 1`; `:4527-4528` `minDist=9`, `maxDist=11`, `:4532` `minDist := minDist-6`; `:4543-4544` `GetMapCollisionTagInRadius(...) = gc_collisiontag_water`; `:4557-4561` ×1.1 bias near cardinal angles; `:4509-4518` child `bui` preferred when built | **CONFIRMED** |
| 3 m port-place gate | `data\scripts\units\building.inc\doprogressorders.inc:19` `const cMinDist = 3;`; `:23` radius query; `:33` blocks built alive ship (`gc_obj_explmedia_ship`) within `cMinDist`; `:40-41` idle blocker re-ordered via `_unit_GetRandomWaterPosition(objHnd, 4, px, pz)`; hard gate at `:202-205` | **CONFIRMED** |
| Construction dummy stages | `doprogressorders.inc:84` `var stage := floor(progress*4)`; `:87-90` `visual_stage_0..3`; `:93` `_unit_SetTagStates(shipHnd, visualtag or gc_statetag_essential_birth)`; `:60` `GetShipDummy` searches radius 2; `:107` `gc_obj_shipcontructrollangle`; `:269-270` completion spawn overridden by `_misc_GetPortResourcePoint(myHnd, px, pz, True)` | **CONFIRMED** (stage count/literals); roll-angle numeric value **UNVERIFIED** |

### 2.2 Minor discrepancy found in DONAVAL-01 (not one of the seven)

- DONAVAL-01 §2.1 states header long `[0]=0x32445049 "IDP2"`. Fresh raw bytes `b[0:4]` for all nine `.osm` files = `b'IDP2'`, i.e. little-endian int `0x32504449`. The ASCII name is correct; the written hex has D and P swapped. No correction depends on this value. **Verdict: transcription slip, substance CONFIRMED.**

---

## 3. Corrections (this pass)

1. **Hex literal correction to DONAVAL-01 §2.1:** `0x32445049` → `0x32504449` (`b'IDP2'`). Non-material to the seven corrections.
2. **No new donor correction is warranted.** All seven enumerated corrections stand as written.
3. **Scope reaffirmed:** D2's 24 AAF / 9 ACL and 54-mesh / 5-`.oss` figures are *subsets*, not totals; DONAVAL-01's 30/12 and 6-total-`.oss` are the fuller naval scope. Both can coexist; docs must label scope explicitly (see §4).
4. **UNVERIFIED set unchanged** from DONAVAL-01 §6: effective `objbase.speed` source, `not … < 4` DScript precedence, `xebeca.dds` selection rule, attach/parent transforms, DDS pixel content/visual parity, `gc_obj_shipcontructrollangle` and `gc_WaterBorderSize` values, runtime weather/wake. Nothing in this pass resolves them.

---

## 4. Prior docs that remain stale

| Doc | Stale claim(s) | Fresh truth | Action suggested (not performed) |
|---|---|---|---|
| `docs/NAVAL_EVIDENCE.md` | §2.1 "54 naval unit meshes" enumerates only 7 families; `chaika`/`ferry` hull + variant meshes exist but are unlisted. §2.2 "the other four `.oss`" = 5-core scope; `ferry.oss` (6th) not mentioned. §2.4/2.5 "24 AAF / 9 ACL" presented without scope caveat. | 9 hull families with 7/7 direction+death variants; 6 crew `.oss` total; 30 AAF / 12 ACL naval subset | Add explicit scope labels and extended-family rows; do not delete existing subset lists |
| `docs/NAVAL_PORT_PLAN.md` | §2 "Materials … verify `frigate`/`galley`/`xebec` before baking" and §5 Q5 "presence not yet confirmed" — stale, now confirmed present. §4 speed "~2–4 m/s", radius "~1.5–2 m" estimates stale vs donor radii 1.31–3.38 m and unproven effective speed. §2 family table omits `chaika`/`ferry`. | C1, C6 above | Mark Q5 closed; relabel speed/radius as port estimates pending effective-speed resolution |
| `docs/coord_swarm_2026-11-24/reports/W210_naval_assets.md` (P3) | Donor stat table needs the V6 corrections: `yachttur` shield 100 (`unit.script:1908`), `galley` shield 80 (`:1929`), `xebec` radius px80 (`:1992`), `battleship` shield 100 (`:2000`); `chaika` 25,000 hp and `ferry` 62,000 hp/transport 120 not tabulated | `unit.script:1873-2049` re-read verbatim | Patch stat table or annotate deltas |
| PORT `variant3d\tools\convert_models.py:279-280` (code comment, stale not a doc) | "no shipyard/dock `.osm` anywhere under data/actors … 'Shipyard' … is a name only, not an actor" | 15 base `*por*` actor families, 222 `*por*.osm`, `eurpor.osm` 341,276 B; `units.txt:975` "Shipyard" is a label but the actor exists | Flag for the owning port agent; **no edit made here** |
| Prior doc status still valid (not stale) | `DEC_02_scripts.md` gold-precedence UNVERIFIED marker; `DEC_03_configs.md` formations/hotkeys; `V778_ship_skins.md` "7 ships skipped as IDP2 static hulls" + no-parity label; `RD_DLC.md` D-12 deferral | Unchanged by this pass | Leave as-is |

---

## 5. Open questions

1. **UNVERIFIED — effective ship speed.** All `objbase.speed := gc_obj_speed_*` lines are commented (`unit.script:1857,1875,1906,1924,1961,1991,2001,2015,2035`, re-read). Constants are declared at `dmscript.global:612-620`; m/s conversion still needs engine-side source or ACL `TrackPointMoveStep` confirmation.
2. **UNVERIFIED — `not … < 4` precedence** at `unit.script:8185`; cannot be decided from plaintext (DEC_02 §9 Q1 unchanged).
3. **UNVERIFIED — galley locale/script contradiction** persists: `units.txt:802` vs no `bturnoff` in the galley block (`unit.script:1922-1958`).
4. **UNVERIFIED — `xebeca.dds` selection** (nation/season/capture) — only filename and size (2,796,344 B) known.
5. **UNVERIFIED — attach transforms/geometry** for sail/flag/paddle/ladder; this pass only re-confirmed file presence for hull/crew/skin/animation scope.
6. **UNVERIFIED — DDS pixels / visual parity**; only magic + byte sizes read. No A/B render performed.
7. **UNVERIFIED — `gc_obj_shipcontructrollangle`** and `gc_WaterBorderSize` numeric values; not located in the constants slices read.
8. **Scope decision still open:** `chaika`/`ferry` are readable donor ships (hull 7/7 variants, `chaika` has `.oss`? — no; `ferry.oss` yes) but the task keeps the seven-family skirmish scope; no integration decision made here.
9. **Port-read drift:** 2D `data.gd` / `world3d_entities.gd` state was not re-read in this verification; any integration ticket must re-read before wiring sids.

---

## 6. Summary

- **Seven/seven CONFIRMED.** Fresh raw-byte/path checks of the donor independently reproduce DONAVAL-01's seven corrections: skin presence (C1), crew-count scope (C2), AAF/ACL scope 30/12 (C3), tier-as-production-gates (C4), galley gold-stop contradiction with UNVERIFIED precedence (C5), radii/speed divergence (C6), and the false "no shipyard `.osm`" comment (C7).
- **Counts verified twice:** hull headers/variants, crew `.oss` (6, byte-identical), skins (10 ship-alias + `misflagman`), AAF (30), ACL (12) — each by two independent enumeration methods with matching results.
- **Supplementary confirmations:** `country.script:3100-3111` tiers; `dmscript.global` radii/speeds/scale; 72-angle port scan (`misc.script:4533`), 3 m port-place gate (`doprogressorders.inc:19`), 4-stage ship dummy (`:84-93`); 15 base shipyard actor families with `eurpor.osm` 341,276 B.
- **One minor DONAVAL-01 slip:** IDP2 hex written `0x32445049` instead of `0x32504449` — no correction affected.
- **Stale docs:** `NAVAL_EVIDENCE.md`, `NAVAL_PORT_PLAN.md`, P3 `W210_naval_assets.md`, and the `convert_models.py:279-280` comment (flagged only, not edited).
- **No parity claim.** This report verifies donor facts only; it does not assert port equivalence or that any gap is fixed. **No file other than this report was edited.**

---

*DONAVAL-02 — donor private-use read-only; probe scripts in `%TEMP%`; only `docs/coord_swarm_2026-11-25/reports/DONAVAL_02.md` written in the repo. Missions/campaign/network deferred (D-12).*
