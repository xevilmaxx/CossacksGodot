---
id: RV-CAM-01
title: "RV-CAM-01 — independent third-pass resolution of the donor camera FOV / focal / sensor conflict"
owner: RV-CAM-01 (third-pass independent donor re-verification worker)
date: 2026-11-25
status: READ_ONLY_DONOR_RECON__THIRD_PASS__ONE_REPORT_ONLY
scope: "Exactly one report file written. No code, shared file, config, asset, test, runner job or git edit. No Godot run. No donor file executed or copied."
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/latin-1 for text; raw byte-string census for cossacks.exe; never executed, unpacked or copied)"
output: docs/coord_swarm_2026-11-25/reports/RV_CAM_01_fov_resolution.md
labels: [observed, derived, inferred, UNVERIFIED]
method: "Every key claim is supported by two independent means where two exist (fresh file bytes, a second donor file, the EXE byte census, or a second arithmetic pass)."
---

# RV-CAM-01 — donor camera FOV / focal / sensor conflict

## Goal

Resolve, from donor bytes only, the conflict that blocks correct selection-rectangle and terrain
projection: our port hard-codes `FOV_DEG_ASSUMED = 17.27`, two donor-derived analyses disagree about
the donor's FOV arithmetic, and DSEL-02 proves the donor has a runtime
`GetCameraFieldOfViewByFocalLength(focallength, viewportdimension)` API. Decide whether a single
donor-grounded FOV exists for a 1280×720 port, or whether this must stay a labelled port
approximation. Also settle the follow-up question: are the camera `.inc` scripts commented-out
source (DEC-07) or live string-literal script code (DSEL-01)?

## Sources

**Required prior docs (all read first):**
`docs/coord_swarm_2026-11-25/decomp/DEC_07_cameras_shaders.md` (note: the task brief's path
`.../reports/DEC_07_...md` does not exist; the file lives under `.../decomp/`),
`docs/coord_swarm_2026-11-25/reports/DSEL_02_donor_pick_math.md`,
`docs/audit/RENDER_ARCH_CAMERA.md`,
`docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md`,
`docs/coord_swarm_2026-11-24/reports/V790_donor_camera_changes.md`,
`docs/coord_swarm_2026-11-25/reports/DSEL_01_donor_selection_rectangle.md:21-29`,
and read-only `variant3d/scripts/camera3d.gd`.

**Fresh donor text reads this session (Python bytes → latin-1, numbered lines):**
`data\cameras\{camera.cfg, default.cameras, cameradebug.cfg, camerascreenshot.cfg}` (all 4 files,
full dumps); `data\gui\menu.inc\{onresize.inc, docreate.inc, oncamera.inc, cameracontrol.inc,
dombtncameracontrol.inc, onmousedown.inc, onmousemove.inc}`; `data\gui\common.inc\{onmousewheel.inc,
onmousehook.inc}`; `data\gui\menu.cfg`; `data\gui\menu.aix`; `data\scripts\lib\control.script:574-613`;
`data\scripts\lib\misc.script:6238-6305`.

**Fresh donor whole-tree token search:** ripgrep over `C:\Games\Cossacks 3\data` (case-insensitive)
for `Focal|Sensor|DOV|FieldOfView|viewportdimension|ScreenSize|ViewWidth|ViewHeight|fov`, plus
narrow complete searches for `Sensor|FieldOfView|viewportdimension|ScreenSize|ViewWidth` and for the
two FOV API names. An independent Python byte scan (second means) enumerated **17,001 files** under
`data` and collected `focal` = 169 hits in 40 files — the same file list and lines as ripgrep (it
aborted only at console-print time on non-ASCII locale text, after collecting hits). A second
Python scan independently returned `GetCameraFieldOfViewByFocalLength` = 0,
`GetCameraFocalLengthByFieldOfView` = 0, `FieldOfView` = 0, `viewportdimension` = 0, `Sensor` = 0
(`DOV` = 60, all locale false positives such as "Gdov"), before the same console-print abort.
The complete narrow ripgrep result sets are the ones cited below.

**Fresh EXE byte census (`cossacks.exe`, 5,768,048 B = `0x580370`):** ASCII **and** UTF-16LE counts
and ±64/96-byte hex context for 23 tokens; float32 literal census for 20 candidate constants;
hex dump of API region `0x1fde00..0x1fe500` and native region `0x191080..0x191180`.

