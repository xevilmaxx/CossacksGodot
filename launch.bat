@echo off
rem Human test launcher for the Cossacks 3 singleplayer port.
rem Opens the project in Godot (singleplayer menu first).
rem Usage: launch.bat [--battle]   (any extra args are passed to Godot)
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
echo Starting with %GODOT%
"%GODOT%" --path app %*
if errorlevel 1 (
  echo Godot exited with an error, code %errorlevel%.
  pause
)
