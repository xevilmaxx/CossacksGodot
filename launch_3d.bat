@echo off
rem COMPATIBILITY LAUNCHER - the ACTIVE 3D project is variant3d/ (wave-7 full
rem skirmish variant), not the app/ terrain sandbox. This file delegates to
rem launch_variant3d.bat, which uses variant3d's OWN runner:
rem   python variant3d\tools\godot_runner.py run --id launch3d-manual --timeout 900 -- --path variant3d --stay
rem
rem LEGACY M0 terrain-only sandbox (VISUAL FAIL - do not use for acceptance):
rem   "%GODOT%" --path app res://scenes/terrain3d_sandbox.tscn -- --stay
rem Its old default dump app\shots\final_fullmap_dump.json no longer exists.
rem A surviving t6t90 dump is app\shots\t6t90_dumps\dump_20261113_a.json, but
rem no dump is assumed here. Active 3D work = variant3d/ + wave-6 heightmap.
setlocal
cd /d "%~dp0"

if not exist "variant3d\project.godot" (
  echo [ABORT] variant3d\project.godot is missing - no active 3D project to launch.
  pause
  exit /b 1
)
if not exist "launch_variant3d.bat" (
  echo [ABORT] launch_variant3d.bat is missing - cannot delegate to the 3D launcher.
  pause
  exit /b 1
)

call "%~dp0launch_variant3d.bat" %*
exit /b %errorlevel%
