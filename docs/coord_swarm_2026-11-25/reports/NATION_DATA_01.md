---
id: NATION-DATA-01
owner: NATION-DATA-01 subagent (read-only planning worker)
date: 2026-11-25
status: complete — PLAN ONLY
scope: "Read-only planning. Sole output is this report. No code edit, no runner job, no donor copy, no Godot invocation, no board mutation."
output: "docs/coord_swarm_2026-11-25/reports/NATION_DATA_01.md"
owner_file_for_fix: "variant3d/scripts/data.gd — const NATION_UNITS block at :294-305 (DO NOT touch MORALE-02 banners)"
donor_root: "C:\\Games\\Cossacks 3 (READ-ONLY; plaintext bytes/latin-1 via python 3.14)"
labels: observed | derived | inferred | UNVERIFIED
label_key: "observed = literal bytes read this pass | derived = arithmetic / control-flow over observed | inferred = strong but indirect | UNVERIFIED = no plaintext evidence in the read set"
parity_claim: none
---

# NATION-DATA-01 — donor-grounded `NATION_UNITS` plan for Russia and Bavaria

## 1. Sources

| Tag | Source | Read | What it supplies |
|---|---|---|---|
| **P** | `variant3d/scripts/data.gd` | direct, this pass | `PLAYER_NATIONS` `:208`; `NATIONS` `:278-290`; **`NATION_UNITS` `:294-305`** (`rus` at `:295`; **no `bav` key** at `:296-304`); `resolve_sid()` `:1564-1567`; `UNITS_BASE` 62 keys `:637-1302`; `BUILDINGS_BASE` 19 keys `:1303-1358` (train lists `:1310,:1313,:1316,:1319,:1357`); `BATTLE_ARMY` `:1561`. MORALE-02 banners/marker `:81-132` and `:588-602`, marker `:132` — read only. |
| **F** | `reports/NATION_FLOW_01.md` | direct | Hop 7 `:64` — `rus` resolves to `strelet`/`cossackdon`/`pope`, `bav` keeps generic sids because `NATION_UNITS` has no `bav` key; drop-point D2 `:97-102`; mesh keyed by `sid` only D1 `:90-95`; owning files `:167-172`; OBJ count 172 / GLB 0 `:82-83`. |
| **D** | `reports/DUNIT_01_unit_roster.md` | direct | Donor per-nation uniques `rus` `:249`, `bav` `:254`; donor stat cites for `strelet` `:289`, etc.; model/manifest parity `:325-329`. **Port facts there are SECONDARY and stale in places** (see §6 corrections). |
| **C** | `C:\Games\Cossacks 3\data\scripts\lib\country.script` | direct, READ-ONLY, this pass | First-hand nation membership: `:2655-2662` peasants, `:2667` `pikemanrus`, `:2690` `pikeman18`, `:2693` `strelet`, `:2700` `musketeer`, `:2707` `musketeer18`, `:2710` `musketeer18bav`, `:2720` `grenadier`, `:2722` `grenadierbav`, `:2726` `officerrus`, `:2728` `officer`, `:2731` `drummerrus`, `:2733` `drummer`, `:2736` `officer18`, `:2739` `drummer18`, `:2741` `pope`, `:2743` `priest`, `:2754` `hussar`, `:2763` `hetman`, `:2767` `cossackdon`, `:2768` `vityaz`, `:2773` `reiter`, `:2775` `cuirassier`, `:2778` `dragoon`, `:2784` `dragoon18`, `:2795-2812` ships, `:2823-2833` buildings, `:2860-2886` common/national buildings, `:2893-2894` `chaika`. |
| **M** | `variant3d/assets/models/manifest.json` | direct | Baked donor source path per sid; lines named per row in §3. |
| **OBJ** | `variant3d/assets/models/obj/**/*.obj` | direct enumeration, this pass | **172 `.obj` at first enumeration, 280 at final re-check**, zero `.glb`, **0 nation-prefixed stems in both** (new files are building variants such as `aca1`/`cen1`). Asset existence is a literal `Test-Path` result, not inherited from a report. |
| **A** | `variant3d/scripts/ai.gd` | direct | AI orders the GENERIC sid and resolves via `Data.resolve_sid()` at `:696-734`; hence any new mapping changes AI army picks. |
| **G** | `variant3d/scripts/game.gd` | direct | `train_unit()` `:3973-3987` resolves with player nation. |
| **V** | `variant3d/scripts/world3d_entities.gd` | direct | NATION-MODEL-01 probe now present: `_nation_of()` `:653-671`, `_nation_mesh_on_disk()` `:676-680`, `_entity_mesh_sid()` `:695-739` (calls `Data.resolve_sid()` at `:713`, probes `<nat>_<sid>` at `:716,:726`), `_record_nation_mesh()` `:742-747`. |
| **R** | `reports/MORALE_02.md`, `RUN_GUIDE.md` | direct | MORALE-02 scope/byte claims `:44-60`; runner gates `RUN_GUIDE.md:35-55`; current selftest red 28/29 (`build`) `:143`. |
| **B** | `reports/NATION_DONOR_01.md` | **LANDED during this pass — DELIVERED** | At first read it was absent (`SWARM_BOARD.md:295`, `OWNER_FAULTS.md:11,36,53`); a later re-read finds `status: DELIVERED` at `:6`. Its gap table `:181-192`, corrections `:204-211` and summary `:235-254` corroborate this report's §3B/§3D/§3F and §6. |

