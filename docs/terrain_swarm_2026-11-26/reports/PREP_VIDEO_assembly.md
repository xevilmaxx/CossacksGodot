---
id: PREP-VIDEO-ASSEMBLY-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26
wave: DONOR-TERRAIN VISUAL WAVE
title: "PREP-VIDEO — read-only ffmpeg/ffprobe preflight and exact post-capture MP4/contact-sheet/diagnostic-frame assembly packet for COORD"
role: SECONDARY / READ-ONLY PLANNING — exactly one report; no code, Godot, git, capture or assembly
owner_file: docs/terrain_swarm_2026-11-26/reports/PREP_VIDEO_assembly.md
status: PLANNED_ONLY__TOOLS_PRESENT__CAPTURE_NOT_RUN__PARITY_UNVERIFIED
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION / port-internal evidence only. No donor GPU A/B frame exists. No command below is a capture result, no MP4 has been assembled, and nothing in this report certifies donor fidelity."
principle: "[O] literal source/read-only filesystem fact · [D] deterministic consequence · [I] protocol recommendation/heuristic · [U] unresolved. PREP-VIDEO ran no capture, no Godot process and no assembly command; only Get-Command/version probes and source reads."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/W05_video_capture.md
  - docs/terrain_swarm_2026-11-26/VISUAL_WAVE_CHARTER.md
  - variant3d/tools/seq_to_mp4.py
  - variant3d/tests/t_motion_capture.gd
---

# PREP-VIDEO — post-capture video assembly packet

## 0. Executive answer

1. **[O] Tooling is present.** `Get-Command ffmpeg` resolves to
   `C:\Users\Maxym.Oboyshev\AppData\Local\Microsoft\WinGet\Links\ffmpeg.exe`;
   `ffmpeg -version` and `ffprobe -version` both report
   `9.0.1-full_build-www.gyan.dev`. `python -c "import PIL"` reports Pillow
   12.1.1 (exit 0), so `seq_to_mp4.py` can build its contact sheet.
2. **[O] Flags verified against source, not inherited prose.**
   `seq_to_mp4.py` accepts exactly `--dir`, `--fps`, `--out`, `--contact-only`
   (`:38-43`); it encodes with `-framerate <fps> -i frame_%04d.png -c:v
   libx264 -pix_fmt yuv420p -crf 20 <out>` (`:70-72`) and writes
   `<dir>/contact.png` via Pillow (`:21-34,59-60`).
3. **[O]/[D] Two traps are confirmed from source.** (a) ffmpeg is discovered
   through `shutil.which("ffmpeg")` (`:65`) and **missing ffmpeg returns 0 while
   keeping only the contact sheet** (`:66-68`) — so exit code alone cannot prove
   an MP4; a non-empty/existence guard is mandatory. (b) The ffmpeg input
   pattern is **four-digit** `frame_%04d.png` (`:71`), matching W05 §2's
   naming trap; the packet below asserts that exact contiguous naming.
4. **[O] `seq_to_mp4.py` does not read fps from any manifest.** It only *prints*
   `seq_index.json` if present (`:53-56`); encoding fps comes solely from the
   `--fps` argument (`:40,70`). Therefore COORD must read fps from the atom's
   `capture.json` sidecar (W05 §4.2: "`--fps` … also written to sidecar") and
   pass it explicitly. The exact JSON key is **[U]** until the atom lands; §3
   probes the likely keys and fails loudly instead of guessing.
5. **[I] No capture, no assembly, no parity.** §4 is a copy-paste packet for
   COORD to run **after** `t_terrain_motion_capture.gd` emits
   `frame_%04d.png` under `%TEMP%\opencode\v42\video\donor_240` and
   `donor_64`. PREP-VIDEO executed none of it. Parity stays UNVERIFIED.

**Bottom line:** ffmpeg/ffprobe/Pillow = **YES**; a complete, fail-fast assembly
recipe = **YES** (§4); any existing donor MP4 or frame evidence = **NO**.

