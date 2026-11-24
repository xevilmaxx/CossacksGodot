@echo off
rem Canonical launcher for the ACTIVE 3D project: variant3d/ (wave-7 full variant).
rem
rem IMPORTANT: this is an INTERACTIVE WINDOWED launch, so it must NOT go through
rem variant3d's serialized test runner. That runner (tools/godot_runner.py):
rem   * redirects stdout/stderr to spool files and resolves Godot via bare
rem     `shutil.which("godot")` - on this machine godot is only a WinGet symlink,
rem     NOT on PATH, so Popen("godot") fails and no window ever appears;
rem   * calls reap_spawned_godot() after launch, which taskkill /F's every Godot
rem     process started after its snapshot, meant for WinGet shim orphans, so it
rem     would kill a real game window instantly.
rem For swarm/test launches only, use the variant runner with --headless instead.
rem
rem Usage: launch_variant3d.bat [extra godot args...]
setlocal
cd /d "%~dp0"

if not exist "variant3d\project.godot" (
  echo [ABORT] variant3d\project.godot is missing - the 3D variant scaffold is not present.
  pause
  exit /b 1
)

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
echo Starting variant3d directly with %GODOT%
echo Command: "%GODOT%" --path variant3d %*
"%GODOT%" --path variant3d %*
if errorlevel 1 (
  echo Godot exited with an error, code %errorlevel%.
  pause
)
exit /b 0