**Independent arithmetic:** two separate Python passes (`rv_cam_math.py`, `rv_cam_reconcile.py`).

## Conflict statement

1. **Our port** (`variant3d/scripts/camera3d.gd:62-65,153`) hard-codes
   `FOV_DEG_ASSUMED = 17.27` and assigns it to `Camera3D.fov`. It is already labelled a port
   assumption, citing G31 `:227,262-263`.
2. **G31 / V711 / V790** call 2.90° the "36 mm sensor" result and 17.27° the "216 mm display
   sensor" result at `f=400`.
3. **DEC-07 §8.3 correction 3** says that arithmetic is numerically wrong: 36 mm → 5.153° and
   216 mm → 30.219°; 2.90° would need 20.25 mm and 17.27° would need 121.49 mm.
4. **DSEL-02 claim 2** observes the FOV API signature but labels the numeric FOV UNVERIFIED.
5. **RENDER_ARCH_CAMERA §3** gives ≈5.2° for a 36 mm sensor.
6. **Follow-up conflict:** DEC-07 §8.1 says the camera `.inc` files are commented-out source;
   DSEL-01 `:21-29` says every `[*] = ;` line in GUI `.inc` files is live string-literal script code.

## Evidence table

Labels: **O** = observed literal byte/line; **D** = derived arithmetic/control-flow; **I** = inferred
with caveat; **U** = UNVERIFIED. "2nd means" records an independent confirmation.