---

## 1. Tool availability — observed this pass

| Probe | Result | Label |
|---|---|---|
| `Get-Command ffmpeg` | `ffmpeg.exe` at WinGet Links (`…\Microsoft\WinGet\Links\ffmpeg.exe`) | [O] |
| `ffmpeg -version` (first line) | `ffmpeg version 9.0.1-full_build-www.gyan.dev` | [O] |
| `Get-Command ffprobe` | `ffprobe.exe` at WinGet Links | [O] |
| `ffprobe -version` (first line) | `ffprobe version 9.0.1-full_build-www.gyan.dev` | [O] |
| `python -c "import PIL; print(...)"` | `Pillow 12.1.1`, `python_exit=0` | [O] |
| `%TEMP%\opencode\v42\video\` | **does not exist** at this pass | [O] |

Note: `Get-Command … | Format-List Version` shows `0.0.0.0` because the WinGet
entry is a shim; the real version comes from `-version`, above. `[U]` whether a
given COORD shell's `PATH` is identical to this one — the packet re-checks both
tools and fails fast.

---

## 2. `seq_to_mp4.py` flag / behavior audit (verified from source)

| Source line(s) | Literal behavior | Consequence for the packet |
|---|---|---|
| `:39` | `--dir` required | Always pass `--dir`. |
| `:40` | `--fps` type `int`, default `10` | Pass the manifest fps as an integer; never rely on the default. |
| `:41,69` | `--out` default `""` → `<dir>/journey.mp4` | Pass an explicit absolute `--out` outside the frame dir. |
| `:42,62-63` | `--contact-only` returns 0 before ffmpeg | Usable for contact-sheet regeneration; produces no MP4. |
| `:49` | `sorted(d.glob("frame_*.png"))` | Frames are name-sorted; assert contiguous `frame_%04d.png` before assembly. |
| `:50-52` | no frames → print + return 1 | Fail-fast frame-set assertion gives a clearer error. |
| `:53-56` | `seq_index.json` is printed only, never used for fps | Do not expect the tool to pick fps from a manifest. |
| `:59-60` | contact sheet written to `<dir>/contact.png` when Pillow importable | Assert `contact.png` exists after assembly. |
| `:21-34` | `contact(..., cols=6)`, thumbs 320 px wide, dark `(10,10,10)` background | Contact sheet is a compact overview, not a review substitute. |
| `:65` | `ff = shutil.which("ffmpeg")` | PATH, not a hardcoded exe; `Get-Command ffmpeg` preflight is the right check. |
| `:66-68` | ffmpeg missing → message, **return 0**, contact sheet kept | **Exit code is not proof of MP4**; assert non-empty MP4 (§4 `Assert-Video`). |
| `:70-72` | `-y -framerate <fps> -i <dir>/frame_%04d.png -c:v libx264 -pix_fmt yuv420p -crf 20 <out>` | Exactly the requested codec/pixel-format/CRF; four-digit input pattern. |
| `:74-77` | ffmpeg non-zero → print stderr tail, return 1 | Propagate `$LASTEXITCODE` and throw. |
| `:78` | success prints `video: … N bytes` | Corroborates non-empty output, but still use `Get-Item`/ffprobe. |

**[D] Consequence:** the tool's success condition is weaker than W05 §8.1
("MP4 exists, is non-empty, has the declared frame count/duration"). The packet
in §4 adds every missing check rather than trusting `seq_to_mp4.py`'s exit code.

---

## 3. Preconditions and contract assumptions

- **[O] Input directories:** `%TEMP%\opencode\v42\video\donor_240` and
  `%TEMP%\opencode\v42\video\donor_64` (per task). They do not exist yet; the
  atom creates them. W05 §5 additionally recommends a unique batch tag to
  prevent stale frames — **`donor_240`/`donor_64` must be freshly populated**;
  the contiguous-frame assertion below is the guard against contamination.
- **[U] Manifest name/key:** W05 §4.2 specifies a `capture.json` sidecar with
  frame count and fps ("also written to sidecar") but does not fix the exact
  key spelling. The packet probes `fps`/`presentation_fps`/`capture_fps` and
  `frame_count`/`frames`/`n_frames`, fails loudly if none is valid, and lists
  the manifest keys on failure so COORD can align the atom. **No fps constant
  is assumed** — advisory expectations from W05 §4.3 (240² pans commonly 6 or
  8 fps, 64² close-up 8 fps) are *not* used as encoding values.
- **[D] Expected duration** = `frame_count / fps` exactly, because
  `-framerate <fps>` + contiguous `frame_%04d.png` yields one output frame per
  input frame. ffprobe tolerance below is ±`max(0.25 s, 1/fps)`; decoded frame
  count must match exactly.
- **[I] Output layout:** MP4s as `%TEMP%\opencode\v42\video\donor_240.mp4` and
  `donor_64.mp4`; diagnostic PNGs in `donor_240_diag\` and `donor_64_diag\`;
  SHA-256 manifest at `%TEMP%\opencode\v42\video\VIDEO_SHA256SUMS.json`. All
  outside the repo.
- **[I] Diagnostic frames:** for `N` frames, index for percentage `p` is
  `round(p/100 * (N-1))`, extracted by frame index with ffmpeg's `select`
  filter (timestamp-independent and frame-exact).

---

## 4. Copy-paste PowerShell packet — run ONLY after the atom emits frames

Prerequisites: COORD has landed `variant3d/tests/t_terrain_motion_capture.gd`
(W05 §4.2), run the W05 §5 capture packet, and confirmed the two frame
directories contain contiguous `frame_%04d.png` plus their `capture.json`.
This section performs **assembly and verification only** — it launches no Godot
process and submits no runner job.

```powershell
$ErrorActionPreference = 'Stop'
Set-Location 'C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3'