**Method.** Donor plaintext was opened as bytes and decoded latin-1 (python 3.14); no donor binary was run or copied. All "asset exists" verdicts are a literal `Test-Path` enumeration of `variant3d/assets/models/obj/`, not an inference from older reports. The tree changed while this pass was running (172 → 280 OBJs, 0 nation-prefixed at both counts); §3 verdicts were re-checked at the end. `NATION_DONOR_01.md` landed mid-pass and was re-read; its findings are reconciled in §6. **No parity (donor-faithful or visual) is claimed anywhere in this report.**

---

## 2. What `NATION_UNITS` actually does (scope boundary)

`resolve_sid()` (`P:1564-1567`) maps a **generic train-list sid → a nation sid**, and *falls back to the generic sid* unless the target is present in `UNITS` (`P:1555`). Therefore a proposed target must satisfy **two independent conditions** to be usable:

1. a `UNITS_BASE` row (`P:637-1302`) — for `resolve_sid()` to accept it; **and**
2. an `obj/<sid>.obj` asset — for the 3D mesh branch, confirmed both by the historical sid-only path (`F:66`, `F:82-83`) and by the current nation probe's on-disk check (`V:676-680`, `V:730-735`).

A donor sid that fails either condition is **blocked / UNVERIFIED**, regardless of how correct it is in the donor. This is why the plan below is deliberately small.

`NATION_UNITS` covers **units only**. Buildings and ships have no nation key in `data.gd`; they resolve by bare `sid` (`F:65-68`). Nation-prefixed building sids and ship families are documented in §3E/§3F but **no building or ship mapping is proposed**.

---

## 3. Existing-art table (enumerated, not guessed)

Legend: `OBJ ✓` = file present under `variant3d/assets/models/obj/`; `UB` = `UNITS_BASE` key and line; `M:` = manifest row; `C:` = donor `country.script` line. Verdicts are about **port asset availability**, not donor fidelity.

### 3A. Russia — donor nation sids WITH port assets (usable as mapping targets)

| Donor sid (role) | Donor cite | Port `UNITS_BASE` | OBJ | Manifest | Label |
|---|---|---|---|---|---|
| `strelet` (17c shooter) | **C:2693**, U:931-940 (via `D:289`) | `strelet@823` | ✓ | `M:2361` | observed |
| `cossackdon` (heavy cav) | **C:2767**, U:1480-1488 | `cossackdon@1059` | ✓ | `M:2836` | observed |
| `pope` (priest) | **C:2741**, U:1151-1189 | `pope@1010` | ✓ | `M:2741` | observed |
| `vityaz` (heavy cav, reitar role) | **C:2768**, U:1489-1496 | `vityaz@955` | ✓ | `M:2627` | observed |

All four already appear in or are reachable from the current `rus` row (`P:295`) except `vityaz` — see §4B for why it is deferred.

### 3B. Russia — donor nation sids with NO port asset (must stay UNVERIFIED)

