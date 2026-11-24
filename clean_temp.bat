@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

echo ============================================================
echo  Cossacks 3 -^> Godot port : non-essential file cleanup
echo ============================================================
echo  Covers app\ (2D) and, with /VARIANT3D, variant3d\ (active 3D).
echo.

rem --- Safety: never clean while Godot is running ---
tasklist /FI "IMAGENAME eq godot.exe" 2>nul | find /I "godot.exe" >nul
if not errorlevel 1 (
    echo [ABORT] godot.exe is still running. Stop the game / runner first.
    echo.
    pause
    exit /b 1
)

set "FULL=0"
set "SHOTS=0"
set "V3D=0"
set "AUTO=0"
for %%A in (%*) do (
    if /I "%%A"=="/FULL" set "FULL=1"
    if /I "%%A"=="/SHOTS" set "SHOTS=1"
    if /I "%%A"=="/VARIANT3D" set "V3D=1"
    if /I "%%A"=="/Y" set "AUTO=1"
)
if "%AUTO%"=="1" goto :doit

echo [1] Standard  - runner queue, Python bytecode, scratch files
echo [2] Standard + Godot caches (.godot) - first launch will reimport
echo [3] Standard + generated screenshots / dumps in app\shots
echo [4] Standard + variant3d runner queue, caches, generated shots
echo [A] ALL non-essential ^(2 + 3 + 4^)
echo [N] Cancel
echo.
choice /C 1234AN /N /M "Choice [1/2/3/4/A/N]: "
if errorlevel 6 goto :cancel
if errorlevel 5 goto :all
if errorlevel 4 goto :v3d
if errorlevel 3 goto :shots
if errorlevel 2 goto :full
goto :standard

:all
set "FULL=1"
set "SHOTS=1"
set "V3D=1"
goto :menu

:full
set "FULL=1"
goto :menu

:shots
set "SHOTS=1"
goto :menu

:v3d
set "V3D=1"
goto :menu

:standard
:menu
:doit
echo.
echo Will clean:
echo   - app\.godot_queue\results\ and runner *.json state
echo   - __pycache__\, *.pyc / *.pyo, *.tmp / *.temp / *.part
if "%FULL%"=="1" echo   - .godot\ and app\.godot\ caches
if "%SHOTS%"=="1" echo   - generated app\shots\*.png / *.json / pieces\*.png
if "%V3D%"=="1" echo   - variant3d\.godot_queue\results\ and runner *.json state
if "%V3D%"=="1" echo   - variant3d\.godot\ / .import\ caches, *.blend1 / *.glb.tmp / *.gltf.tmp
if "%V3D%"=="1" echo   - generated variant3d\shots\*.png / *.json / *.mp4 / *.log
echo.
echo PROTECTED (never touched):
echo   app\scripts\, app\tools\, app\scenes\, app\shaders\, app\tests\
echo   app\assets\  - INCLUDING models\, models\obj\, models\tex\, terrain\
echo                  and every donor-derived mesh/texture used for baking
echo   inbox\backup\, scans\, docs\, reference\, all root *.md / config files
echo   app\shots\ README hero images and harness *.json configs
echo   variant3d\scripts\, assets\, tools\, tests\, scenes\, shaders\
echo   variant3d\assets\ hardlinks and donor-derived files - NEVER deleted here
echo   3D uses real meshes, not 2D bake sheets; sprite atlases stay untouched
echo   runner locks are left to variant3d\tools\godot_runner.py doctor / reset
echo.
echo.

choice /C YN /N /M "Proceed? [Y/N] "
if errorlevel 2 goto :cancel

echo.
echo [1/8] Runner queue results...
if exist "app\.godot_queue\results" (
    rmdir /s /q "app\.godot_queue\results" 2>nul
    mkdir "app\.godot_queue\results" 2>nul
)
del /q "app\.godot_queue\*.json" 2>nul

echo [2/8] Python bytecode...
for /d /r %%D in (__pycache__) do @if exist "%%D" rmdir /s /q "%%D" 2>nul
del /s /q *.pyc *.pyo 2>nul

echo [3/8] Scratch files...
del /s /q *.tmp *.temp *.part 2>nul
del /q "*.crash" "godot*.log" 2>nul

echo [4/8] Oversized generated PNGs ^(^> 5 MB^) in app\shots...
for %%F in ("app\shots\*.png") do (
    if %%~zF GTR 5242880 (
        set "KP=0"
        for %%K in (portvis-final.png g2_final.png final_nations.png p35_ghost_recheck.png) do if /I "%%~nxF"=="%%K" set "KP=1"
        if "!KP!"=="0" del /q "%%F" 2>nul
    )
)

echo [5/8] Godot caches...
if "%FULL%"=="1" (
    if exist ".godot" rmdir /s /q ".godot" 2>nul
    if exist "app\.godot" rmdir /s /q "app\.godot" 2>nul
    echo       removed ^(reimport on next launch^).
) else echo       skipped.

echo [6/8] Generated screenshots...
if "%SHOTS%"=="1" (
    rem Keep only essential images used by README / docs.
    set "KEEP_PNG=portvis-final.png g2_final.png final_nations.png p35_ghost_recheck.png"
    for %%F in ("app\shots\*.png") do (
        set "KP=0"
        for %%K in (%KEEP_PNG%) do if /I "%%~nxF"=="%%K" set "KP=1"
        if "!KP!"=="0" del /q "%%F" 2>nul
    )
    if exist "app\shots\pieces" (
        del /q "app\shots\pieces\*.png" "app\shots\pieces\*.manifest.json" 2>nul
    )
    rem Keep harness/test configs; drop generated dumps, seedscans and manifests.
    for %%F in ("app\shots\*.json") do (
        set "BN=%%~nxF"
        set "KJ=0"
        if /I "!BN:~0,8!"=="selftest" set "KJ=1"
        if /I "!BN:~0,3!"=="cli" set "KJ=1"
        if /I "!BN:~0,2!"=="q_" set "KJ=1"
        for %%K in (terrain_sample.json terrain_land.json terrain_relief_probe.json t2render.json t3world_winter.json blend_grass.json perf_low.json boost.json islands.json bench.json st2.json low.json perftests.json) do if /I "!BN!"=="%%K" set "KJ=1"
        if "!KJ!"=="0" del /q "%%F" 2>nul
    )
    echo       generated shots removed.
) else echo       skipped.

echo [7/8] Variant3D runner queue...
if "%V3D%"=="1" (
    if exist "variant3d\.godot_queue\results" (
        rmdir /s /q "variant3d\.godot_queue\results" 2>nul
        mkdir "variant3d\.godot_queue\results" 2>nul
    )
    del /q "variant3d\.godot_queue\*.json" 2>nul
    echo       variant3d runner results / state removed.
) else echo       skipped.

echo [8/8] Variant3D caches and generated shots...
if "%V3D%"=="1" (
    if exist "variant3d\.godot" rmdir /s /q "variant3d\.godot" 2>nul
    if exist "variant3d\.import" rmdir /s /q "variant3d\.import" 2>nul
    del /s /q "variant3d\shots\*.png" "variant3d\shots\*.json" "variant3d\shots\*.mp4" "variant3d\shots\*.log" 2>nul
    del /s /q *.blend1 *.blend2 *.glb.tmp *.glb.part *.tmp.glb *.gltf.tmp 2>nul
    echo       variant3d caches / shots removed ^(reimport on next launch^).
) else echo       skipped.

echo.
echo [DONE] Non-essential files cleaned.
echo.
endlocal
pause
exit /b 0

:cancel
echo Cancelled - nothing was deleted.
echo.
endlocal
pause
exit /b 0
