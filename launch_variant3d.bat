@echo off
rem Canonical launcher for the ACTIVE 3D project: variant3d/ (wave-7 full variant).
rem Preferred path is variant3d's OWN serialized runner - it owns a separate FIFO
rem (.godot_queue) so it never contends with app/ 2D runner jobs. A direct
rem windowed launch is a last-resort fallback and is clearly labelled as such.
rem Usage: launch_variant3d.bat [extra godot user args...]
rem   Extra args are forwarded after Godot's "--" separator.
rem   The runner requires `godot` and `python` on PATH; job id launch3d-manual.
setlocal
cd /d "%~dp0"

if not exist "variant3d\project.godot" (
  echo [ABORT] variant3d\project.godot is missing - the 3D variant scaffold (V7-0) is not present.
  pause
  exit /b 1
)

set "HAS_RUNNER=0"
if exist "variant3d\tools\godot_runner.py" set "HAS_RUNNER=1"
if "%HAS_RUNNER%"=="1" goto :runner
goto :direct

:runner
where python >nul 2>nul
if errorlevel 1 (
  echo [WARN] python not on PATH - falling back to direct windowed launch.
  goto :direct
)
echo Launching variant3d through its own serialized runner...
python variant3d\tools\godot_runner.py run --id launch3d-manual --timeout 900 -- --path variant3d --stay %*
if errorlevel 1 (
  echo variant3d runner exited with an error, code %errorlevel%.
  pause
)
exit /b 0

:direct
rem --- FALLBACK ONLY: direct launch bypasses the FIFO, hard timeout and orphan cleanup. ---
echo [WARNING] variant3d runner unavailable - DIRECT WINDOWED LAUNCH.
echo [WARNING] This bypasses serialization, the hard timeout and orphan cleanup.
echo [WARNING] Use `python variant3d\tools\godot_runner.py run ...` for swarm work.

set "GODOT="
for /f "delims=" %%G in ('where godot 2^>nul') do (
  set "GODOT=%%G"
  goto :found
)
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\godot.exe" (
  set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Links\godot.exe"
  goto :found
)
if exist "%ProgramFiles%\Godot\godot.exe" (
  set "GODOT=%ProgramFiles%\Godot\godot.exe"
  goto :found
)
echo Godot not found. Install it with: winget install GodotEngine.GodotEngine
pause
exit /b 1

:found
echo Starting variant3d directly (UNSERIALIZED) with %GODOT%
"%GODOT%" --path variant3d --stay %*
if errorlevel 1 (
  echo Godot exited with an error, code %errorlevel%.
  pause
)
exit /b 0