| Donor sid (role) | Donor cite | OBJ | `UNITS_BASE` | Verdict | Label |
|---|---|---|---|---|---|
| `pearus` (peasant/Serf) | **C:2657** | ✗ | ✗ | blocked — no port sid | observed (absence) |
| `pikemanrus` (Spearman) | **C:2667** | ✗ | ✗ | blocked | observed (absence) |
| `officerrus` (Commander) | **C:2726** | ✗ | ✗ | blocked; generic `officer@704`/`M:138` only | observed (absence) |
| `drummerrus` | **C:2731** | ✗ | ✗ | blocked; generic `drummer@743`/`M:2228` only | observed (absence) |
| `musketeer18` (18c shooter) | **C:2707** | ✗ (no `musketeer18.obj`) | ✗; port sid is `musk18@774` | renamed in port, **not** byte-identical — UNVERIFIED as exact sid | observed + derived |
| `dragoon18` | **C:2784** | ✗ | ✗; port has `dragoon@694`, `dragoon17@842` | no exact port sid | observed (absence) |

`hetman` is **excluded from Russia**: donor assigns it to Ukraine only (`C:1982`, `C:2760-2764`). Port has `hetman@964`/`OBJ ✓`/`M:2646`, but it is not a Russian donor sid — see §6 correction C1.

### 3C. Bavaria — donor nation sids WITH port assets (usable as mapping targets)

| Donor sid (role) | Donor cite | Port `UNITS_BASE` | OBJ | Manifest | Label |
|---|---|---|---|---|---|
| `musketeer` (17c shooter) | **C:2700** (bav in the generic list) | `musketeer@813` | ✓ | `M:2342` | observed |
| `hussar` (light cav) | **C:2754** (bav in the generic list) | `hussar@852` | ✓ | `M:385` | observed |
| `pikeman` / `pikeman18` (17c/18c melee) | **C:2685**, **C:2690** | `pikeman@647`, `pikeman18@833` | ✓ / ✓ | `M:24`, `M:347` | observed |
| `officer` / `officer18` | **C:2728**, **C:2736** | `officer@704`, `officer18@734` | ✓ / ✓ | `M:138`, `M:176` | observed |
| `drummer` / `drummer18` | **C:2733**, **C:2739** | `drummer@743`, `drummer18@1037` | ✓ / ✓ | `M:2228`, `M:765` | observed |
| `priest` (Catholic; **not** `pope`/`padre`) | **C:2743** (`padre` is pie-only at `C:2744`) | `priest@752` | ✓ | `M:2247` | observed |
| `reiter`, `cuirassier`, `dragoon` | **C:2773**, `C:2775`, `C:2778` | `reiter@879`, `cuirassier@870`, `dragoon@694` | ✓ / ✓ / ✓ | `M:442`, `M:423`, `M:119` | observed |

### 3D. Bavaria — donor nation sids with NO port asset (must stay UNVERIFIED)

| Donor sid (role) | Donor cite | OBJ | `UNITS_BASE` | Verdict | Label |
|---|---|---|---|---|---|
| `musketeer18bav` (18c unique shooter) | **C:2710**, U:969-976 (`D:96`) | ✗ | ✗ | **blocked** — highest-value Bavarian unique, no port asset | observed (absence) |
| `grenadierbav` (18c unique grenadier) | **C:2722**, U:1268-1277 (`D:108`) | ✗ | ✗ | **blocked** — generic `grenadier@763`/`M:2266` only | observed (absence) |
| `peaaus` (Bavarian peasant) | **C:2655** | ✗ | ✗ | blocked; generic `peasant@638`/`M:5` only | observed (absence) |
| `dragoon18` | **C:2784** | ✗ | ✗ | no exact port sid (`dragoon17@842` approximates) | observed (absence) |

### 3E. Ships — shared by both nations, no nation key exists

Donor roster (`C:2795-2812`) gives both `rus` and `bav` the same family. Port `dock` trains seven sids at `P:1357`.

