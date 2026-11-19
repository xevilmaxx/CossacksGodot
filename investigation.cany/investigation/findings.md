# Findings

- **fnd_1** World and movement constants come from dmscript.global: 26.6666666 px per meter, 53.3333333 px per tile, 32 fps, speeds 32/40/56/96/20 px/s. (Seen it; evidence: ev_0d087bb72d524b54c2bbd50d6c04ba70b65bd225dce3aa280664acb531288090, ev_b526c8821a3fd877bd5bae3ee0021df4f107896543ce9a9ed583887a81fd885e)
- **fnd_2** Gathering and mine income confirmed: 22/14/20 hits for 45/28/40 loads, mine income 13*32/250=1.664 per s, upkeep consume/625 per s. (Seen it; evidence: ev_7d18a5c4ddd26081c7ca9bf53a5642889f05388761f10b504b492a9e6ee25680, ev_22c1e75fcf3b8da4046bb039473f09b569bf3834187532e016f0b0aedd07cea0)
- **fnd_3** Damage formula is _misc_DoDamage in miscext2.script: minus 5 vs fast horse, minus shield, minus squad bonus, minus protection, minimum 1. (Seen it; evidence: ev_c908762281b70283c347d21304dbce59e7dfe4ae6192aaa03ddf2cbe73b577b2)
- **fnd_4** cossacks.exe entry at 0x8f1a08 is a packed loader showing Cossacks III title and DEP/single-instance messages; game logic is not in static code. (Worked it out; evidence: ev_8fb27745cfdcd87de8123c983ce02e5e1d38777db5f954af707a40a39c899437, ev_3b5555f1897d0ff7f4dfa4169162d3100ab22223d1e4d963f0084dcf5d63803e)
