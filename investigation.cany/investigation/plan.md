# Plan

1. [doing] Read the game's own settings and scripts for singleplayer rules — authoritative numbers: dmscript.global, unit.script, weapon.script, player.script, hotkeys.cfg, camera.cfg
2. [todo] Decompile the game binary for the movement/fire/damage code — the exe is packed; check whether any constants are readable
3. [todo] Copy the original assets the port uses into the project folder — textures, icons, sounds and maps must live with the project
4. [todo] Finish the playable port: gather, mines, building, combat, AI, camera, controls — two self-test steps still fail
5. [todo] Add the fast command-line test mode and the screenshot option — tests must never hang and must be quick
6. [todo] Run the checks and compare against the original — rebuild_check lists what still differs