| # | Claim | Label | Means A (fresh) | 2nd means | Verdict |
|---:|---|---|---|---|---|
| 1 | Main camera focal = 400, tilt = −32° in all four slots, dolly 20–58 m | O | `data\cameras\camera.cfg:44-46` `MinFocalLength=400`, `MaxFocalLength=400`, `FocalLengthPower=1.0`; `:32-35` four `−32`; `:6-10` 58/20 | `default.cameras:17,47` `FocalLength=400`; `onresize.inc:81,86,91,96,101,107,116-118` forces `focal:=400`, `angle:=−32`; `control.script:584-589` actively re-parses `camera.cfg` at runtime | CONFIRMED |
| 2 | No `Sensor`, `FieldOfView`, `viewportdimension`, `ScreenSize` or `ViewWidth` key exists anywhere in donor `data` | O (absence) | ripgrep whole `data` tree: 0 hits for those tokens in configs/scripts (only a local `viewwidth` variable at `onresize.inc:16,18,69,114`; `FieldOfView` appears only as a GUI *event name* in the EXE at `0x178cdb`) | EXE ASCII+UTF-16 census: `Sensor` 0, `sensor` 0, `ScreenSize` 0, `ViewWidth` 0; `DOV` 0 (`DepthOfView` 8, all DOF/DOV, not FOV); independent Python whole-tree scan: 0 hits for each of the four config tokens | CONFIRMED |
| 3 | FOV is computed at runtime from focal length **and** a viewport dimension | O (API exists) / U (formula) | EXE ASCII `0x1fe0e6`: `function GetCameraFieldOfViewByFocalLength(const focallength, viewportdimension : Float) : Float`; token `viewportdimension` at `0x1fe11b` | Inverse at `0x1fe158`: `function GetCameraFocalLengthByFieldOfView(const fieldofview, viewportdimension : Float) : Float`; token at `0x1fe187` | API CONFIRMED; numeric FOV and formula **UNVERIFIED** |
| 4 | No donor script calls either FOV API | O (absence) | ripgrep whole `data` tree for both exact names: 0 hits | EXE census: each name has exactly 1 ASCII hit — the declaration itself; independent Python whole-tree scan: 0 hits for both names and for `FieldOfView`/`viewportdimension` | CONFIRMED — the API is not invoked from any readable script; its shipping use (native/editor/tools) is **UNVERIFIED** |
| 5 | Bookmark `(h=49, back=78.42125)` encodes `back = h·cot(32°)` | O + D | `default.cameras:6-7` and duplicate `:36-37` | `camera.cfg:5,8` commented `//SphereHeight = 49`, `//SphereLength = 49`; `control.script:602` `offZ := ArcTan(angleZ)*height`; `misc.script:6283` identical | Ratio `78.42125/49 = 1.6004337` vs `cot 32° = 1.6003345` (0.0062 % apart); `49·cot32 = 78.41639` (Δ 0.00486 m). `ArcTan` VM semantics **UNVERIFIED** |
| 6 | Camera `.inc` files are **live string-literal code**, not comments | O | Byte structure of 9 files: envelope only `section.begin` / `Name = X` / `Code : struct.begin` / `[*] = ;<code>` ×N / `struct.end` / `section.end`. Counts: `onresize.inc` 122 prefixed lines / 6 envelope; `onmousewheel.inc` 336/5; `docreate.inc` 462/7; `oncamera.inc` 73/5; `cameracontrol.inc` 32/5; `dombtncameracontrol.inc` 56/5; `onmousedown.inc` 898/6; `onmousemove.inc` 199/6; `onmousehook.inc` 43/5 | `menu.cfg:3` `StateCreateGUI = DoCreate`, `:14` `StateOnMouseWheel = OnMouseWheel`, `:22` `StateResizeGUI = OnResize`, `:27` `StateOnGUIHookEvent = OnMouseHook`; `menu.aix:1-5` DoCreate→`menu.inc\docreate.inc`, `:36-41` OnResize→`menu.inc\onresize.inc`, `:83-88` OnMouseWheel→`common.inc\onmousewheel.inc`, `:90-95` OnMouseHook→`common.inc\onmousehook.inc`, all with `UsedFile = True`, `LanClientExecute = True` | DEC-07's claim is **WRONG**. See dedicated subsection below |
| 7 | Genuine comments *inside* the string-literal code use `//` and `{ }` | O | `onmousewheel.inc:8` `// doesnt support rotation`; `:19-28` Delphi block `{var pCamera … }`; `docreate.inc:95-96` `//SetCameraDynamicFocalLength(...)` | `onmousedown.inc` 35 `//` lines and 6 `{` lines; `onmousehook.inc:3` `//` lines and 1 `{` block | DEC-07's claim applies **only to this subset**, not to the `[*] = ;` prefix |
| 8 | Prior 2.90° / 17.27° are the 16:9 **vertical** conversions of 36 mm / 216 mm **horizontal** sensors | D (two arithmetic passes) | `36 mm → H 5.153144° → V@16:9 2.899980°`; `216 mm → H 30.219150° → V 17.271604°` | Reverse: `2.90° → H 5.153180° → sensor 36.000254 mm`; `17.27° → H 30.216430° → sensor 215.979628 mm` | DEC-07 §8.3 correction 3 is **WRONG**; the prior figures are numerically sound under the standard "sensor width = horizontal" reading |
| 9 | No sensor/gate constant present in EXE as float32 | O | `36.0` (`00001042`) count 0; `20.25` count 0; `121.4885` count 0; `1200.0` count 0 | `216.0` count 1 (`0x2fbb3`, inside an unrelated float table); `400.0` count 1 (`0x1910c5`, native `mov [ebp-0xc],400.0` default assignment); `pi/180`+`180/pi` pair at `0x4f3de0..4f3de4` = CRT math constant table | Bounds the sensor theory: no literal sensor constant to recover |
| 10 | Projection is `glFrustum`-class perspective; ortho imports exist but no data key selects them | O (imports) / I (selection) | EXE imports `glFrustum` @`0x4ffcf4`, `gluPerspective` @`0x4ff8b8`, `glOrtho` @`0x4ffbc6`, `gluOrtho2D` @`0x4ff8ca` (1 each) | G31 `:31` (prior decomp) reports default renderer switch `0 = glFrustum`; shaders use `gl_ModelViewProjectionMatrix` / `ftransform()` | Main view perspective CONFIRMED; which native switch is active at runtime **UNVERIFIED** |
| 11 | Port currently uses 17.27° unchanged | O | `variant3d/scripts/camera3d.gd:65` `FOV_DEG_ASSUMED = 17.27`; `:153` `fov = FOV_DEG_ASSUMED` | V790 `:306` probe measured `fov=17.270000`; V790 `:323` "FOV_DEG_ASSUMED = 17.27 … untouched" | CONFIRMED (port fact, not donor fact) |

### `[*] = ;` at byte level — resolving the follow-up

The literal bytes of every camera and GUI `.inc` file have this envelope (shown for `onresize.inc`,
fresh bytes, lines 1–5 and 127–129):

```
section.begin
   Name = OnResize
   UsedFileName =
   Code : struct.begin
      [*] = ;if (not gbool_gui_firstonresize) then
      ... 122 further [*] = ; lines ...
   struct.end
section.end
```