| Donor sid | Cite | Port OBJ | `UNITS_BASE` | Verdict |
|---|---|---|---|---|
| `fishboat`, `yacht`, `galley`, `frigate`, `battleship` | `C:2795,2801,2797,2802,2812` | ✓ (`M:1411,1373,1449,1430,1468`) | present (`fishboat`, `yacht`, `galley`, `frigate`, `battleship`) | identity — no mapping |
| `yachttur`, `xebec` | `C:2806-2810` (tur/alg) | ✓ | present | not rus/bav |
| `ferry` | `C:2796` | ✗ | ✗ | **blocked / UNVERIFIED** (no port asset) |
| `chaika` | `C:2893-2894` (ukr only) | ✗ | ✗ | **blocked**; also corrects `D:319` (see §6 C2) |

### 3F. Buildings — nation-prefixed donor sids, none in the OBJ tree

Donor builds `csid+'cen'`, `+'hou'`, `+'bla'`, `+'sta'`, `+'tem'`, `+'aca'`, `+'dip'`, `+'bar'`, `+'art'`, `+'ba2'` (`C:2823-2833`) plus `russto`/`russwa`/`russga` (`C:2840,2882-2886`) and the Bavarian equivalents `bavcen`, `bavbar`, … . Donor detail corroborated by `NATION_DONOR_01.md:136-140,204-211`: Russia/Ukraine share the `rus*` **common-family** building art, while Bavaria uses `eur*` (`bavpor`/`bavmil` do **not** exist). **Enumeration result: zero `rus*.obj`, `bav*.obj` or `eur*.obj` stems exist** at either count (172 or 280). Port has only generic `cen@1304`, `hou@1307`, `bar@1309`, `bar18@1312`, `sta@1318`, `bla@1320`, `aca@1322`, `dip@1315`, `art@1333`, `sto@1327`, `mil@1329`, `mar@1331`, `tow@1347`, `wal@1337`, `gat@1339`, mines, `dock@1356` — with `bar18` and `dock` themselves lacking OBJ. `tem` and `por` have no port row at all. The renderer's `<nat>_<sid>` building probe (`V:726`) therefore cannot succeed. **No building mapping is proposed; all nation-prefixed building sids stay UNVERIFIED in 3D.**

Relevant contrast (context only, not an OBJ asset): nation-prefixed **2D** sprite sheets do exist, e.g. `assets/models/anim/bav/buildings/bav_bar18.png` and `.../rus/buildings/rus_bar18.png` (78 building PNGs per nation); `rus/units/` holds 14 `rus_peasant_*` PNGs, `bav/units/` is absent. These are 2D-layer inputs and cannot satisfy the §2 OBJ condition. [observed]

---

## 4. Proposed `data.gd` table plan

### 4A. Minimal additive diff (the actual proposal)

Owner file: **`variant3d/scripts/data.gd`**, block `const NATION_UNITS := { … }` at `:294-305`.
Change: **one inserted line**, immediately after the existing `rus` row at `:295` (before `ukr` at `:296`). No other line is edited, removed or re-ordered.

```gdscript
const NATION_UNITS := {
	"rus": {"serdiuk": "strelet", "musketeer": "strelet", "cossack": "cossackdon", "dragoon": "cossackdon", "priest": "pope"},
+	"bav": {"serdiuk": "musketeer", "cossack": "hussar"},
	"ukr": {"priest": "pope"},
	…  (unchanged)
}
```

Justification for each new pair — both are donor-correct *and* satisfy both §2 conditions:

| New pair | Donor truth | Port asset | Label |
|---|---|---|---|
| `bav.serdiuk → musketeer` | Bavaria's 17c shooter is `musketeer` (**C:2700**); `serdiuk` is Ukraine-only (**C:2696**) — the port's `serdiuk` is a generic stand-in in `bar` (`P:1310`). Target `musketeer@813` + `M:2342`. | ✓ | observed (donor membership + asset), derived (role substitution) |
| `bav.cossack → hussar` | Bavaria's light cavalry is `hussar` (**C:2754**); `cossacksich` is Ukraine-only (**C:2747**) — `cossack` is the port's generic stand-in in `sta` (`P:1319`). Target `hussar@852` + `M:385`. | ✓ | observed + derived |