# ---- fixed outside-repo paths ------------------------------------------------
$Root  = Join-Path $env:TEMP 'opencode\v42\video'
$Tool  = 'variant3d/tools/seq_to_mp4.py'
$Shots = @(
    @{ Name = 'donor_240'; Dir = Join-Path $Root 'donor_240' },
    @{ Name = 'donor_64';  Dir = Join-Path $Root 'donor_64'  }
)
$Percents = @(0, 20, 40, 60, 80, 100)

# ---- tool fail-fast (read-only probes) --------------------------------------
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    throw 'BLOCKED: ffmpeg not on PATH; seq_to_mp4.py would return 0 with only a contact sheet.'
}
$HasProbe = [bool](Get-Command ffprobe -ErrorAction SilentlyContinue)
if (-not (Test-Path -LiteralPath $Tool)) { throw "BLOCKED: missing $Tool" }

# ---- helpers -----------------------------------------------------------------
function Read-ShotManifest {
    param([string]$Dir, [string]$Name)
    $mp = Join-Path $Dir 'capture.json'
    if (-not (Test-Path -LiteralPath $mp)) { throw "[$Name] missing manifest: $mp" }
    $m = Get-Content -LiteralPath $mp -Raw | ConvertFrom-Json

    $fps = $null
    foreach ($k in @('fps','presentation_fps','capture_fps')) {
        if ($m.PSObject.Properties.Name -contains $k -and $null -ne $m.$k) {
            $fps = [int]$m.$k; break
        }
    }
    if ($null -eq $fps -or $fps -lt 1 -or $fps -gt 240) {
        throw "[$Name] valid fps not found in capture.json (keys: $(($m.PSObject.Properties.Name) -join ',')). Align the atom's fps key before assembly."
    }

    $want = $null
    foreach ($k in @('frame_count','frames','n_frames')) {
        if ($m.PSObject.Properties.Name -contains $k -and $null -ne $m.$k) {
            $want = [int]$m.$k; break
        }
    }
    if ($null -eq $want -or $want -lt 1) {
        throw "[$Name] valid frame_count not found in capture.json (keys: $(($m.PSObject.Properties.Name) -join ','))."
    }
    return @{ Fps = $fps; WantFrames = $want }
}