`[*] = ;` is the element marker of a `Code : struct.begin / struct.end` **string list**: each code
line is an element, and the payload is everything after the `;`. Two independent proofs that this
is live code rather than a comment convention:

1. **Byte structure:** across all 9 camera-related `.inc` files, only 5–7 non-blank lines per file
   are envelope lines (`section.begin`, `Name`, `UsedFileName`, `Code : struct.begin`,
   `struct.end`, `section.end`); 32–898 lines per file are `[*] = ;` payload lines. If `[*] = ;`
   were a comment prefix, every script would be empty — yet the same payload contains executable
   statements (`SetCameraFocalLengthInfo(...)`, `ScreenToWorldRayCast(...)`, `AddCameraInfo(...)`)
   and real in-language comments marked separately with `//` or `{ }`.
2. **Registration:** `menu.aix` maps each script name to its file with `UsedFile = True` and
   `LanClientExecute = True`, and `menu.cfg` binds the three camera-critical names as active
   state handlers (`DoCreate :3`, `OnMouseWheel :14`, `OnResize :22`, plus `OnMouseHook :27` and
   `OnMouseMove :11`).

**Verdict on the nuance:** DEC-07 §8.1 is **wrong**. DSEL-01 is right. The claim is true only for a
*subset* — the actual Delphi `//` and `{ }` comment lines embedded inside the string-literal code
(e.g. `onmousewheel.inc:19-28`, `docreate.inc:95-96`, `dombtncameracontrol.inc` one `{` block).
The file-level `[*] = ;` prefix is an encoding, not a comment. Consequence: the camera scripts are
donor-authored **intent backed by live registration** (observed), and their focal/tilt/dolly values
are donor intent, not dead text. That strengthens the *behavioural* findings but **does not supply
the numeric FOV**, because the conversion is native and no script calls the FOV API (claims 3–4).

## Arithmetic section

All numbers recomputed from first principles in two independent Python passes. Let `f = 400`
(`camera.cfg:44-45`) and assume the standard pinhole relation
`FOV = 2·atan(sensor / (2f))`; for a 16:9 viewport `V = 2·atan(tan(H/2)/1.777…)`.

### A. Sensor-width (horizontal) candidates — the interpretation that reconciles the prior docs

| Sensor (horizontal) | H-FOV from `2·atan(s/800)` | V-FOV @ 16:9 | Equivalent *vertical* sensor for that V-FOV |
|---:|---:|---:|---:|
| 36 mm | 5.153144° | **2.899980°** | 20.250000 mm |
| 216 mm | 30.219150° | **17.271604°** | 121.500000 mm |

Reverse check: `V=2.90° → H=5.153180° → sensor=36.000254 mm`;
`V=17.27° → H=30.216430° → sensor=215.979628 mm`.

**Conclusion:** 2.90° and 17.27° are *not* arithmetic errors. They are exactly the 16:9 vertical
FOVs corresponding to 36 mm and 216 mm **horizontal** sensor widths. DEC-07 obtained 5.153° and
30.219° by treating those same numbers as **vertical** sensors — a different (and non-standard)
interpretation. RENDER_ARCH_CAMERA's 5.2° is the *horizontal* FOV for 36 mm, not the vertical one;
it and G31's 2.90° are two views of the same lens assumption.

### B. Other plausible "sensor" substitutions at `f = 400`

| Assumption | FOV it produces | Role |
|---|---:|---|
| 36 mm as *vertical* sensor | 5.153° | DEC-07 / RENDER_ARCH number; H-FOV of row A's 36 mm case |
| 216 mm as *vertical* sensor | 30.219° | DEC-07 number; H-FOV of row A's 216 mm case |
| Pixel-focal 400 over **1280 px** width | H 115.989°, V 83.974° | if `viewportdimension` were raw width in pixels |
| Pixel-focal 400 over **1920 px** width | H 134.760°, V ≈ 106.94° | same interpretation at 1080p width |
| Pixel-focal 400 over **720 px** height | V 83.974° | equivalent to the 1280 px H case at 16:9 |
| `DOV = 1200` as the dimension | 112.620° | DepthOfView is a DOF/fog distance (`default.cameras:18`, `docreate.inc:86`), not a sensor |
| `DOV/2 = 600` as the dimension | 73.740° | equally unsupported |