**Effect, stated precisely (no parity claim):** Bavarian units ordered with generic `serdiuk` / `cossack` resolve to `musketeer` / `hussar` instead of staying on the Ukrainian-family generic sids. Two consumers are affected, both read-only on their side: training (`G:3973-3987`, `A:696-734`) and the now-landed 3D nation-mesh probe, which itself calls `Data.resolve_sid()` (`V:713`) and selects the resolved stem when that OBJ exists on disk (`V:730-735`). For both proposed targets the OBJ **does** exist (`M:2342`, `M:385`), so the renderer will report `exact=true` and switch the mesh stem; this is a **sid/mesh-key change only**, not a stat change and **not** an assertion of donor-faithful or visual parity. Buildings and ships are unaffected because no prefixed 3D mesh exists (§3E/§3F; `B:184-186`).

### 4B. Explicitly NOT in the minimal set

| Candidate | Why deferred | Label |
|---|---|---|
| `rus.reiter → vityaz` | Donor-grounded (`vityaz` carries `gc_ai_unit_reitar` at **C:2768** and generic `reiter` excludes rus at **C:2773**); both assets exist (`reiter@879`, `vityaz@955`). **But** AI resolves and orders generics (`A:696-734`), so this would change Russian AI army picks and could shift deterministic selftest traces. Separate owner decision + re-baseline required. | inferred (role), deferred |
| `bav.musk18 → musketeer18bav` | Target has no OBJ and no `UNITS_BASE` row (§3D). `resolve_sid()` would reject it (`P:1567`). | UNVERIFIED — blocked |
| `bav.grenadier → grenadierbav` | Same (§3D). | UNVERIFIED — blocked |
| `bav.peasant → peaaus`, `rus.peasant → pearus` | No port assets (§3B/§3D); `peasant` is not a `NATION_UNITS` key today (`P:295-304`). | UNVERIFIED — blocked |
| identity pairs for Bavaria (`pikeman`, `musketeer`, `priest`, `drummer`, `dragoon`, `musk18`, `grenadier`, `officer`, `officer18`, `drummer18`, `reiter`, `cuirassier`) | Donor says Bavaria uses the generic sid already (§3C). Adding identity pairs is a no-op and violates "minimal". | observed |
| any building / ship pair | `NATION_UNITS` handles units only; no nation-specific port assets exist (§3E/§3F). | UNVERIFIED |

### 4C. `rus` row — unchanged

`P:295` is left **byte-identical**. Each of its five targets is donor-grounded and asset-backed: `serdiuk→strelet` (C:2693), `musketeer→strelet` (C:2693), `cossack→cossackdon` (C:2767), `priest→pope` (C:2741); `dragoon→cossackdon` is a **port approximation** (rus has no 17c `dragoon`, C:2778; it has `dragoon18`, C:2784, with no exact port sid). Changing it is out of scope for a minimal additive plan. [observed / derived]

### 4D. MORALE-02 preservation constraint

MORALE-02 added comment banners and one marker; it declares *no behaviour change* and exactly two touched files (`R:MORALE_02.md:5-6,44-53`). This plan must:

- leave every byte of `data.gd:81-132` (morale/aura/famine banners + `PORT_MORALE_FAMINE_ENABLED` at `:132`) and `:588-602` (XP banner + constants) **unchanged**;
- introduce exactly **one** added line inside `NATION_UNITS` and no other diff hunk;
- verify by **content hash / `git diff`**, not by line number: inserting at `:296` shifts the XP block from `:588-602` to `:589-603` while its bytes stay identical. A line-number-only check would produce a false positive. [derived]

---

## 5. Validation plan (PLANNED — no runner job was launched by this worker)

### 5.1 Preflight (owner/implementer, before any runner job)
1. `git diff -- variant3d/scripts/data.gd` → must show **one** added line inside `:294-305` and nothing else.
2. SHA-256 the byte ranges of the two MORALE banner regions before/after (§4D); require equal. Keep the pre-edit copy as the rollback artifact (MORALE-02 used `inbox/backup/data.gd.bak-MORALE02`, `R:58-60`).

