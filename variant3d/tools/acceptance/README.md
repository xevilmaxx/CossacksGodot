# Acceptance tools: video / snapshot path

Owner-runnable, deterministic harness for the **visual acceptance path**.
Unit-test gates are **not** acceptance. These tools only capture, arrange and
measure frames; a human still has to look at the evidence and decide.

## Honesty contract (read first)

* `parity=UNVERIFIED` is printed by `capture_sequence.py` and **always** by
  `compare_frames.py`. No metric (MAE, RMSE, correlation, histogram overlap,
  SSIM, a visual contact sheet) constitutes donor parity on its own.
* `compare_frames.py --assert-ab-verified "reason"` does **not** change the
  verdict. It only writes `claim=owner-supplied` into the JSON report: it is a
  human assertion that an A/B pair was chosen correctly, not a tool-verified
  donor identity or a PASS.
* Nothing here executes the donor game or extracts new donor imagery. Donor
  frames are existing local files; the tools never synthesise pixels.
* Every Godot launch goes through `variant3d/tools/godot_runner.py run`
  (global FIFO ticket, hard timeout, isolated spool). This harness submits
  jobs strictly one at a time and takes an exclusive lock so two harness
  instances cannot race. Never start Godot directly.

## Files (all new, no existing repo files modified)

| File | Role |
| --- | --- |
| `capture_sequence.py` | Serial Godot capture -> `manifest.json` with exact argv, resolution, per-frame hashes |
| `contact_sheet.py` | Labelled, pixel-preserving tile sheet; optional explicitly-labelled rescale |
| `compare_frames.py` | Exact ROI metrics + difference image; refuses missing provenance |
| `imgio.py` | Pillow-backed PNG I/O with a documented stdlib-only fallback |

## Donor evidence and capture locations

* Donor video id: **`cZW0AEupCaI`**.
* Local donor frames (pre-existing, owner-provided):
  `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\`
  (PowerShell: `$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\`).
  Frames are named `t_0.png`, `t_60.png`, `t_600.png`, ... — the suffix is the
  donor time label, not a port frame index.
* Port captures: `inbox/qa/captures/`. Use a **fresh subdirectory per run**;
  the harness refuses to overwrite `frame_*.png` from an earlier capture.
* Selection of which donor frame corresponds to which port frame/camera/ROI
  is a **human decision**. Record it in `--roi-source` and keep the manifest.

## 1. Capture (PowerShell, from repo root)

```powershell
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 60 --step 1 --label abrun `
  --view wide=variant3d/config_donor_capture.json `
  --view zoom=$env:TEMP\ab_zoom_config.json `
  --out inbox/qa/captures/abrun_20261113
```

* `--seed` must be an integer (or the literal `random`, which is recorded as
  `deterministic=false`). `--frames` is 1..600; `--step` is 0.25..30 sim
  seconds. The engine's sequence mode takes `--seq-seconds = frames * step`
  (recorded verbatim in the manifest). The engine may stop early on a winner;
  the manifest records `complete=false` and `seq_index.json` in that case, and
  the harness exits non-zero.
* `--view NAME=CONFIG.json` is a camera/preset: the engine has **no**
  `--camera` or `--preset` flag, so the harness passes the config file as an
  absolute `--config` argument and records its SHA-256. Camera zoom/pitch and
  preset-like `gameplay.*` settings live in that config file. `--view NAME`
  (no `=`) means "engine default, uncontrolled" and is labelled as such.
  `variant3d/config_donor_capture.json` is a usable starting template; copy it
  to a temp file, change `camera.start_zoom` / `camera.pitch_degrees` etc., and
  pass the copy so the repo config is unchanged.
* Default is a **windowed** real viewport capture (`--seq` +
  `frame_post_draw`). `--headless` captures a CPU map timelapse instead, **not**
  viewport frames; the manifest states which semantics were used. Do not
  compare a headless map image to a donor gameplay frame.
* The manifest records: exact `command_line_text` (Windows copy-paste form)
  and argv, resolved config path/hash, requested resolution from the config,
  observed resolution from the PNG header, runner ticket/status/stdout path,
  and for every frame `sha256_file` + `sha256_pixels` + width/height.
* If a lock or a stale capture directory blocks a run, inspect
  `.capture.lock` / `manifest.json` first; do not delete real captures to
  force a rerun.

## 2. Contact sheet (no rescale by default)

```powershell
python variant3d/tools/acceptance/contact_sheet.py `
  --manifest inbox/qa/captures/abrun_20261113/manifest.json `
  --out inbox/qa/captures/abrun_20261113/contact.png --cols 4 --hash-labels
```

Sources come from `--frame` (repeatable), `--dir` (with `--pattern`) and/or
`--manifest` (optionally `--view NAME`), de-duplicated and sorted. Each frame
is pasted **1:1** into its cell; labels occupy a separate band above the image,
never on top of pixels. Differently sized frames are padded, not stretched.
`--fit 320x180` rescales explicitly; the label says `RESCALED ... <- ...` and
the sidecar JSON records `rescaled=true`, `exact_pixels_preserved=false` and
the filter from `--resample`. Without `--fit`, `exact_pixels_preserved=true`.

## 3. Compare one donor frame to one port frame

```powershell
python variant3d/tools/acceptance/compare_frames.py `
  --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png" `
  --port inbox/qa/captures/abrun_20261113/00_wide/frame_0060.png `
  --roi 100,100,640,360 `
  --roi-source "manual ROI: town hall and shore, donor video cZW0AEupCaI t=600" `
  --camera wide `
  --out-diff inbox/qa/captures/abrun_20261113/diff_wide.png `
  --report inbox/qa/captures/abrun_20261113/diff_wide.json
```

Refusals (exit 2, no comparison): missing `--donor`/`--port`/`--roi`, missing
`--roi-source` or `--camera`, ROI outside either frame, different frame
resolutions, or different `--config-donor`/`--config-port` hashes. There is no
rescaling, no clamping and no guessed alignment: the ROI must be the *same*
pixel box at the *same* camera on both frames.

Output: per-channel MAE/RMSE/max absolute error, differing-pixel count,
per-channel and overall Pearson pixel correlation, per-channel histogram
correlation/intersection/chi-square, plus an exact absolute-difference PNG
(`--amplify N` only brightens it and is labelled in the report). The JSON
report carries both file SHA-256 values, the ROI, the provenance and
`parity=UNVERIFIED`.

Optional human assertion:

```powershell
... --assert-ab-verified "Owner confirmed A/B pairing after viewing both full frames and the contact sheet"
```

This prints `claim=owner-supplied` and writes it to the report. The tool still
prints `parity=UNVERIFIED`; it cannot confirm that the donor file is genuine or
that the camera/ROI metadata is correct.

## Static check only

```powershell
python -m py_compile variant3d/tools/acceptance/imgio.py `
  variant3d/tools/acceptance/capture_sequence.py `
  variant3d/tools/acceptance/contact_sheet.py `
  variant3d/tools/acceptance/compare_frames.py
```

No donor execution, Godot launch, runner mutation or git operation is done by
this toolkit itself.

## Backend limitation (if Pillow is missing)

Pillow is available in this workspace (checked by import), so normal runs use
it. The stdlib fallback in `imgio.py` reads/writes **8-bit, non-interlaced PNG
only** (colour types 0/2/3/4/6, alpha composited on white, `tRNS` ignored) and
`contact_sheet.py` then uses a limited 5x7 ASCII font. `--fit` is refused
without Pillow. Frames from other formats must be converted to PNG by the
owner before comparison.