The pixel-focal and DOV readings produce 74°–135° FOVs — incompatible with the strongly
axonometric look described by RENDER_ARCH_CAMERA §3 and G31 §6. **Inferred**, not donor-grounded.

### C. Consistency with the bookmark `(h=49, back=78.42125)`, tilt 32°

Pose check (independent of FOV):
`back/h = 78.42125/49 = 1.6004337`; `cot(32°) = 1.6003345`; `49·cot32 = 78.41639`
(Δ 0.00486 m). Eye→focus distance `= √(49²+78.42125²) = 92.4710 m = 49/sin32°` (to 0.005 %).
This validates **tilt and pose**, and it validates them identically for *every* FOV candidate.

Ground footprint implied at that bookmark pose (using
`depth ≈ 2·s·tan(V/2)/sin32°`, `width ≈ 2·s·tan(H/2)`, `s = 92.4710 m`; **derived/inferred**,
flat-ground approximation):

| V-FOV | H-FOV @16:9 | Ground depth | Ground width |
|---:|---:|---:|---:|
| 2.900° | 5.153° | 8.83 m | 8.32 m |
| 5.153° | 9.148° | 15.70 m | 14.79 m |
| 17.271° | 30.216° | 53.00 m | 49.93 m |
| 30.219° | 51.282° | 94.23 m | 88.77 m |
| 83.974° | 115.99° | 314.08 m | 295.88 m |

**The bookmark cannot discriminate FOV.** It constrains camera pose, not projection; `FocalLength =
400` is a separate key on a different line (`default.cameras:17,47`). Any of the above V-FOVs is
geometrically consistent with `(h=49, back=78.42125)` and tilt 32°. Plausibility of the 17.27° row
for an RTS view is **inferred**, not donor truth.

### D. EXE bound on the conversion

The native body is not recoverable from strings. The string block `0x1fde00..0x1fe385` is a registry
of script-VM declarations only; native x86 begins at `0x1fe385` (`55 8b ec …`). Near the FOV
declaration:

```
001fe0e0  63 74 69 6f 6e 20 47 65 74 43 61 6d   ction GetCam
001fe0f0  65 72 61 46 69 65 6c 64 4f 66 56 69   eraFieldOfVi
001fe100  65 77 42 79 46 6f 63 61 6c 4c 65 6e   ewByFocalLen
001fe110  67 74 68 28 63 6f 6e 73 74 20 66 6f   gth(const fo
001fe120  63 61 6c 6c 65 6e 67 74 68 2c 20 76   callength, v
001fe130  69 65 77 70 6f 72 74 64 69 6d 65 6e   iewportdimen
001fe140  73 69 6f 6e 20 3a 20 46 6c 6f 61 74   sion : Float
```

Float censuses: `36.0`, `20.25`, `121.4885`, `1200.0`, `sin32`, `cot32`, `49.0`, `78.42125` are all
**absent** as float32 literals; `400.0` occurs once at `0x1910c5` in a native default-assignment
sequence (`c7 45 f4 00 00 c8 43` = `mov [ebp-0xc],400.0`), which is consistent with focal
initialisation but is not a FOV formula. This bounds the search: **no stored sensor constant exists
to read**.

## Verdict

**(b) CONFIRMED_UNVERIFIED.** There is no donor-grounded FOV value for our 1280×720 port.

What is missing, precisely:

1. **The native conversion body** — how the engine turns `focallength` (+ viewport dimension) into a
   projection matrix / FOV. The API declaration is observed (`0x1fe0e6`, inverse `0x1fe158`); its
   implementation is native and not present in any readable text or string.
2. **The runtime `viewportdimension` value and call site** — no donor script calls either FOV API
   (whole-tree search = 0 hits), so we cannot even establish that the shipping main camera uses it
   rather than a separate native `glFrustum` path. Whether it is `GetViewerWidth`, `GetViewerHeight`,
   a scene-scale-adjusted value (`onresize.inc:112,114`), or a fixed gate is **UNVERIFIED**.
3. **Any sensor / film-gate constant** — zero hits in `data`, no matching float32 in the EXE.
4. **A donor screenshot with known ground scale** for an A/B calibration — running the donor is
   forbidden in this task, so no independent scale anchor exists.

Hence the two analyses are reconciled at the *arithmetic* level (both are right under different
sensor-axis readings) but the *physical* sensor choice (36 mm vs 216 mm vs something else) is not
donor evidence. Do **not** promote any candidate to a donor fact.