function Assert-FrameSet {
    param([string]$Dir, [string]$Name, [int]$Want)
    $frames = @(Get-ChildItem -LiteralPath $Dir -File -Filter 'frame_*.png' | Sort-Object Name)
    if ($frames.Count -ne $Want) {
        throw "[$Name] frame count $($frames.Count) != manifest frame_count $Want in $Dir (stale/incomplete sequence)"
    }
    for ($i = 0; $i -lt $Want; $i++) {
        $expected = 'frame_{0:D4}.png' -f $i
        if ($frames[$i].Name -ne $expected) {
            throw "[$Name] non-contiguous sequence at index ${i}: '$($frames[$i].Name)' != '$expected' (seq_to_mp4.py reads frame_%04d.png)"
        }
    }
    return $frames
}

function Assert-Video {
    param([string]$Mp4, [string]$Name, [int]$WantFrames, [int]$Fps)
    $fi = Get-Item -LiteralPath $Mp4 -ErrorAction Stop
    if ($fi.Length -le 0) { throw "[$Name] MP4 is empty: $Mp4" }   # non-empty guard

    if (-not $HasProbe) {
        Write-Warning "[$Name] ffprobe absent: frame count / duration NOT verified (non-empty only)."
        return
    }
    # decoded frame count must equal the manifest frame count
    $nb = (( & ffprobe -v error -select_streams v:0 -count_frames `
              -show_entries stream=nb_read_frames `
              -of default=nokey=1:noprint_wrappers=1 $Mp4 ) -join '').Trim()
    if ([int]$nb -ne $WantFrames) { throw "[$Name] ffprobe decoded frames $nb != $WantFrames" }

    # duration must equal frame_count / fps (tolerance = one frame, min 0.25 s)
    $dur = (( & ffprobe -v error -show_entries format=duration `
               -of default=nokey=1:noprint_wrappers=1 $Mp4 ) -join '').Trim()
    $gotSec  = [double]::Parse($dur, [Globalization.CultureInfo]::InvariantCulture)
    $wantSec = [double]$WantFrames / [double]$Fps
    $tol     = [math]::Max(0.25, 1.0 / [double]$Fps)
    if ([math]::Abs($gotSec - $wantSec) -gt $tol) {
        throw "[$Name] duration ${gotSec}s != expected ${wantSec}s (tol ${tol}s)"
    }
    Write-Host "[$Name] MP4 OK: $($fi.Length) bytes, $nb frames, ${gotSec}s @ ${Fps}fps"
}

# ---- assemble / verify each shot --------------------------------------------
foreach ($s in $Shots) {
    $name = $s.Name
    $dir  = $s.Dir
    $manifest = Read-ShotManifest -Dir $dir -Name $name   # fps comes from manifest
    $fps  = $manifest.Fps
    $want = $manifest.WantFrames

    if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
        throw "[$name] frame directory missing: $dir"
    }
    $null = Assert-FrameSet -Dir $dir -Name $name -Want $want

    $mp4 = Join-Path $Root "$name.mp4"
    # seq_to_mp4.py: -y -framerate <fps> -i frame_%04d.png -c:v libx264
    #                -pix_fmt yuv420p -crf 20 <out>   (verified :70-72)
    python $Tool --dir $dir --fps $fps --out $mp4
    if ($LASTEXITCODE -ne 0) { throw "[$name] seq_to_mp4.py failed (exit $LASTEXITCODE)" }

    Assert-Video -Mp4 $mp4 -Name $name -WantFrames $want -Fps $fps

    # contact sheet is written automatically by seq_to_mp4.py (Pillow :59-60)
    $contact = Join-Path $dir 'contact.png'
    if (-not (Test-Path -LiteralPath $contact)) {
        # regenerate explicitly; --contact-only is a valid standalone step (:42,62-63)
        python $Tool --dir $dir --contact-only
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $contact)) {
            throw "[$name] contact sheet missing (Pillow installed?)"
        }
    }

    # six diagnostic frames at 0/20/40/60/80/100 percent, by exact frame index
    $diag = Join-Path $Root "${name}_diag"
    New-Item -ItemType Directory -Force -Path $diag | Out-Null
    foreach ($p in $Percents) {
        $idx = [int][math]::Round(($p / 100.0) * ($want - 1))
        $dst = Join-Path $diag ('frame_{0:d3}_p{1:d3}.png' -f $idx, $p)
        # -fps_mode passthrough keeps exactly the selected frame
        # (older builds: -vsync 0). select=eq(n\,IDX) is frame-exact.
        & ffmpeg -y -loglevel error -i $mp4 -vf "select=eq(n\,$idx)" -fps_mode passthrough -frames:v 1 $dst
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $dst)) {
            throw "[$name] diagnostic extract failed at $p% (frame $idx)"
        }
        $fi = Get-Item -LiteralPath $dst
        if ($fi.Length -le 0) { throw "[$name] empty diagnostic frame at $p%" }
    }
    Write-Host "[$name] contact sheet: $contact"
    Write-Host "[$name] diagnostics: $diag (0/20/40/60/80/100%)"
}

# ---- SHA-256 manifest (enumerate BEFORE writing, so it cannot hash itself) ---
$artifacts = @()
foreach ($s in $Shots) {
    $artifacts += Get-ChildItem -LiteralPath $s.Dir -File -Recurse |
                  Where-Object { $_.Extension -in '.png','.mp4','.json' }
    $mp4 = Join-Path $Root "$($s.Name).mp4"
    if (Test-Path -LiteralPath $mp4) { $artifacts += Get-Item -LiteralPath $mp4 }
    $diag = Join-Path $Root "$($s.Name)_diag"
    if (Test-Path -LiteralPath $diag) {
        $artifacts += Get-ChildItem -LiteralPath $diag -File -Filter '*.png'
    }
}
$hashManifest = Join-Path $Root 'VIDEO_SHA256SUMS.json'
$artifacts | Sort-Object FullName |
    ForEach-Object { Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256 } |
    ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $hashManifest -Encoding utf8
if (-not (Test-Path -LiteralPath $hashManifest)) { throw 'SHA-256 manifest not written' }
Write-Host "Assembly packet complete. SHA-256 manifest: $hashManifest"
Write-Host 'PORT APPROXIMATION only; donor parity UNVERIFIED. No capture was performed by PREP-VIDEO.'
```

### 4.1 Explicit command forms (for spot-checking, same flags)

```powershell
# Assembly (per shot) — flags verified against seq_to_mp4.py:38-43,70-72
python variant3d/tools/seq_to_mp4.py --dir "$env:TEMP\opencode\v42\video\donor_240" --fps <FPS_FROM_CAPTURE_JSON> --out "$env:TEMP\opencode\v42\video\donor_240.mp4"
python variant3d/tools/seq_to_mp4.py --dir "$env:TEMP\opencode\v42\video\donor_64"  --fps <FPS_FROM_CAPTURE_JSON> --out "$env:TEMP\opencode\v42\video\donor_64.mp4"

# Contact sheet only (standalone regeneration; no MP4 produced)
python variant3d/tools/seq_to_mp4.py --dir "$env:TEMP\opencode\v42\video\donor_240" --contact-only
python variant3d/tools/seq_to_mp4.py --dir "$env:TEMP\opencode\v42\video\donor_64"  --contact-only

# ffprobe fail-fast (per MP4): decoded frame count and duration
ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 "$env:TEMP\opencode\v42\video\donor_240.mp4"
ffprobe -v error -show_entries format=duration -of default=nokey=1:noprint_wrappers=1 "$env:TEMP\opencode\v42\video\donor_240.mp4"

# One diagnostic frame at a given index IDX (0-based, frame-exact)
ffmpeg -y -loglevel error -i "$env:TEMP\opencode\v42\video\donor_240.mp4" -vf "select=eq(n\,IDX)" -fps_mode passthrough -frames:v 1 "<diag-dir>\frame_IDX.png"

# SHA-256 manifest (enumerate before writing the manifest itself)
Get-ChildItem "$env:TEMP\opencode\v42\video" -Recurse -File |
  Where-Object { $_.Extension -in '.png','.mp4','.json' } |
  Sort-Object FullName |
  ForEach-Object { Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256 } |
  ConvertTo-Json -Depth 3 | Set-Content "$env:TEMP\opencode\v42\video\VIDEO_SHA256SUMS.json" -Encoding utf8
```

---

## 5. Human review after the packet

- Open each `contact.png` for a one-glance overview, **then** the six
  `*_diag\frame_*_p*.png` frames at full resolution. Contact thumbnails are
  320 px wide (`:27`) and cannot settle fine-pattern questions.
- Confirm the MP4s play at the fps printed by `Assert-Video`, duration equals
  `frame_count/fps`, and the first/last diagnostic frames correspond to 0% and
  100% of the captured path.
- Apply W05 §8.1 acceptance to the *source frames* too (1280×720, non-blank,
  `full_width_dark_rows=0`, contiguous, donor backend proven in `capture.json`).
  A clean MP4 built from bad frames is still a failed capture — re-encoding is
  never a remedy.

**Required reviewer line, verbatim (from W05 §7.3):**

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

---

## 6. Scope / honesty statement

PREP-VIDEO wrote exactly one repo file: this report. It ran only read-only
availability probes (`Get-Command ffmpeg`, `Get-Command ffprobe`, `-version`
queries, a Pillow import check, directory listings) and source reads of
`W05_video_capture.md` and `seq_to_mp4.py`. It launched **zero** Godot
processes, ran **zero** runner subcommands, assembled **zero** videos,
extracted **zero** frames, wrote **zero** capture artifacts, edited no
code/config/test/result, and used no git command. Every command in §4 is a
**PLANNED** packet for COORD and is conditioned on frames that do not exist at
this pass (`%TEMP%\opencode\v42\video\` is absent). No frame count, fps value,
duration, hash or visual finding is invented. Tool versions are observations;
asset acceptance and donor parity are untouched.

**PORT APPROXIMATION / port-internal assembly only; donor parity UNVERIFIED.**

## 7. Five-line summary for COORD

1. ffmpeg, ffprobe (`9.0.1-full_build-www.gyan.dev`) and Pillow 12.1.1 are present — assembly tooling is unblocked; no video has been assembled here.
2. `seq_to_mp4.py` flags verified from source: `--dir`/`--fps`/`--out`/`--contact-only`, encoding `-framerate <fps> -i frame_%04d.png -c:v libx264 -pix_fmt yuv420p -crf 20`; it never reads fps from a manifest.
3. Read fps from each shot's `capture.json` (exact key still **[U]** — packet probes and fails loudly), assert contiguous `frame_%04d.png`, then assemble to `donor_240.mp4` / `donor_64.mp4`.
4. Do not trust `seq_to_mp4.py`'s exit code: missing ffmpeg returns 0 with only a contact sheet; the packet adds non-empty MP4 + ffprobe decoded-frame-count and `frame_count/fps` duration guards.
5. Contact sheets are automatic (assert existence), six diagnostic frames are extracted by exact index (0/20/40/60/80/100%), and a SHA-256 manifest is written outside the repo — all planned, with parity UNVERIFIED.

*End of PREP-VIDEO. Planned only; no runner job, no Godot, no capture, no assembly, no code/git edit, no parity claim.*
