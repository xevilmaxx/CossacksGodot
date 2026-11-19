# What we found in C:\Games\Cossacks 3

C:\Games\Cossacks 3 starts C:\Games\Cossacks 3\editor.exe, so that's what we looked at.

editor.exe is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names.

Evidence ev_2544b87d85fe54c4eb886af829754548105a51a175e5c7f0f8c5fbe8eb0cc67c.

```json
{
  "architecture": "x86",
  "bits": 32,
  "dotnet_arch": null,
  "entry_point": "0xa259b8",
  "format": "pe",
  "format_name": "PE (Windows)",
  "kind": "executable",
  "libraries": [
    "GLU32.dll",
    "PowrProf.dll",
    "advapi32.dll",
    "comctl32.dll",
    "comdlg32.dll",
    "d3d9.dll",
    "gdi32.dll",
    "imm32.dll",
    "kernel32.dll",
    "ole32.dll",
    "oleaut32.dll",
    "opengl32.dll",
    "shell32.dll",
    "user32.dll",
    "version.dll",
    "wininet.dll",
    "winmm.dll",
    "winspool.drv",
    "wsock32.dll"
  ],
  "next_steps": [
    {
      "tool": "core_overview_show",
      "why": "check section entropy; packed code must be unpacked (run in a sandbox) before static analysis helps"
    },
    {
      "tool": "native_functions_list",
      "why": "every function we found"
    },
    {
      "tool": "native_strings_find",
      "why": "find text the program shows or uses"
    },
    {
      "tool": "native_function_study",
      "why": "a full dossier on one function (start with main or the entry point)"
    },
    {
      "tool": "core_feature_find",
      "why": "follow a word you see in the app to the code behind it"
    },
    {
      "tool": "native_pe_resources_list",
      "why": "icons, version information and the manifest"
    }
  ],
  "operating_system": "Windows",
  "plain_english": "editor.exe is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names.",
  "recommended_toolsets": [
    "core",
    "native",
    "formats"
  ],
  "stripped": true,
  "symbol_table_stripped": true,
  "toolchain_hints": [
    {
      "category": "language",
      "evidence": "Borland/Embarcadero markers",
      "id": "delphi",
      "label": "Delphi or C++Builder",
      "strength": "weak"
    },
    {
      "category": "packer",
      "evidence": "section .bind has entropy 7.96 bits/byte",
      "id": "high_entropy",
      "label": "Compressed or encrypted code",
      "strength": "weak"
    }
  ]
}
```

## Ghidra

Deep mode: Ghidra has analysed C:\Games\Cossacks 3\editor.exe (0 min), so decompiling it is quick.

## The game's own files

Folder: C:\Games\Cossacks 3

- Maps and levels: 87 files, 4644.3 MB. For example:
  - dlcs\winter\data\maps\missions\celmis1.map
  - dlcs\summer\data\maps\missions\celmis2.map
  - dlcs\exp1\data\maps\missions\scomis1.map
  - dlcs\dlc4\data\maps\missions\netmis1.map
  - dlcs\dlc3\data\maps\missions\spamis1.map
  - dlcs\dlc2\data\maps\missions\prumis1.map
  - dlcs\dlc1\data\maps\missions\polmis1.map
  - data\maps\missions\ausmis1.map
- Textures and pictures: 6243 files, 3941.3 MB. For example:
  - data\water\textures\diffusewaves0.bmp
  - data\terrain\tiles\textures\alpha.bmp
  - data\terrain\decals\pfx\groundexp0.dds
  - data\terrain\decals\env\christmastreed.dds
  - data\terrain\decals\buildings\algcend.dds
  - data\pfx\textures\blank.bmp
  - data\materials\units\archer.dds
  - data\materials\pfx\buildfire1.dds
- Sounds and music: 325 files, 281.8 MB. For example:
  - data\sounds\units\arrow1.ogg
  - data\sounds\interface\alarm.ogg
  - data\sounds\ambient\alg.ogg
- Settings and scripts: 1163 files, 12.6 MB. For example:
  - cossacks.ini
  - data\sounds\manager.cfg
  - data\scripts\patch.txt
  - data\locale\uk\gui.txt
  - data\locale\uk\missions\ausmis1.txt
  - data\locale\tu\gui.txt
  - data\locale\tu\missions\ausmis1.txt
  - data\locale\ru\gui.txt