### PORT APPROXIMATION recommendation

**KEEP `FOV_DEG_ASSUMED = 17.27`**, relabelled with the corrected rationale.

Rationale:
- No donor-grounded replacement exists; changing to 5.15° or 30.22° would substitute one
  unverified constant for another and would be a regression in evidence quality, not an improvement.
- 17.27° is **numerically coherent**: it is the 16:9 V-FOV of `H = 2·atan(216/800) = 30.219°`, i.e.
  a 216 mm *horizontal* sensor at `f=400`. DEC-07's "numerically wrong" label is itself wrong.
- The mis-stated 2.90° is likewise coherent (36 mm horizontal → V 2.90°); RENDER_ARCH_CAMERA's 5.2°
  is the same lens's *horizontal* FOV. There is no contradiction left to "fix".
- 17.27° is already the measured baseline (V790 probe `fov=17.270000`, selftest 29/29). Changing it
  without donor evidence would invalidate those measurements and every downstream px/m ratio.
- `camera3d.gd:62-65` already marks it "PORT ASSUMPTION — NOT a donor literal"; that label is
  correct and should stay. Only the *explanation* should be corrected (216 mm horizontal sensor @
  16:9, not "display sensor giving 17.27° directly"). No code edit is made by this task.

If a future pass obtains a donor screenshot with a measurable ground feature at a known camera
height, A/B only these two coherent candidates (V 2.90° and V 17.27°); do not treat 5.15°/30.22°
as independent V-FOV candidates.

## Corrections to prior docs

**DEC-07**
- §8.1 "all camera `.inc` control scripts are commented-out source" — **WRONG**. `[*] = ;` is a
  `Code : struct.begin` string-list element marker, not a comment; the scripts are registered and
  bound as live state handlers (`menu.cfg:3,14,22,27`; `menu.aix:1-5,36-41,83-88,90-95`).
  Superseded by DSEL-01 `:21-29` and this pass. §10 open question 4 is therefore resolved: they are
  not dead code.
- §8.1 is **partly right** only for the genuine `//` and `{ }` comment lines inside those scripts
  (`onmousewheel.inc:8,19-28`; `docreate.inc:95-96`; etc.).
- §8.3 correction 3 "FOV/sensor arithmetic in G31/V711 is numerically wrong" — **WRONG**.
  G31/V711 used horizontal sensor widths and converted to 16:9 V-FOV correctly: 36 mm → 2.90° V,
  216 mm → 17.27° V. DEC-07 treated the same widths as vertical sensors and got the H-FOVs
  (5.153°, 30.219°). Correct this correction.
- §3.4 / §8.4 (`default.cameras` is not an absolute-position bookmark) — **agree**; independently
  corroborated: `PosY=0.05298996 ≈ 0.1·sin32°`, `PosZ=0.08480835 ≈ 0.1·cos32°`.
- §3.1 49-key `camera.cfg` dump, §5.2–5.3 closed forms, §12 summary geometry — **confirmed** by
  fresh reads; only the "sensor/FOV UNVERIFIED" caveat is correct and retained.

**DSEL-02**
- Claim 2 ("numeric FOV UNVERIFIED") — **correct**, retained.
- Claim 2 wording "FOV is computed at runtime from focal and a viewport dimension" — correct as an
  *API existence* statement, but should be softened: no donor script calls the API (whole-tree 0
  hits), so the main-camera call path is **UNVERIFIED**. Do not state that the shipping camera's
  FOV is demonstrably computed by this function.
- Open question 2 ("focal→FOV conversion constant") — still open; this pass adds that no script
  call site and no float32 sensor constant exist to recover it from.
- Open question 1 (`ArcTan`) — add EXE fact: declaration `function ArcTan(const val : Float) : Float`
  exists at `0x209cc6` (1 ASCII hit); V790's "absent from the binary" is too strong. Body/semantics
  remain **UNVERIFIED**.

**RENDER_ARCH_CAMERA**
- §3 numeric note `≈ 2·atan(36/(2·400)) ≈ 5.2°` — numerically right but it is the **horizontal**
  FOV for a 36 mm sensor; the 16:9 vertical FOV is 2.90°. Label the axis explicitly.
- §2.3 "gives camera position (0, 0.05299, 0.08481)" — misreading; DEC-07 §8.4 and this pass
  agree it is a rotated `dz = 0.1` offset, not an absolute position.