### 5.2 Runner smoke — variant spool only, fresh unique ids (`R:RUN_GUIDE.md:35-55`)
```
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id nation-data-01-smoke --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
python variant3d\tools\godot_runner.py run --id nation-data-01-uitest --timeout 240 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
python variant3d\tools\assert_clean.py --json
```
Gate: **no new failures versus the pre-change baseline.** The tree is already red at 28/29 on the `build` step (`R:RUN_GUIDE.md:143`); that pre-existing failure is not attributable to this data-only change and must not be reported as a regression or as a pass. Never use the 2D runner or the 2D `doctor` (`R:RUN_GUIDE.md:19,55`). No `--stay`; no direct `godot` call.

### 5.3 sid-resolution probe (new read-only test script, written by the implementer — NOT by this worker)
Proposed file `variant3d/tests/t_nation_sid_probe.gd`, executed headless through the same runner with a fresh id (`--script res://tests/t_nation_sid_probe.gd`). It must call `Data.resolve_sid()` for every generic key and assert:

| Nation | generic → expected | extra assertion |
|---|---|---|
| `rus` | `serdiuk→strelet`, `musketeer→strelet`, `cossack→cossackdon`, `dragoon→cossackdon`, `priest→pope` (`P:295`) | unchanged from current |
| `bav` | `serdiuk→musketeer`, `cossack→hussar` (new, §4A) | result differs from the generic key; result is **not** any ukr-only sid (`serdiuk`, `cossacksich`, `chaika`, `peaukr`) |
| `bav` identity | `musketeer`, `priest`, `drummer`, `dragoon`, `pikeman`, `musk18`, `grenadier`, `officer`, `officer18`, `drummer18`, `reiter`, `cuirassier` | `resolve_sid("bav", s) == s` |

For **every** resolved target assert both `Data.UNITS.has(result)` (`P:1567`) and `FileAccess.file_exists("res://assets/models/obj/" + result + ".obj")`. Additionally, after one rendered frame, read `world3d_entities.stats["nation_mesh_usage"]` (`V:742-747`) and assert an `exact=true` entry for `units|bav|serdiuk->musketeer` and `units|bav|cossack->hussar` — this is the read-only proof that the §4A mapping reaches mesh selection through `V:713-735`, not only training. Dump tuples and the usage dict to a JSON artifact outside the repo (`R:RUN_GUIDE.md:139`), e.g. `%LOCALAPPDATA%\Temp\opencode\nation_data_01_probe.json`. A target that resolves but has no OBJ is a **failure**, not a pass — this is the check that would catch any future attempt to map to the blocked sids in §3B/§3D.

### 5.4 What this validation does **not** prove
It proves sid resolution, asset existence and mesh-stem selection. It does **not** prove donor-faithful geometry, animation, or visual identity; no screenshot, donor comparison or parity claim is made. `exact=true` means only "a file with that stem exists", not "that file is Bavarian-faithful". Visual verification belongs to `NATION-MODEL-01` / `CAPTURE_RECHECK` (`R:RUN_GUIDE.md:139`, `F:167-172`, `B:225-227`). [derived / UNVERIFIED]

---

## 6. Corrections to prior docs (first-hand donor read this pass)

- **C1 — `D:249` lists `hetman` as a Russian unique; donor says Ukraine-only.** `_country_AddMember(country, 'hetman', …)` sits inside `if (ukr)` at **C:2760-2764**, and the upgrade case is `if (cid=_ukr)` at **C:1982**. `D:250` also lists it under Ukraine, so the `rus` listing is the erroneous one. `vityaz@1502` and `cossackdon@1568` are the genuine `_rus` cases. [observed] — this is why §3B/§4B exclude `hetman` for Russia.
- **C2 — `D:319` says "chaika mesh exists, V7-63".** Current disk has **no `chaika.obj`**, no manifest row, and no `UNITS_BASE` key; donor restricts it to ukr (**C:2893-2894**). Treated as stale for this tree; where the earlier claim came from is **UNVERIFIED**. [observed (absence) + UNVERIFIED provenance]
- **C3 — line numbers in `D:50-54` are stale** (`NATION_UNITS` cited at `P:263-274`; current `:294-305`) because MORALE-02 added ~40 lines before them (`R:MORALE_02.md:53`). Values were re-read, not inherited. [observed]
- **C4 — `NATION_DONOR_01.md` landed mid-pass.** At first read it was absent (`SWARM_BOARD.md:295`, `OWNER_FAULTS.md:11,36,53`); a later re-read finds `status: DELIVERED` (`B:6`). It was re-read in full and reconciled: its G1 (`:181`) independently confirms the missing `bav` key, G8/G9 (`:188-189`) confirm the blocked Bavarian/Russian assets, and its C2/C3 (`:207-208`) independently confirm C1/C2 above. No conflict with §4 was found. Its building-prefix nuance (`:136-140,204-211`) is folded into §3F. [observed]

