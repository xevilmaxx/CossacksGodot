@echo off
rem Human test launcher for the Cossacks 3 Godot 3D terrain preview.
rem Opens the terrain-only 3D sandbox (world3d.gd via terrain3d_sandbox.tscn).
rem Default dump: app/shots/final_fullmap_dump.json (32x32-tile window).
rem Usage: launch_3d.bat [--seam-mask] [--dump res://shots/foo.json]
rem   Extra args are forwarded to the sandbox scene (after --).
rem   --stay is passed by default so the window stays open for inspection.
rem   For capture-and-quit mode, delete --stay from the command below.
setlocal
cd /d "%~dp0"

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
echo Starting 3D sandbox with %GODOT%
"%GODOT%" --path app res://scenes/terrain3d_sandbox.tscn -- --stay %*
if errorlevel 1 (
  echo Godot exited with an error, code %errorlevel%.
  pause
)