- Open question 1 (exact FOV/sensor) — still open; EXE adds the FOV API declarations but no body.

**V790**
- §5 item 2 "FOV unchanged (BLOCKED); 2.90° and 17.27° are A/B assumptions" — **correct decision**;
  add that the two figures are arithmetically coherent (not the errors DEC-07 alleged), so keeping
  them is the right call.
- §2.5 / §5 item 1 "_control_GetMoveCameraToPositionOffset absent from the binary" — the helper
  body is present in active `control.script:574-613` (DEC-07 §8.2, DSEL-02 claim 16, this pass);
  `ArcTan` itself *is* declared in the EXE at `0x209cc6`. Keep "VM body UNVERIFIED".
- §3 measured `fov=17.270000` — confirmed as a port fact; no donor grounding.

## Recommended value and label for the port

| Item | Recommendation |
|---|---|
| `FOV_DEG_ASSUMED` | **Keep 17.27** (do not change; do not promote to "donor value") |
| Label | **PORT APPROXIMATION / UNVERIFIED** — "16:9 V-FOV equivalent of a 216 mm *horizontal* sensor at f=400; sensor choice is not donor-grounded" |
| Secondary candidate for any future A/B | 2.90° ("36 mm horizontal" V-FOV), clearly labelled the same way |
| Do not use as V-FOV candidates | 5.15° and 30.219° (these are the H-FOVs of the 36 mm and 216 mm cases) |
| Code action this task | None — no code edits were made; only this report was written |

## Open questions

1. Native body of `GetCameraFieldOfViewByFocalLength` / the native `glFrustum` parameter derivation — **UNVERIFIED**.
2. Runtime `viewportdimension` value, and whether the shipping main camera calls the API at all (0 script call sites) — **UNVERIFIED**.
3. Sensor / film-gate constant — absent from `data` and as float32 in EXE; a different encoding (integer, derived at runtime) is **UNVERIFIED**.
4. `ArcTan` VM body and units (degrees vs radians; cotangent-like behaviour) — declaration at `0x209cc6`, semantics **UNVERIFIED**.
5. Donor screenshot A/B with known ground scale at a known bookmark height (forbidden here) — **UNVERIFIED**.
6. Confirm the port's effective viewport is 1280×720 (16:9) so the H↔V conversion used above applies — **UNVERIFIED** from donor; stated as the task's premise.
7. How `SetCameraSceneScale((viewheight/2400)*4)` / `((viewwidth/3840)*2.5)` (`onresize.inc:111-114`) feeds the native projection — **UNVERIFIED**.
8. Whether `DepthOfView = 1200` also sets a clip/far plane that interacts with projection — `docreate.inc:86,106` sets it, but its native use is **UNVERIFIED**.

## Summary

Third-pass independent bytes settle the conflict as follows. (1) The donor main camera is focal-driven
perspective: `f=400`, tilt −32°, dolly 20–58, bookmark `(h=49, back=78.42125) = h·cot32°` — all
freshly confirmed twice. (2) **No sensor, FOV, or viewportdimension constant exists anywhere in the
donor data tree or as a float32 in the EXE**; the FOV API exists only as script-VM declarations
(`0x1fe0e6` and inverse `0x1fe158`) and is called by no script. Therefore the numeric FOV is
**CONFIRMED_UNVERIFIED** and no donor-grounded value can be given for 1280×720. (3) The apparent
arithmetic conflict is an axis misreading: 2.90° and 17.27° are the correct 16:9 **vertical** FOVs
for 36 mm and 216 mm **horizontal** sensor widths at f=400; DEC-07's 5.153°/30.219° are the
corresponding horizontal FOVs, and RENDER_ARCH_CAMERA's 5.2° is that same horizontal figure.
DEC-07's §8.3 "correction" is therefore itself wrong. (4) DEC-07's "camera `.inc` files are
commented-out" claim is **wrong**: `[*] = ;` is a string-list element marker, the files are
registered in `menu.aix` and bound in `menu.cfg`, and the only genuine comments are the `//` and
`{ }` lines inside the payload. DSEL-01 is right; this makes the camera scripts live donor intent
but still does not supply the native FOV. (5) Keep `FOV_DEG_ASSUMED = 17.27` as a labelled
PORT APPROXIMATION with corrected rationale; do not substitute another unverified number. No donor
file was executed or copied; no repo code, asset, config, test or git state was changed; exactly one
report file was written.