---

## 7. Open questions

1. `NATION-DONOR-01` has landed (`DELIVERED`) and does **not** assert a concrete generic→nation sid table for Bavaria beyond roster membership (`B:160,181,188`); the `serdiuk→musketeer` / `cossack→hussar` substitutions remain **derived** from donor roster roles (`C:2700`, `C:2754`) rather than explicitly confirmed by that report. If its owner later publishes a differing table, §4 must be re-checked.
2. Is the Bavarian identity set in §4B truly complete? Donor has no `bav` 17c melee/18c unique besides `musketeer18bav`/`grenadierbav`, but a full DScript scan of `unit.script` beyond `DUNIT-01`'s extraction was not repeated here. **UNVERIFIED.**
3. Accept or defer `rus.reiter → vityaz` (§4B)? The AI-pick change is real (`A:696-734`); it needs an owner decision and a seed-trace baseline, not a data-only ticket.
4. Should blocked Bavarian uniques (`musketeer18bav`, `grenadierbav`) be imported as new OBJ + `UNITS_BASE` rows in a separate asset ticket? Out of scope here; requires manifest + mesh + animation work. **UNVERIFIED.**
5. Will `NATION-MODEL-01` key 3D meshes off the resolved sid or off a nation prefix? If the latter, the 2D-only `bav_*.png` sheets (§3F) may be relevant to it, not to this data plan. **UNVERIFIED.**
6. Does `user://options.json` override `Data.PLAYER_NATIONS` on this machine (`F:182`)? Not inspected; affects which nation actually reaches `train_unit()`. **UNVERIFIED.**
7. MORALE byte verification method — content hash vs `git diff --exit-code` on the two regions — owner's choice; both are specified in §4D/§5.1.
8. No donor/visual parity claim is made; whether the resolved `musketeer`/`hussar` meshes *look* Bavarian remains **UNVERIFIED**.

---

## 8. Summary

- The current `NATION_UNITS` table is `variant3d/scripts/data.gd:294-305`; `rus` is at `:295` and **there is no `bav` key** (`F:64`, `B:181`, `P:296-304`). `resolve_sid()` accepts only targets that already have a `UNITS_BASE` row (`P:1564-1567`), and mesh selection additionally needs an `obj/<sid>.obj` (`V:730-735`).
- First-hand donor enumeration (`country.script`) plus literal OBJ enumeration (172 → 280 during the pass, 0 nation-prefixed at both counts) show that most nation-unique sids **cannot** be mapped: Russia lacks `pearus`, `pikemanrus`, `officerrus`, `drummerrus`; Bavaria lacks `musketeer18bav`, `grenadierbav`, `peaaus` (`B:188-189`); `ferry`/`chaika` and all nation-prefixed building sids have no port asset. These stay **UNVERIFIED / blocked**.
- The minimal donor-grounded additive plan is **one line**: `"bav": {"serdiuk": "musketeer", "cossack": "hussar"}`, inserted after `P:295`. Both targets are donor-correct for Bavaria (`C:2700`, `C:2754`) and exist as `UNITS_BASE` rows **and** OBJ assets (`M:2342`, `M:385`), so the renderer's nation probe (`V:713`) can select them. The `rus` row is unchanged; `vityaz` is deferred because it would change AI picks.
- MORALE-02 banners (`P:81-132`, `P:588-602`) must remain byte-identical; the only diff hunk is the one added table line. Validation is a variant-spool runner smoke plus a new sid-resolution probe that asserts `Data.UNITS.has(target)`, `obj/<target>.obj` existence, and `exact=true` in `nation_mesh_usage` (`V:742-747`).
- No code was edited, no runner job launched, no donor file modified, and no parity claim made. This report is the sole output.
