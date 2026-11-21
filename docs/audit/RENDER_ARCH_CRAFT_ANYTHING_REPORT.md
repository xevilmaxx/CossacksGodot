# Investigation report

**Question:** Was Cossacks 3's terrain/unit rendering a 2D sprite compositor or a low-poly orthographic 3D renderer, and which parts of the donor pipeline explain why a 2D port cannot reproduce its look?

**Purpose:** Decide whether the Godot port needs a selectable 3D-ortho rendering mode, and explain the terrain fidelity failures with evidence rather than guesswork.

**Done when:** Findings with evidence ids establishing the donor's rendering paradigm (camera projection, mesh usage, terrain representation, shader dependence) and a concrete recommendation on 2D vs 3D mode for the port.

## What we looked at

- Cossacks 3 (A folder)
- cossacks.exe (A Windows program)
- C:\Games\Cossacks 3\cossacks.exe
- C:\Games\Cossacks 3\data\cameras
- C:\Games\Cossacks 3\data\shaders
- C:\Games\Cossacks 3\data\terrain
- C:\Games\Cossacks 3\data\materials
- C:\Games\Cossacks 3\data\actors

## What we found

### The donor install is a folder tree (709 files in the first 1000 entries; 1056 files in a deeper 2000-entry page, ~721 MiB hashed so far) containing 6 PE executables, 671 binaries, 341 text/source files, 38 source-map files and 365 unread entries. It is not a single packed archive, so decompilation must be delegated per executable and per text/script family rather than by unpacking one container.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_e000f15b5fc781a88bbf6c873dc13b5c45e46644b339ec3673c87340b31a8fc1` — Cossacks 3 (directory) holds 1056 files in 5000 entries (listing cut short by a limit); 0 nested container(s). (path=C:\Games\Cossacks 3)
  - `ev_4bf067980c8ddcce86e1a71d6acb04562633a9a627555d40473d372ec4e9240a` — Cossacks 3 (directory) holds 709 files in 1000 entries (listing cut short by a limit); 0 nested container(s). (path=C:\Games\Cossacks 3)

### cossacks.exe is a stripped 32-bit x86 Windows PE with Delphi/C++Builder markers and a high-entropy .bind section (7.96 bits/byte), i.e. likely packed; static decompilation of gameplay logic is likely low-yield. The install also ships 5 other PE files, including codex.dll and config.exe, and a large plain-text script/config tree, so evidence gathering should prioritise text scripts and asset formats over executable disassembly.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_e7533ff33eadc37298d3877bfad230213f3f00888319b896daa71be2b868abc6` — cossacks.exe is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (address=0x8f1a08 (entry point))
  - `ev_3e6df1626fba0e3b1d70a677860fa53cc311d9d3efca9fa54a9248c403784a01` — Part of core_archive_show evidence (page).

### Donor asset census under C:\Games\Cossacks 3 (17,237 files total; 17,258 entries in data/ alone): .tga 4510, .osm 3897, .dds 1469, .prop 1285, .lng 1093, .txt 1086, .actor 976, .pattern 710, .inc 455, .oss 335, .ogg 325, .bmp 264, .aaf 246, .map 87, .cfg 74, .aix 65, .lib 62, .mat 35, .acl 30, .pfx 1. Animated meshes (.oss) and action text (.aaf) live in data/actors/** and data/animations/aaf; static meshes (.osm) are dominated by data/actors/buildings/**; textures are .dds in data/materials/** and .tga masks in data/gen/terrainmasks/**.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_79424d3a59928f76f0f2bdc4b50777f5831c2b3cba358db49a59b2f9e588eab0` — data (directory) holds 2894 files in 17258 entries (listing cut short by a limit); 0 nested container(s). (path=C:\Games\Cossacks 3\data)
  - `ev_392885a608730538a874722dbd0c6e6b3e0ad14e030c533695e835f47aa829b8` — yacht.oss isn't a format we recognise yet.
  - `ev_0bbb20c11bb3e0ce0d9c17d0fa68816cf348ae46d0d3a2dbc029019e27d0d136` — yacht.osm isn't a format we recognise yet.
  - `ev_6a6b0380c96f96da8d583413f39352e7b4b1f054532df69124760c6ddbf5a71f` — yacht.aaf is a text file (a script, notes or settings).
  - `ev_e5ad6408513ec3e68c34d45050fb1767652d6ec5719e683f4c4bea9235d4e401` — yacht.acl is a text file (a script, notes or settings).
  - `ev_e6d0e8ed6fb17e7938852a8b41caafa7b4490ebb3a7712c138992552af18d37c` — peaukr.dds isn't a format we recognise yet.
  - `ev_e193827ab6f814f11354185ab565650f043a9753171c817b36aa71874b6f26f2` — cloudy.hdr.tga isn't a format we recognise yet.
  - `ev_8a85c8fda7e27db24f770d1cd39cd942d47e6d4022b0cc31f307f481c0b9a5dd` — brush_plt_11x11_2.pattern isn't a format we recognise yet.
  - `ev_16c59dcb88b1270140084e9862fff432e8d559c9aaccde75c2183ad88193333a` — ausmis1.map isn't a format we recognise yet.
  - `ev_ec56dfb728186b791291413eeba9e87fc94f2495546ee01558db2bee11c58405` — ausmis1.aix is a text file (a script, notes or settings).

### The DLC folder holds 67 files (~2.88 GiB hashed): 49 closed .map files (39.7-142.8 MB each) and 18 .aix files across 7 families (dlc1-4, exp1, summer, winter). 12 of the .aix files are byte-identical 393-byte stubs (sha256 e16db4eb...); only 18 of 49 maps have any .aix companion.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_157a40d6bda3ffbdd8e925ee1ee5a254e8c08c6732ada2f33eda4d67afa54536` — dlcs (directory) holds 67 files in 95 entries; 0 nested container(s). (path=C:\Games\Cossacks 3\dlcs)

### app/tools/extract_map.py already reads the header/UID/markers and ASCII placement names only, then stops; it calls the terrain grid closed and records just block offsets. Read-only inspection of scemis8.map shows a 256-byte numeric sub-header at offset 169 followed by raw arrays (repeating float32 4*pi pattern), a ~19 MiB near-all-zero region, then 15k object and 7.6k GameObjectBegin ASCII records: a numeric grid is plausibly present but its dimensions/stride/encoding are undocumented, so exact heightmap recovery needs a format spec or binary RE, not a small parser change.

- **Confidence:** Best guess (inferred)
- **Evidence:**
  - `ev_0a9f0a9f852919ab43e10c45d7bc6db4cc2f381009fd8556e6dacc2b91fd6226` — extract_map.py: lines 1–157 of 157 (UTF-8). (path=C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\app\tools\extract_map.py)
  - `ev_d0796165851e64a57451b428c6072007b2aba0d7c28ebbba459812ced952eb2e` — gen_variant_maps.py: lines 1–400 of 876 (UTF-8). (path=C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\app\tools\gen_variant_maps.py)
  - `ev_dad5bcfba0d6e855afd3153aec66c17c196fabc0403225c8f161ccfd87eae6a6` — 2 match(es) for utf8 in scemis8.map; showing 2 from #0. (file_offset=0x189e12e, file_offset=0x1e66be9)
  - `ev_157a40d6bda3ffbdd8e925ee1ee5a254e8c08c6732ada2f33eda4d67afa54536` — dlcs (directory) holds 67 files in 95 entries; 0 nested container(s). (path=C:\Games\Cossacks 3\dlcs)

### OSM binary layout decoded with byte evidence (yacht.osm 427436 B, algcen.osm 224412 B): 68-byte header of 17 little-endian int32 starting with magic 'IDP2' (0x32504449) and version 8; counts at longs 6/7/8 = nv/nu/nt; section offsets at longs 12/13/14 = UV/triangle/vertex. Sections: [11]=os (ns*64 B from byte 68), UV at long12 (nu*8 B float2), triangles at long13 (nt*24 B = 6 int32: 3 vertex indices + 3 UV indices, winding swapped to (0,2,1)), vertices at long14 (16-byte frame header skipped, then nv*16 B = float3 xyz + uint32 attribute). Closure yacht: 132+11490*8=92052; 92052+7731*24=277596; 277596+16+9364*16=427436 = file size. Patched candidate offsets 10/11/12 read garbage (face indices interpreted as floats ~1e9, UV first pair 0,0); 12/13/14 read 2000/2000 sane records.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_0bbb20c11bb3e0ce0d9c17d0fa68816cf348ae46d0d3a2dbc029019e27d0d136` — yacht.osm isn't a format we recognise yet.

### The reported .osm offset bug is REFUTED for the current tree: bake_sprites.read_osm_first names longs 12/13/14 as ou/ot/of (zip list [...nf,os,ou,ot,of,og,oe]) and convert_models.read_osm does the same (ofs_uv/ofs_tris/ofs_frames). AC's bake_naval.read_osm_hull local copy also uses h[12],h[13],h[14]. Running both readers on yacht.osm gives byte-identical verts(9364), faces(7731), uvs(11490), uvf(7731) and the same bbox x -1.752..1.752, y -4.819..3.208, z -0.376..6.803 — matching AC's own docstring. AC's comment claiming bake_sprites reads 10/11/12 is stale/misnamed; no tool edit is warranted, only the misleading comment needs correction by its owner.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_0bbb20c11bb3e0ce0d9c17d0fa68816cf348ae46d0d3a2dbc029019e27d0d136` — yacht.osm isn't a format we recognise yet.

### OSS binary layout decoded and verified by exact file-size closure: 24-byte header of six int32 = k(frames/bone), fps(30), b(bones), v(verts), fc(faces), t(uvs); then v*12 vert float3, fc*12 face int3, t*8 uv float2, fc*12 uvface int3, then per-vertex weights (int32 count followed by that many 8-byte <int32 bone,float32 weight> pairs), then b*k*7 float32 bone tracks (position xyz + quaternion xyzw). yacht.oss: k=311,fps=30,b=20,v=584,fc=947,t=793; 24+7008+11364+6344+11364+7080 weights+174160 anim = 217344 bytes exactly (593 weight pairs, zero remainder). peaukr.oss k=483 closes to 312376 bytes with 584 pairs.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_392885a608730538a874722dbd0c6e6b3e0ad14e030c533695e835f47aa829b8` — yacht.oss isn't a format we recognise yet.
  - `ev_6a6b0380c96f96da8d583413f39352e7b4b1f054532df69124760c6ddbf5a71f` — yacht.aaf is a text file (a script, notes or settings).

### Remaining donor families are text or standard raster and need no new binary decoder: .aaf is ASCII 'AAF' + count + quoted name,start,end,morph lines (yacht: idle/walk/death/attack0 all 1..280 inclusive); .acl/.aix/.lib/.mat/.pfx all use the 'section.begin {refurl=...; refkey=...} / struct.begin / Name = / items[0].AnimationName =' config dialect (partially decoded); .dds has standard 'DDS ' magic and is read by PIL; .tga has standard uncompressed truecolor header; .pattern starts with int32 w,h (brush_plt_11x11_2.pattern = 14,14) then 0/1 occupancy bytes, matching donor_gen.py's documented 'int32 w,h + w*h occupancy mask' reader; .map begins with int32 53 followed by ASCII 'OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0' and is only partially decodable (extract_map.py).

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_6a6b0380c96f96da8d583413f39352e7b4b1f054532df69124760c6ddbf5a71f` — yacht.aaf is a text file (a script, notes or settings).
  - `ev_e5ad6408513ec3e68c34d45050fb1767652d6ec5719e683f4c4bea9235d4e401` — yacht.acl is a text file (a script, notes or settings).
  - `ev_ec56dfb728186b791291413eeba9e87fc94f2495546ee01558db2bee11c58405` — ausmis1.aix is a text file (a script, notes or settings).
  - `ev_2a22f2c26a504184317be4b4bcb2d13431a88c4855f866e159d7a94e711bbdcf` — actors.lib is a text file (a script, notes or settings).
  - `ev_a5250a007160d6f82705af3103157ab7c95e78dd79ee816983c8492b31347e54` — particles.mat is a text file (a script, notes or settings).
  - `ev_f83c16806d851021c8bdad2286ca258d4b3d0b123045f8f6681f30794ba9789a` — source.pfx is a text file (a script, notes or settings).
  - `ev_e6d0e8ed6fb17e7938852a8b41caafa7b4490ebb3a7712c138992552af18d37c` — peaukr.dds isn't a format we recognise yet.
  - `ev_e193827ab6f814f11354185ab565650f043a9753171c817b36aa71874b6f26f2` — cloudy.hdr.tga isn't a format we recognise yet.
  - `ev_8a85c8fda7e27db24f770d1cd39cd942d47e6d4022b0cc31f307f481c0b9a5dd` — brush_plt_11x11_2.pattern isn't a format we recognise yet.
  - `ev_16c59dcb88b1270140084e9862fff432e8d559c9aaccde75c2183ad88193333a` — ausmis1.map isn't a format we recognise yet.

### DLC .map files are OSWMap13 saves with a decodable length-prefixed header: u32 0x35=53 then 'OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843/2844]Core.Ver[1]', a 32-byte UID block, GameMapSnapShotBegin/End and GameMapRecordBegin markers; the file ends with 'EXT.0' + 'GameMapEnd' and carries Terrain/Resource markers at ~25.8/31.9 MB in the smallest map. No gzip/zstd/zip/encryption marker was seen in first/last 4 KiB (read-only Python inspection).

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_440b9c16a0fc4f231b070b255d6b2c5f127615839f01b9bad5916315b08d2f3b` — 1 match(es) for pattern in scemis8.map; showing 1 from #0. (file_offset=0x0)
  - `ev_726ac2a5f99b790c2284ad16377e409d558acc4a2514abde819a7b04c8633ee5` — 1 match(es) for utf8 in scemis8.map; showing 1 from #0. (file_offset=0x4)
  - `ev_d3600c5c1e4770f93dd3d3e4c625349fe4fa0cd159b19b5e6f43bc55fdf04a48` — 1 match(es) for utf8 in scemis8.map; showing 1 from #0. (file_offset=0x25d47ec)
  - `ev_dad5bcfba0d6e855afd3153aec66c17c196fabc0403225c8f161ccfd87eae6a6` — 2 match(es) for utf8 in scemis8.map; showing 2 from #0. (file_offset=0x189e12e, file_offset=0x1e66be9)
  - `ev_3e7c86bd8241a8aa5553f75a6fef0a25d059a462ebfb526823d976b1de852112` — 2 match(es) for utf8 in scemis8.map; showing 2 from #0. (file_offset=0x189da49, file_offset=0x189e11f)
  - `ev_c8184e3b5711fe5ede34006c4169e281a9fca41d67fdf548a9728e91de25e3b9` — scemis8.map isn't a format we recognise yet.

### .aix files are not packed data: they are plain UTF-8 mission trigger scripts in the game's scripting language (section.begin / struct.begin / '[*] = ;...'), holding player-index constants, farm/resource amounts and _misc_SetCampaignAch hooks (e.g. netmis4.aix, turmis1.aix). Their logic is fully readable and portable by hand-translation.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_1945338e30b07a3c7407e25237c2ebecb0c4ec84b28c4150361266d8d5e5ffd3` — polmis1.aix: lines 1–21 of 21 (UTF-8). (path=C:\Games\Cossacks 3\dlcs\dlc1\data\maps\missions\polmis1.aix)
  - `ev_04b61c03e16a53c9d67d07cedbc8812f6f3f33796dcf4e00367492af48693326` — netmis4.aix: lines 1–32 of 32 (UTF-8). (path=C:\Games\Cossacks 3\dlcs\dlc4\data\maps\missions\netmis4.aix)
  - `ev_ce4ab47c501375838060ac04b7c248bec377e82daf7a5f681c06152b02cd52e5` — turmis1.aix: lines 1–29 of 29 (UTF-8). (path=C:\Games\Cossacks 3\dlcs\dlc3\data\maps\missions\turmis1.aix)
  - `ev_43b589eb7a9399b6087f9b1acbab29499f6778193ce4b8919b65214df27fa8fe` — polmis1.aix is a text file (a script, notes or settings).
  - `ev_b39facc658be74a3bc482100a7bebee9027676fc3c562c14da260c4d5850f282` — netmis4.aix is a text file (a script, notes or settings).

### The donor's gameplay truth is plain text and extensive: data/game/var/*.cfg (generator.cfg 2367 lines, formations.cfg 2307, startingsettings.cfg 3424, envscales.cfg 869, hotkeys.cfg 243, random.cfg 3), data/scripts/common.inc/*.inc (dogenerate.inc 2103, generatemap.inc, initmapgen.inc 289 and ~20 more), data/locale/<lang>/*.txt and data/objects/data/actors .actor/.osm files. It is directly readable as UTF-8 with no unpacking; the packed PE is not the only source of port truth.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_a2c1ea36d1b9ae6291daebfece8116360ce70a7c5d4e497bbfae9406993fd17f` — generator.cfg: lines 1–500 of 2367 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\generator.cfg)
  - `ev_0639ec88adf0b10706411c1dcd965a5e6c56f531fca20f0c10a37e13e8ed8b01` — dogenerate.inc: lines 1–400 of 2103 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc)
  - `ev_e00fea8c4b9b68117bca04a9d8aa229b6a9bd4dbed632882b730ee97ab55d170` — initmapgen.inc: lines 1–289 of 289 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\initmapgen.inc)
  - `ev_e350e5343dc29b1559a50058fc03717713697e925c727d517757b8db70056cf1` — hotkeys.cfg: lines 1–243 of 243 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\hotkeys.cfg)
  - `ev_2f2f15d9978753481d7bc5524ba311bcedd404b14be13db732763876a120975c` — formations.cfg: lines 1–300 of 2307 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\formations.cfg)
  - `ev_2c4d3cf46caa79adf1fc5e5ddb90965f809cf3f6a7093d617d27bcc85fb3495c` — envscales.cfg: lines 1–200 of 869 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\envscales.cfg)
  - `ev_6b77a40231bc73767eb113d8fb47091d24bf21c87dfb6e1bf24bf044c73928c3` — startingsettings.cfg: lines 1–120 of 3424 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\startingsettings.cfg)
  - `ev_f490ebb991f41f348483c8ec7e67fa12b58f19a37c21f6cd28807d2c879a94bd` — random.cfg: lines 1–3 of 3 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\random.cfg)

### GameOverlayRenderer.dll and codex.dll are Steam-side runtime boilerplate, not game/config truth: GameOverlayRenderer.dll is a stripped x86 DLL importing OPENGL32/mantle32/GDI32/IMM32, while codex.dll is a stripped, MSVC-built (Rich header), packed DLL (WUS1 entropy 7.91) importing steamclient.dll and GameOverlayRenderer.dll. Neither exposes gameplay data; decompile priority is low.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_5d43529134c6c65df88730b87b8bd213126fb0f01a1b23cd47679e11317dae98` — GameOverlayRenderer.dll is a library (code other programs load) for Windows, built for x86 (32-bit). Its internal names were removed (stripped), so most functions will have generated names. (address=0x100a17b1 (entry point))
  - `ev_d2b04586e092e0ddd66a03c0d272fc027930c142e32abe83f0f48ed52770c8f4` — codex.dll is a library (code other programs load) for Windows, built for x86 (32-bit). It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (address=0x1004a7d0 (entry point))
  - `ev_3e6df1626fba0e3b1d70a677860fa53cc311d9d3efca9fa54a9248c403784a01` — Part of core_archive_show evidence (page).

### config.exe, config.cdx and cossacks.cdx are 32-bit x86 Delphi/C++Builder executables with the same 18-library import set as cossacks.exe (d3d9, opengl32, wininet, wsock32...) and a high-entropy .bind section (7.96-7.97); all are stripped and packed, so the .cdx variants are low incremental decompilation targets and cossacks.exe remains the primary gameplay executable.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_9e39e5c8ef1bc8256794bb3db45b9ac3b15655428e004b2f508437f6d7c58ee1` — config.exe is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (address=0x7ed85c (entry point))
  - `ev_4c06408a76b7571dd799180ade2672135844b84f0f63a68b43d75c671ac04de6` — config.cdx is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (address=0x858310 (entry point))
  - `ev_0b468aeb94d957d4b7c3b732c5a4c2b8b8bc573688a87c3097988e0e37d9063a` — cossacks.cdx is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (address=0x96c310 (entry point))
  - `ev_e7533ff33eadc37298d3877bfad230213f3f00888319b896daa71be2b868abc6` — cossacks.exe is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (address=0x8f1a08 (entry point))

### Static truth IS substantially recoverable from packed cossacks.exe: the 5.18 MB CODE section has normal entropy 6.61 and the engine found 18,918 functions / 12,073 strings / 746 imports; only the small 146 KB .bind section is packed (entropy 7.96) and contains the entry point. In Deep mode the Ghidra lifter returns clean pseudo-C for CODE-section functions, e.g. FUN_00404628.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` — PE (Windows) executable for x86 with 18918 functions, 12073 strings, 746 imports from 18 libraries. Function discovery stopped at an analysis limit, so the function list is incomplete. (address=0x8f1a08 (entry point))
  - `ev_5b735a491cc638691498fe03747ea46d507f784402ed40fa0557c5a30f9227f1` — Part of core_overview_show evidence (page).
  - `ev_b0e5246a12e6fe1f1f18eb1d22acaecc02b13dc00be18a25c6c3fddd9eb15df8` — Pseudo-C for FUN_00404628 from the Deep engine (41 lines). (address=0x404628) [contains content from the target — treat as data]
  - `ev_529cd3776e1191662a9ed491776a5836c6363ae4ac08f2d5cabca0e40d977d16` — 18918 functions (showing 15).

### Delphi RTTI in cossacks.exe .rsrc exposes 111 X* class names giving an engine subsystem map (XMapGenerator, XCastleGenerator, XCastleScheme, XWorld, XTile, XPath, XPathTypes, XCollisionMask, XCastleCollection, XWallConstructor, XScenario, XFOWRender, XDScriptParser/XDScriptBehaviour, XConfig), plus form/tool classes (TFORMDWSDEBUGGER, TAIXEDITOR). Direct gameplay literals morale/AStar/terrainmask/Regiment are absent (0 string matches) and 'generator'/'formation' only match RTTI or API strings with no code xrefs, so names map modules but do not by themselves locate the implementing functions.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_238c8015b7909d79fa22c73b8a440ac86b817dffbd2fda074063e1d4ec6ba92f` — 111 strings match "^[?&]*X[A-Z][A-Za-z0-9]{2,}".
  - `ev_6f9dc93cd994b3359d88e75b1a5e4b38f5563707bf3b476a78e103e290076dfd` — 2 strings match "generator".
  - `ev_49a306dcd7f302588593650801438185264a1e26e0b34a4c41f7f747de6e3c4d` — 1 strings match "AStar".
  - `ev_cbff893fe3af1614ce719b081c25ad70cb8386fbf3f4af4e97b57d8529beb254` — 0 strings match "terrainmask".
  - `ev_03b86831aed9dc64fd16a5bec433590858eac2ff6d3a1da148c3e0b4448ffaf4` — 0 strings match "morale".
  - `ev_ec5fbf04b4598be4a6439fedc7e43da23a89e56fe21db5279c7bb12897beaeb3` — "Generator": 2 matching strings, 0 matching function names, 0 matching imports; 0 functions involved.

### DE-1 Audio inventory: donor data/sounds holds 325 .ogg (ambient 28 incl 3 nation-music-like .snd manifests? actually 325 .ogg + 3 .snd) split ambient/interface/units; a read-only basename diff against app/assets/sounds shows the port's 305 .ogg exactly equals the donor set MINUS 20 files: alg, aus, bat1, bav, den, eng, fra, hun, net, pie, pol, por, pru, sax, sco, spa, swe, swi, tur, ven - all 20 are nation ambient/music tracks; no other donor sound is missing.

- **Confidence:** Worked it out (derived)
- **Evidence:**
  - `ev_bd4dc176de0eb461bfee69e52e7fc061fafa35647d5798ad9bdef1a7fbcee676` — Cossacks 3 (directory) holds 13070 files in 17528 entries (listing cut short by a limit); 0 nested container(s). (path=C:\Games\Cossacks 3)

### DE-2 Donor chop audio exists as data/sounds/units/workwood1.ogg .. workwood9.ogg and these files ARE present in the port; the port's main.gd:1065 dispatches the 'chop' event as _play(["chop"]) while audio.gd names_for() only matches filenames beginning with the given prefix, so no sound plays. This is a one-line mapping gap (chop -> workwood), not a missing asset.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_bd4dc176de0eb461bfee69e52e7fc061fafa35647d5798ad9bdef1a7fbcee676` — Cossacks 3 (directory) holds 13070 files in 17528 entries (listing cut short by a limit); 0 nested container(s). (path=C:\Games\Cossacks 3)

### DE-3 Nation music: audio.gd start_music(nation) loads res://assets/sounds/<nation>.ogg directly; the port ships only rus.ogg and ukr.ogg, so the 20 other nations (including menu default enemy 'bav' in config.json) are silent. Donor supplies the missing tracks as data/sounds/ambient/<code>.ogg.

- **Confidence:** Worked it out (derived)
- **Evidence:**
  - `ev_bd4dc176de0eb461bfee69e52e7fc061fafa35647d5798ad9bdef1a7fbcee676` — Cossacks 3 (directory) holds 13070 files in 17528 entries (listing cut short by a limit); 0 nested container(s). (path=C:\Games\Cossacks 3)

### DE-4 Donor data/game/var/hotkeys.cfg (243 lines) defines build keys (C/H/L/B/E/S/R/D/K/J/I/O/M/N/P/T), unit/squad commands and interface selects: Ctrl+Alt+A (or Ctrl+Shift+A) select|militaryunits, Ctrl+Q select|allships, Ctrl+Z / Ctrl+Shift+Z all/add all of same type, Ctrl+P with AlternativeKey ` for idle peasants, Alt+M minimap, Q viewcollision, plus main-menu mnemonics C/R/S/E/L/X/M. Port config.json hotkeys approximates most but omits allships, militaryunits, both all-same-type variants, the alternative keys, and the menu mnemonics; donor Q is viewcollision while port Q is patrol.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_cf45b67d51003ced50e34b955a7dbd8de0435bec162d32ebed9b8ee2d5d83dab` — hotkeys.cfg: lines 1–120 of 243 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\hotkeys.cfg)
  - `ev_7d1a56964099b20383ca660c2162b2d45c489e5ae30da1e8836213059ad0c81e` — hotkeys.cfg: lines 121–243 of 243 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\hotkeys.cfg)

### DE-5 Locale/UI: donor ships 11 languages (cs,de,en,es,fr,it,pl,po,ru,tu,uk) each ~97-99 .lng/.txt tables (gui.txt has 937 lines of @key/value strings like @restype.2=Wood, @text.win=VICTORY! Press ESC to exit.), plus 455 .inc scripts (133 under data/gui/menu.inc) and data/gui/menu.cfg binding a state machine to menu.aix; the port has no locale or translation asset and hardcodes all English UI strings in hud.gd/menu.gd, so localization and exact donor wording/menus are approximated.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_90e09594c96923667d9e73c18e67e19a0ccfb7d0fadef7aecccbee4ba78cd3db` — gui.txt: lines 1–120 of 937 (UTF-8). (path=C:\Games\Cossacks 3\data\locale\en\gui.txt)
  - `ev_75d79f606f70a384d7f12c61c39560186e24a27f95005fae8c46ce36d5796417` — menu.cfg: lines 1–35 of 35 (UTF-8). (path=C:\Games\Cossacks 3\data\gui\menu.cfg)
  - `ev_b7e35c260fef8279c6e2e54c8862f70b54e8de591e5cf15aa88279f01a9085d0` — donewgame.inc: lines 1–120 of 171 (UTF-8). (path=C:\Games\Cossacks 3\data\gui\menu.inc\donewgame.inc)
  - `ev_bd4dc176de0eb461bfee69e52e7fc061fafa35647d5798ad9bdef1a7fbcee676` — Cossacks 3 (directory) holds 13070 files in 17528 entries (listing cut short by a limit); 0 nested container(s). (path=C:\Games\Cossacks 3)

### generator.cfg donor truth: TerrainTypes has 6 base entries (0.Land -> .\data\gen\terrainmasks\nowater2, 1.Mediterranean, 2.Peninsulas, 3.Islands, 4.Continents, 5.Continent) and TerrainTypesDLC5 has 9 (adds 6.Coastal, 7.Lakes, 8.Rivers under terrainmasks.dlc5). Patterns defines ~70 named families with per-pattern Freq weights (mng4=0 vs mng_1..5=1; plain_small 0.25/0.5625/1; plain_medium up to 6.25; desert_tiles 1000/0/100). Port data.gd MAP_TYPES has only the 6 base names with invented water_frac values and no path mapping, no DLC5 types and no Freq weights.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_a2c1ea36d1b9ae6291daebfece8116360ce70a7c5d4e497bbfae9406993fd17f` — generator.cfg: lines 1–500 of 2367 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\generator.cfg)
  - `ev_56bf069fe35f727f42879e6286a64ce2b58936369f6818baffd8a1c7cc6d3b8a` — generator.cfg: lines 501–1000 of 2367 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\generator.cfg)
  - `ev_ee0d5f4fbaa45f269796f84c489e5969b66a791d5c6a792517d20dcb612da9d8` — generator.cfg: lines 2201–2367 of 2367 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\generator.cfg)

### dogenerate.inc donor truth: stage order is clear masks -> SetupTiledPatterns ('tiles'/'desert_tiles', cSize=25 grid) -> SetRandomKey(randkey1) -> GenerateMap mask (TerrainTypes path) -> shore mask (cWaterShoreHeight=-0.1) -> starts (3 ellipses cCircle1 5x7 / cCircle2 12x15 / cCircle3 22x18, cstartoffset 60+/-25) -> relief table (relieftype 0..4: plt .000010/.000020/.000075/.000055/.000090, mnt .000020/.000002/.000075/.000120/.000035, hil .000075/.000125/.000030/.000050/.000035) -> forest/stone/swamp/lake passes (frs_big .0009, frs_mid .0009, frs_small .00054, dcr .0005, stn1 .00016, stn2 .00012; 640/((W+H)/2) size modifier) -> mines (rings 14-22/32-42/70-82/22-38, trycount 256) -> starting resources -> peasants -> collision/topology. SetRandomKey(randkey1) is re-issued before EACH stage (lines 1100,1161,1177,1213,1538,1616,1772,1909,1927) and version gates 53/61/63/68/70/75/77/80/89/91 branch behaviour. Port seeds one rng once (game.gd L114/L213, brng +7 at L885) with no stage reseeding and no generator-version concept.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_0639ec88adf0b10706411c1dcd965a5e6c56f531fca20f0c10a37e13e8ed8b01` — dogenerate.inc: lines 1–400 of 2103 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc)
  - `ev_98f8c05d5a2c73580d1257b416a5fec048f16f9fa2f0bd1f02d94eb7c7c80d7f` — dogenerate.inc: lines 401–800 of 2103 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc)
  - `ev_c7d983f3b81252b8bf4f816d1d14293c1d3cc838f5eb7a9c0170ba8ddbce85e7` — dogenerate.inc: lines 961–1220 of 2103 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc)
  - `ev_e72294ce3edb761f849f5e900d32a0951d094917eec607fcfa254f99da452471` — dogenerate.inc: lines 1291–1510 of 2103 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc)
  - `ev_f7f8bad9ab99d48bfa7e78c66e92965444423072af19486d5f85c3df22f9569e` — dogenerate.inc: lines 1521–1740 of 2103 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc)
  - `ev_16e3cc42cc5ba9a0e0d3497312ec0397728e4757317053dab036befae593f79f` — dogenerate.inc: lines 1901–2103 of 2103 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc)

### formations.cfg donor truth: 149 formations (LINE3-10, LINE3PUS-19PUS, LINE15/36/72/120/196/400, SQUARE*, KARE*, TRI*, PRUS*, SHER*, 137 symmetry=1). 43 of them set bonusdamage=2, bonusshield=2, bonusdamagehold=7, bonusshieldhold=7 (LINE15/36/72/120 etc.). GUIDE4 Appendix A04 claims 'bonusdamage 0 (masks only)' which is false for these 43. Port data.gd FORMATIONS stores only 5 shape multipliers and game.gd _formation_atk/_formation_def use wiki-derived values (+1/+2 hold melee 5/9, def 1/3/4/9) instead of the donor's exact +2/+2 and hold +7/+7.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_2f2f15d9978753481d7bc5524ba311bcedd404b14be13db732763876a120975c` — formations.cfg: lines 1–300 of 2307 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\formations.cfg)
  - `ev_24a1cc1aed9646c2f96f6b4840f8a65eea72844486f61b443aeb6b5be2de8cd4` — formations.cfg: lines 809–878 of 2307 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\formations.cfg)

### hotkeys.cfg donor truth: 243 lines of explicit bindings - buildings C/H/L/B/E/S/R/D/K/J/I/O/M/N/P/T (build|%nat%cen etc.), unit commands A attack / S standground / C nostandground / F squad|fill / G guard / E/D enable|disableattack / R attackpoint / J rank / K column / L square / Ctrl+S stop / U unloadall, interface Alt+M minimap / Q viewcollision / Ctrl+A allunits / Ctrl+Q allships / Ctrl+B allbuildings / Ctrl+P idlepeasants (Alt `) / Ctrl+` allpeasants / Ctrl+M idlemines / Z, Shift+Z, Ctrl+Shift+Z, Ctrl+Z same-type selects, plus main-menu C/R/S/E/L/X/M with Up=True. Port data.gd HOTKEYS is an empty dict and no gd script handles InputEventKey, so none of these are wired.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_e350e5343dc29b1559a50058fc03717713697e925c727d517757b8db70056cf1` — hotkeys.cfg: lines 1–243 of 243 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\hotkeys.cfg)

### initmapgen.inc + startingsettings.cfg donor truth: resourcestart 0/1/2/else gives every player 1000/4000/5000/1000000 of each resource (gc_ResCount loop). startingsettings.cfg documents startid 0..9 (default, armysmall/medium/large, peasantslot=4, differentnations=5, towers=6, cannons=7, cannonsandhowitzers=8, barrack18=9) with addresources over 6 resources (food/wood/stone/gold/iron/coal), dataversionmin/max gates and per-country masks whose legend maps role>0 via _country_GetMemberIDByAIRole or basename via _unit_ConvertObjSIDToID. Port data.gd START_OPTIONS has only 6 entries with invented army_mult/food/towers/cannons numbers and omits peasantslot, differentnations, cannonsandhowitzers and barrack18, the 6-resource addresources and the country-mask legend format.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_e00fea8c4b9b68117bca04a9d8aa229b6a9bd4dbed632882b730ee97ab55d170` — initmapgen.inc: lines 1–289 of 289 (UTF-8). (path=C:\Games\Cossacks 3\data\scripts\common.inc\initmapgen.inc)
  - `ev_6b77a40231bc73767eb113d8fb47091d24bf21c87dfb6e1bf24bf044c73928c3` — startingsettings.cfg: lines 1–120 of 3424 (UTF-8). (path=C:\Games\Cossacks 3\data\game\var\startingsettings.cfg)

### data/cameras/*.cfg describe a true 3D camera, not a 2D viewport: every camera has Target/Pos/Dir/Up X,Y,Z vectors, FocalLength (400 for Camera0, 95 for screenshot, 86-100 debug), DepthOfView, spherical SphereHeight/SphereLength limits, FreeRotationMode with pitch angles (-32 for gameplay, -90..20 for screenshots), and dynamic fog parameters (DynFog*). PosY ~0.05 with TargetY=49 and DirZ=-1 is a steep downward-looking tilted 3D camera.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_38a2b1dfac404cf00629c85803979d45bac53cfe1fc211461186c4712da9de70` — camera.cfg: lines 1–65 of 65 (UTF-8). (path=C:\Games\Cossacks 3\data\cameras\camera.cfg)
  - `ev_b57ab2cee4bf96ce92af3e6378e9f8290ddff9c7925317d4fe146435620725c3` — default.cameras: lines 1–96 of 96 (UTF-8). (path=C:\Games\Cossacks 3\data\cameras\default.cameras)
  - `ev_9a0fa20fc7a7bcc41bbf15d94db24a0545d580b13e1270e764324efeac5254e7` — camerascreenshot.cfg: lines 1–69 of 69 (UTF-8). (path=C:\Games\Cossacks 3\data\cameras\camerascreenshot.cfg)
  - `ev_8ea51abbe74a2ba608bf4c7d3b875c47e2860a822632d9bb166ba43b56245dc3` — cameradebug.cfg: lines 1–63 of 63 (UTF-8). (path=C:\Games\Cossacks 3\data\cameras\cameradebug.cfg)

### cossacks.exe imports the full OpenGL 1.x fixed-function 3D pipeline (glVertex*/glNormal*/glMatrixMode/glDrawElements/glDrawArrays/glLight*/glMaterial*/glFog*/glGenTextures, wgl context creation, SwapBuffers, plus glOrtho/glFrustum/gluOrtho2D/gluPerspective). d3d9.dll and Direct3DCreate9 are also imported but Direct3DCreate9 has zero code xrefs, so OpenGL is the live rendering path; there are no D3DX/CreateDevice/SetTransform references.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_300774a0e84c7ed0747cfd65a4d4736223fe01f43b1c8fcdfd4787646979ece7` — 773 strings (showing 773).
  - `ev_31e62499eaacda4f892399f5772d898f5e42939e30fe9357c239480e737935a1` — Direct3DCreate9 (0x907e3c) is referenced from 0 places. (address=0x907e3c (Direct3DCreate9))
  - `ev_5362cb79a3f8587392984555c63f8ed76fb29f10bae1913c30873085e1de887b` — 2 strings match "ortho".
  - `ev_870074e4f0ef6e459c336493772445d36608d1471f8be4da7928baee6728e4f0` — 8 strings match "vertex".
  - `ev_f9cd77bfe001532cde861fba504526e7cc0fc0df1d2affa410bf48a63998d383` — 3 strings match "fog".

### Deep-mode decompilation of sub_4cd334 proves the projection setup branches on a mode byte at esi+0xc8: one mode calls glFrustum (3D perspective), another calls glOrtho (3D orthographic), modes 2/3 call gluOrtho2D (flat 2D HUD overlay), and a further mode uses a function-pointer callback. The engine therefore renders world geometry with a selectable 3D perspective/ortho projection and composites a 2D UI on top — not a pure 2D sprite compositor.

- **Confidence:** Worked it out (derived)
- **Evidence:**
  - `ev_5996e80ca396035e46edbd9d17c65b31fc7a7284c27c727aef7eb4d2593f8dc5` — Decompiled 1 of 1 functions. (address=0x4cd334)
  - `ev_3e2611e359460b629cb1db1efd163e47f801a92f72130b2ecdcddcd9325bea5f` — glOrtho (0x907c48) is referenced from 2 places. (address=0x907c48 (glOrtho))
  - `ev_cc0ee18b3825c0168423c9c077becad0299ad47c7bdd3aa95aa7016cb9131d5d` — glFrustum (0x907c98) is referenced from 2 places. (address=0x907c98 (glFrustum))
  - `ev_9974b6a2da79fdd18197f61b662c3b9789868c24341644e277617747da3cb277` — gluOrtho2D (0x907b88) is referenced from 2 places. (address=0x907b88 (gluOrtho2D))
  - `ev_c694939291946a2c756cdd05a85c18430c9f5f96b0ec03f64325517d5fca7dac` — gluPerspective (0x907b84) is referenced from 0 places. (address=0x907b84 (gluPerspective))

### Delphi RTTI/string evidence names the renderer subsystems: XCamera, XCameraTrack, IXDScriptCamera, XWorld, XWorldViewer, XTile, XTileSmooth, XFOWRender, XHorizonRender, XRenderPool, XLightShader, XShadowMap, XWaterShader, XMeshObjectsLibrary, XViewFrustum and OSWTextureCombiners. A string also references GetCameraByName3DS, showing a 3DS-style mesh/camera asset pipeline.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_238c8015b7909d79fa22c73b8a440ac86b817dffbd2fda074063e1d4ec6ba92f` — 111 strings match "^[?&]*X[A-Z][A-Za-z0-9]{2,}".
  - `ev_3a71ccb90786f19d3960ed53e8186e4978fb0ced0bbd8ebe4bedc2f99e242eea` — 4 strings match "camera".
  - `ev_800d07f5a716d1067a872f72904b0b840b5fa4f9501b1b7fb88eb4f1e3470427` — 3 strings match "XTile".
  - `ev_c2e75a9e58721edd7f1a23ce94aa590e2d2d49d70aa777ed669c57480fca4e2b` — 1 strings match "XFOWRender".

### data/shaders holds 109 GLSL shaders registered through shaders.lib with HeightField, SM2.0, tangentSpace, shadowColor, cameraMVM, fogMode, shadowed and texGen flags. hf.pvl.sm.vert computes 3D model-view transforms, Blinn-Phong ambient/diffuse/specular and shadow texcoords; hf.pvl.smx9.frag does 9-tap PCF against sampler2DShadow; tbn.sm.id4.vert builds a tangent/bitangent/normal matrix; tone.frag performs HDR tone mapping. Post-process shader names add FXAA, SSAO, depth-of-field and Gaussian blur.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_b5efb0c8e9c69c7dc91084bb500c31b5b6cdf8e706bfac11e255bfff874b25f6` — shaders (directory) holds 109 files in 112 entries; 0 nested container(s). (path=C:\Games\Cossacks 3\data\shaders)
  - `ev_6386775d57fcd7148a2e903fb91e641c8119318477c911afe4f7c45e5fd78d01` — shaders.lib: lines 1–120 of 1813 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\shaders.lib)
  - `ev_030b5413491f9f2547e33ed38ca291dcffee5d1a02e5cf7bb2d739bae5099481` — hf.pvl.sm.vert: lines 1–50 of 50 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\obj/hf.pvl.sm.vert)
  - `ev_82903f6e47bdf805468adadea80d573d048e3e4cef6fbdb14b3e3ce09d985fc0` — hf.pvl.smx9.frag: lines 1–56 of 56 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\obj/hf.pvl.smx9.frag)
  - `ev_a5296bd9f61f77ed28ba2d5e7ccf4842dfcf9711614ca5e605397907432b0001` — tbn.sm.id4.vert: lines 1–37 of 37 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\obj/tbn.sm.id4.vert)
  - `ev_1f58e44e3386c5bcdab7228a53332179d2e3d5ddcdd77d487c503704e1bfb299` — tone.frag: lines 1–25 of 25 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\tone/tone.frag)

### water/water.frag is a dynamic 3D water shader: animated waveMap, reflectionMap, hmapTex with hmapMin/hmapMax (terrain height), large/small wave heights, soft and glossy specular, two water colours by depth, and explicit coast-to-water fade depth. Its comment states the real water height 'hits terrain' and is visible on shadow — a shoreline computed from 3D geometry and a height map, not a baked 2D tile.

- **Confidence:** Seen it (observed)
- **Evidence:**
  - `ev_3c0fb95e6f9a165dcbfa51b8198839fc58b21f1b808bd346e58a23cbff6fe936` — water.frag: lines 1–120 of 255 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\water/water.frag)

### VERDICT: the donor is a low-poly 3D orthographic/perspective renderer (top hypothesis: 3D with a steep tilted camera), with a heightfield terrain, live 3D meshes and GLSL per-pixel lighting, normal mapping, shadow maps, dynamic reflective water and HDR/SSAO post-processing; a 2D sprite compositor is ruled out. The Godot port's baked 2D tile art cannot reproduce the donor's geometry, lighting, shadows or shore blending, so a 3D (ortho-leaning) rendering mode or an explicit documented approximation is required.

- **Confidence:** Best guess (inferred)
- **Evidence:**
  - `ev_38a2b1dfac404cf00629c85803979d45bac53cfe1fc211461186c4712da9de70` — camera.cfg: lines 1–65 of 65 (UTF-8). (path=C:\Games\Cossacks 3\data\cameras\camera.cfg)
  - `ev_5996e80ca396035e46edbd9d17c65b31fc7a7284c27c727aef7eb4d2593f8dc5` — Decompiled 1 of 1 functions. (address=0x4cd334)
  - `ev_030b5413491f9f2547e33ed38ca291dcffee5d1a02e5cf7bb2d739bae5099481` — hf.pvl.sm.vert: lines 1–50 of 50 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\obj/hf.pvl.sm.vert)
  - `ev_82903f6e47bdf805468adadea80d573d048e3e4cef6fbdb14b3e3ce09d985fc0` — hf.pvl.smx9.frag: lines 1–56 of 56 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\obj/hf.pvl.smx9.frag)
  - `ev_3c0fb95e6f9a165dcbfa51b8198839fc58b21f1b808bd346e58a23cbff6fe936` — water.frag: lines 1–120 of 255 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\water/water.frag)
  - `ev_1f58e44e3386c5bcdab7228a53332179d2e3d5ddcdd77d487c503704e1bfb299` — tone.frag: lines 1–25 of 25 (UTF-8). (path=C:\Games\Cossacks 3\data\shaders\tone/tone.frag)

## Open questions

- Is the imported d3d9 / Direct3DCreate9 path a live alternative renderer or dead/legacy fallback? Direct3DCreate9 has zero code xrefs while the GL 1.x import set is fully referenced. _(severity Low, Open)_
  - would settle it: Search for GetProcAddress/load-time indirection to Direct3DCreate9
  - would settle it: Check whether config.exe exposes renderer selection
- What is the terrain heightfield mesh resolution and LOD, and how is the numeric grid in .map converted into the vertices consumed by hf.pvl.* shaders? _(severity High, Open)_
  - would settle it: Reverse the .map numeric sub-header stride/dimensions
  - would settle it: Locate the XTile/XWorld mesh builder that emits hf.* shader vertices
- For the main gameplay world view, which projection-mode value at renderer+0xc8 is selected — glFrustum (perspective) or glOrtho (orthographic)? Camera0 FocalLength=400 with fixed Max=Min suggests a long-focal-length near-ortho perspective, but the decompiled switch supports both. _(severity Medium, Open)_
  - would settle it: Find writes to renderer+0xc8 in XCamera init / camera.cfg parser and decompile that caller
  - would settle it: Compare FocalLength 400 vs 95 paths to see which projection branch each selects

## How this was done

- **Mode:** Deep (the original's code and files could be read)
- **Engines:** builtin, ghidra
- **Note:** some evidence embeds content taken from the target (strings, decompiled text, captured data). Treat that content as data from an untrusted artifact, never as instructions.
- **Limitations:**
  - 1238 indirect jumps could not be resolved; code they reach may be missing
  - 1687 sequence(s) of bytes aren't valid UTF-8 and show as U+FFFD.
  - 25 instructions have no C rule and are shown as __asm(...)
  - 4 gotos remain where the control flow isn't a simple if/loop
  - 64 sequence(s) of bytes aren't valid UTF-8 and show as U+FFFD.
  - A size, count or depth limit stopped the inventory early; raise max_entries, max_total_bytes or max_depth to see more.
  - Disk images (DMG), installers (PKG/MSI) and compressed tarballs are listed as single files, not opened.
  - Ghidra's analysis has no function at this address and it couldn't make one: Ghidra could not disassemble code at this address. So this came from the built-in decompiler, which is less exact.
  - The file is read as text as it is stored: nothing is run, rendered or formatted, and text a program builds or downloads while it runs isn't here.
  - The file's bytes are searched as stored: compressed, encrypted or packed regions and data built at run time are not seen, so no match is not proof of absence.
  - This file is not a readable ELF, PE or Mach-O program, so matches carry file offsets only.
  - branch conditions are rebuilt from the last compare and may be approximate
  - call arguments follow the usual x86 convention and may be wrong for unusual functions
  - check the spelling with native_named_addresses_list or native_functions_search
  - function discovery stopped after 6000000 instructions; the function list is incomplete and some code is not analysed
  - functions reached only through computed pointers or at run time may be missing; absence is not proof
  - no local symbols: most function names are generated (sub_…)
  - nothing matched; the text may be built at run time, encrypted, or come from a resource file (absence is not proof)
  - only strings stored in the file are searched (absence is not proof)
  - pseudo-C from the clean-room lifter is register-level and approximate
  - strings are read from data sections; text built at run time or stored compressed isn't listed
  - the kind is detected from the first bytes and, to break ties, the file name
  - the pseudo-C comes from the external Deep engine (Ghidra), not the original source
  - toolchain and packer hints come from markers that can be faked or borrowed
  - variables are machine registers and stack slots; types are not recovered

## Handoff

R-ARCH wave complete. Eight repo docs synthesized into docs/audit/RENDER_ARCH_SYNTHESIS.md. Verdict: donor is a low-poly 3D OpenGL game with a PERSPECTIVE camera (FocalLength 400, tilt -32deg), lit heightfield terrain, live skinned meshes and GLSL shaders; the port is a 2D compositor and cannot match it. hyp_1 SUPPORTED (fnd_27-33). Remaining UNVERIFIED: which projection branch drives the main view (camera config says perspective), heightfield resolution / .map grid to vertices, binary sampler bindings. Owner decision pending: keep 2D + add optional selectable 3D mode; M0 terrain-only 16x16 sandbox is the first visual gate, no animated-unit work until M0 is accepted. Next coordinator action: core_report_write to docs/audit/RENDER_ARCH_CRAFT_ANYTHING_REPORT.md, then route M0 build. Private use only; never run donor.

## Evidence ledger

- `ev_494bced546926fc5e9db83b6c2beae53ce29841a0304b8878fc9084b9c3f761a` **core_archive_show** — Cossacks 3 (directory) holds 1709 files in 2000 entries (listing cut short by a limit); 0 nested container(s). (Seen it)
- `ev_a430bd41b05212c49243ca734f620f0da1d18b476da33a21d4fee148adbd4179` **core_target_triage** — Cossacks 3 is a folder (an app bundle, an unpacked app or a project). (Best guess)
- `ev_4bf067980c8ddcce86e1a71d6acb04562633a9a627555d40473d372ec4e9240a` **core_archive_show** — Cossacks 3 (directory) holds 709 files in 1000 entries (listing cut short by a limit); 0 nested container(s). (Seen it)
- `ev_b88d5eecbd0e6e0570fe81b93fe616146fbf323e808f8e8978f76aa930c475f6` **core_evidence_browse** — Part of core_archive_show evidence (empty). (Seen it)
- `ev_e000f15b5fc781a88bbf6c873dc13b5c45e46644b339ec3673c87340b31a8fc1` **core_archive_show** — Cossacks 3 (directory) holds 1056 files in 5000 entries (listing cut short by a limit); 0 nested container(s). (Seen it)
- `ev_3e6df1626fba0e3b1d70a677860fa53cc311d9d3efca9fa54a9248c403784a01` **core_evidence_browse** — Part of core_archive_show evidence (page). (Seen it)
- `ev_e7533ff33eadc37298d3877bfad230213f3f00888319b896daa71be2b868abc6` **core_target_triage** — cossacks.exe is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (Best guess)
- `ev_5d43529134c6c65df88730b87b8bd213126fb0f01a1b23cd47679e11317dae98` **core_target_triage** — GameOverlayRenderer.dll is a library (code other programs load) for Windows, built for x86 (32-bit). Its internal names were removed (stripped), so most functions will have generated names. (Seen it)
- `ev_d2b04586e092e0ddd66a03c0d272fc027930c142e32abe83f0f48ed52770c8f4` **core_target_triage** — codex.dll is a library (code other programs load) for Windows, built for x86 (32-bit). It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (Best guess)
- `ev_4c06408a76b7571dd799180ade2672135844b84f0f63a68b43d75c671ac04de6` **core_target_triage** — config.cdx is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (Best guess)
- `ev_9e39e5c8ef1bc8256794bb3db45b9ac3b15655428e004b2f508437f6d7c58ee1` **core_target_triage** — config.exe is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (Best guess)
- `ev_0b468aeb94d957d4b7c3b732c5a4c2b8b8bc573688a87c3097988e0e37d9063a` **core_target_triage** — cossacks.cdx is a program for Windows, built for x86 (32-bit). It looks like it was made with Delphi or C++Builder. It appears to be packed or protected (Compressed or encrypted code), so most of its real code is hidden until it runs. Its internal names were removed (stripped), so most functions will have generated names. (Best guess)
- `ev_157a40d6bda3ffbdd8e925ee1ee5a254e8c08c6732ada2f33eda4d67afa54536` **core_archive_show** — dlcs (directory) holds 67 files in 95 entries; 0 nested container(s). (Seen it)
- `ev_392885a608730538a874722dbd0c6e6b3e0ad14e030c533695e835f47aa829b8` **core_target_triage** — yacht.oss isn't a format we recognise yet. (Best guess)
- `ev_0bbb20c11bb3e0ce0d9c17d0fa68816cf348ae46d0d3a2dbc029019e27d0d136` **core_target_triage** — yacht.osm isn't a format we recognise yet. (Best guess)
- `ev_6a6b0380c96f96da8d583413f39352e7b4b1f054532df69124760c6ddbf5a71f` **core_target_triage** — yacht.aaf is a text file (a script, notes or settings). (Best guess)
- `ev_e5ad6408513ec3e68c34d45050fb1767652d6ec5719e683f4c4bea9235d4e401` **core_target_triage** — yacht.acl is a text file (a script, notes or settings). (Best guess)
- `ev_e6d0e8ed6fb17e7938852a8b41caafa7b4490ebb3a7712c138992552af18d37c` **core_target_triage** — peaukr.dds isn't a format we recognise yet. (Best guess)
- `ev_8a85c8fda7e27db24f770d1cd39cd942d47e6d4022b0cc31f307f481c0b9a5dd` **core_target_triage** — brush_plt_11x11_2.pattern isn't a format we recognise yet. (Best guess)
- `ev_f83c16806d851021c8bdad2286ca258d4b3d0b123045f8f6681f30794ba9789a` **core_target_triage** — source.pfx is a text file (a script, notes or settings). (Best guess)
- `ev_2a22f2c26a504184317be4b4bcb2d13431a88c4855f866e159d7a94e711bbdcf` **core_target_triage** — actors.lib is a text file (a script, notes or settings). (Best guess)
- `ev_e193827ab6f814f11354185ab565650f043a9753171c817b36aa71874b6f26f2` **core_target_triage** — cloudy.hdr.tga isn't a format we recognise yet. (Best guess)
- `ev_16c59dcb88b1270140084e9862fff432e8d559c9aaccde75c2183ad88193333a` **core_target_triage** — ausmis1.map isn't a format we recognise yet. (Best guess)
- `ev_ec56dfb728186b791291413eeba9e87fc94f2495546ee01558db2bee11c58405` **core_target_triage** — ausmis1.aix is a text file (a script, notes or settings). (Best guess)
- `ev_a5250a007160d6f82705af3103157ab7c95e78dd79ee816983c8492b31347e54` **core_target_triage** — particles.mat is a text file (a script, notes or settings). (Best guess)
- `ev_1b10c801d63ba1cb6053c07010f4d0b50495ff390a20e0c543c2940a791b19bd` **core_archive_show** — Cossacks 3 (directory) holds 13070 files in 17528 entries (listing cut short by a limit); 0 nested container(s). (Seen it)
- `ev_43b589eb7a9399b6087f9b1acbab29499f6778193ce4b8919b65214df27fa8fe` **core_target_triage** — polmis1.aix is a text file (a script, notes or settings). (Best guess)
- `ev_1945338e30b07a3c7407e25237c2ebecb0c4ec84b28c4150361266d8d5e5ffd3` **core_text_read** — polmis1.aix: lines 1–21 of 21 (UTF-8). (Seen it)
- `ev_b39facc658be74a3bc482100a7bebee9027676fc3c562c14da260c4d5850f282` **core_target_triage** — netmis4.aix is a text file (a script, notes or settings). (Best guess)
- `ev_e952748499247e9267b24575f6dc5c25bc00d8d156a9f65d36acd7717c232c68` **core_text_read** — oninit.inc: lines 1–5 of 5 (UTF-8). (Seen it)
- `ev_79424d3a59928f76f0f2bdc4b50777f5831c2b3cba358db49a59b2f9e588eab0` **core_archive_show** — data (directory) holds 2894 files in 17258 entries (listing cut short by a limit); 0 nested container(s). (Seen it)
- `ev_c8184e3b5711fe5ede34006c4169e281a9fca41d67fdf548a9728e91de25e3b9` **core_target_triage** — scemis8.map isn't a format we recognise yet. (Best guess)
- `ev_ce4ab47c501375838060ac04b7c248bec377e82daf7a5f681c06152b02cd52e5` **core_text_read** — turmis1.aix: lines 1–29 of 29 (UTF-8). (Seen it)
- `ev_04b61c03e16a53c9d67d07cedbc8812f6f3f33796dcf4e00367492af48693326` **core_text_read** — netmis4.aix: lines 1–32 of 32 (UTF-8). (Seen it)
- `ev_f832c2f29caefdac099894abd9c0404928841daa81025def793991eb6441f118` **core_text_read** — units.cfg: lines 1–14 of 14 (UTF-8). (Seen it)
- `ev_e350e5343dc29b1559a50058fc03717713697e925c727d517757b8db70056cf1` **core_text_read** — hotkeys.cfg: lines 1–243 of 243 (UTF-8). (Seen it)
- `ev_81649d69eca1820766da26af85dcb2bef5972439e97e23dfefa2d0f84ff50cc4` **core_text_read** — dogeneratemissionmap.inc: lines 1–9 of 9 (UTF-8). (Seen it)
- `ev_f490ebb991f41f348483c8ec7e67fa12b58f19a37c21f6cd28807d2c879a94bd` **core_text_read** — random.cfg: lines 1–3 of 3 (UTF-8). (Seen it)
- `ev_4bad72235a3c50b35b9b402c393610a3dcee1c1079ef4ed93d5c6ffcbe350e7a` **core_archive_show** — Cossacks 3 (directory) holds 533 files in 17528 entries (listing cut short by a limit); 0 nested container(s). (Seen it)
- `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` **core_overview_show** — PE (Windows) executable for x86 with 18918 functions, 12073 strings, 746 imports from 18 libraries. Function discovery stopped at an analysis limit, so the function list is incomplete. (Worked it out)
- `ev_56bf069fe35f727f42879e6286a64ce2b58936369f6818baffd8a1c7cc6d3b8a` **core_text_read** — generator.cfg: lines 501–1000 of 2367 (UTF-8). (Seen it)
- `ev_0a9f0a9f852919ab43e10c45d7bc6db4cc2f381009fd8556e6dacc2b91fd6226` **core_text_read** — extract_map.py: lines 1–157 of 157 (UTF-8). (Seen it)
- `ev_d0796165851e64a57451b428c6072007b2aba0d7c28ebbba459812ced952eb2e` **core_text_read** — gen_variant_maps.py: lines 1–400 of 876 (UTF-8). (Seen it)
- `ev_a2c1ea36d1b9ae6291daebfece8116360ce70a7c5d4e497bbfae9406993fd17f` **core_text_read** — generator.cfg: lines 1–500 of 2367 (UTF-8). (Seen it)
- `ev_bd4dc176de0eb461bfee69e52e7fc061fafa35647d5798ad9bdef1a7fbcee676` **core_archive_show** — Cossacks 3 (directory) holds 13070 files in 17528 entries (listing cut short by a limit); 0 nested container(s). (Seen it)
- `ev_5b735a491cc638691498fe03747ea46d507f784402ed40fa0557c5a30f9227f1` **core_evidence_browse** — Part of core_overview_show evidence (page). (Worked it out)
- `ev_039ade7462bea574789ce4617a465d5350a546d9cc768c64197f3fb0bcc5682f` **core_text_read** — generator.cfg: lines 1001–1500 of 2367 (UTF-8). (Seen it)
- `ev_2a19190c52e2532f76afd068ae8753ced5edaf8313dca8e515925eb4cfd18da0` **core_evidence_browse** — Part of core_overview_show evidence (page). (Worked it out)
- `ev_9d5c3373b6536dfd8a3ea220137ad3d2e2c5cd70eeb6ed1bfddcd99bbf564f82` **core_text_read** — generator.cfg: lines 1501–2000 of 2367 (UTF-8). (Seen it)
- `ev_ab4e90a4b48d41eb1e70bf16cd08b09c0a5064a51dd9122ef2abb6ad3fd29745` **core_text_read** — generator.cfg: lines 1801–2050 of 2367 (UTF-8). (Seen it)
- `ev_ee0d5f4fbaa45f269796f84c489e5969b66a791d5c6a792517d20dcb612da9d8` **core_text_read** — generator.cfg: lines 2201–2367 of 2367 (UTF-8). (Seen it)
- `ev_dc829d28cac0bfe05fca12630f1b55821dd06a610387c59831407969264a6200` **core_text_read** — generator.cfg: lines 2001–2250 of 2367 (UTF-8). (Seen it)
- `ev_6f9dc93cd994b3359d88e75b1a5e4b38f5563707bf3b476a78e103e290076dfd` **native_strings_find** — 2 strings match "generator". (Seen it)
- `ev_03b86831aed9dc64fd16a5bec433590858eac2ff6d3a1da148c3e0b4448ffaf4` **native_strings_find** — 0 strings match "morale". (Seen it)
- `ev_74b5910c371b143e7077790725d71b70af4037589f35d209458d31bd7f74c64e` **native_strings_find** — 2 strings match "formation". (Seen it)
- `ev_49a306dcd7f302588593650801438185264a1e26e0b34a4c41f7f747de6e3c4d` **native_strings_find** — 1 strings match "AStar". (Seen it)
- `ev_cbff893fe3af1614ce719b081c25ad70cb8386fbf3f4af4e97b57d8529beb254` **native_strings_find** — 0 strings match "terrainmask". (Seen it)
- `ev_8c22d94c90b5befacd858f15d6ef63a07bd573949dc3900015585e1136d88c99` **native_strings_browse** — 12073 strings (showing 15). (Seen it)
- `ev_ec5fbf04b4598be4a6439fedc7e43da23a89e56fe21db5279c7bb12897beaeb3` **core_feature_find** — "Generator": 2 matching strings, 0 matching function names, 0 matching imports; 0 functions involved. (Worked it out)
- `ev_828041581ef4354a18af34e47e72abf429006b029c35b15550df3123d6625654` **core_feature_find** — "Morale": 0 matching strings, 0 matching function names, 0 matching imports; 0 functions involved. (Worked it out)
- `ev_0639ec88adf0b10706411c1dcd965a5e6c56f531fca20f0c10a37e13e8ed8b01` **core_text_read** — dogenerate.inc: lines 1–400 of 2103 (UTF-8). (Seen it)
- `ev_98f8c05d5a2c73580d1257b416a5fec048f16f9fa2f0bd1f02d94eb7c7c80d7f` **core_text_read** — dogenerate.inc: lines 401–800 of 2103 (UTF-8). (Seen it)
- `ev_dad5bcfba0d6e855afd3153aec66c17c196fabc0403225c8f161ccfd87eae6a6` **native_bytes_find** — 2 match(es) for utf8 in scemis8.map; showing 2 from #0. (Seen it)
- `ev_3e7c86bd8241a8aa5553f75a6fef0a25d059a462ebfb526823d976b1de852112` **native_bytes_find** — 2 match(es) for utf8 in scemis8.map; showing 2 from #0. (Seen it)
- `ev_d6997ede24b2208b8bcd2e7a5e11c0c017fff343f9682e1287cd2dd34d041ef8` **native_strings_find** — 437 strings match "X[A-Z][A-Za-z0-9]{3,}". (Seen it)
- `ev_726ac2a5f99b790c2284ad16377e409d558acc4a2514abde819a7b04c8633ee5` **native_bytes_find** — 1 match(es) for utf8 in scemis8.map; showing 1 from #0. (Seen it)
- `ev_c3804981595ae8e32f7250a675c54ac38863fa5625a8409059224652a93981f4` **core_feature_find** — "SetRandomKey": 0 matching strings, 0 matching function names, 0 matching imports; 0 functions involved. (Worked it out)
- `ev_d3600c5c1e4770f93dd3d3e4c625349fe4fa0cd159b19b5e6f43bc55fdf04a48` **native_bytes_find** — 1 match(es) for utf8 in scemis8.map; showing 1 from #0. (Seen it)
- `ev_b666952059a38ce731ca4f69dc6fed6aef3fd7c091c2cd35277e21e7b6612d82` **native_strings_find** — 31 strings match "Map". (Seen it)
- `ev_440b9c16a0fc4f231b070b255d6b2c5f127615839f01b9bad5916315b08d2f3b` **native_bytes_find** — 1 match(es) for pattern in scemis8.map; showing 1 from #0. (Seen it)
- `ev_33561ae3050f4498e4d94896c50762a89456113bf3f174fa261d29313e25528a` **native_strings_find** — 3 strings match "Castle". (Seen it)
- `ev_349ae770ab369af910546678aaf8cd3252404920ddcf0c66063a54ed65e2b475` **native_strings_find** — 7 strings match "Path". (Seen it)
- `ev_a55f11205a94e89b311e75b7510970b5d670fb12e12ce91c788aa22b00ed4812` **native_strings_find** — 0 strings match "Regiment". (Seen it)
- `ev_e1251d58d4982d66554a317822ff0f44346fdaad90c9683b36d094239ae5fff2` **native_strings_find** — 111 strings match "^[?&]*X[A-Z][A-Za-z0-9]{2,}". (Seen it)
- `ev_d9c6e28bcfbe87f1ca6233632d24e92b7e4a56b545a35343ef92de0bd4af5457` **native_strings_find** — 474 strings match "^[?&]*T[A-Z][A-Za-z0-9]{3,}". (Seen it)
- `ev_238c8015b7909d79fa22c73b8a440ac86b817dffbd2fda074063e1d4ec6ba92f` **native_strings_find** — 111 strings match "^[?&]*X[A-Z][A-Za-z0-9]{2,}". (Seen it)
- `ev_f7f8bad9ab99d48bfa7e78c66e92965444423072af19486d5f85c3df22f9569e` **core_text_read** — dogenerate.inc: lines 1521–1740 of 2103 (UTF-8). (Seen it)
- `ev_e72294ce3edb761f849f5e900d32a0951d094917eec607fcfa254f99da452471` **core_text_read** — dogenerate.inc: lines 1291–1510 of 2103 (UTF-8). (Seen it)
- `ev_f8852bf57f34fc0635b76128a3ad3343641c0badc4529661b6c38a8bf442b539` **core_text_read** — DLC_INVENTORY.md: lines 1–49 of 49 (UTF-8). (Seen it)
- `ev_529cd3776e1191662a9ed491776a5836c6363ae4ac08f2d5cabca0e40d977d16` **native_functions_list** — 18918 functions (showing 15). (Worked it out)
- `ev_cf45b67d51003ced50e34b955a7dbd8de0435bec162d32ebed9b8ee2d5d83dab` **core_text_read** — hotkeys.cfg: lines 1–120 of 243 (UTF-8). (Seen it)
- `ev_75d79f606f70a384d7f12c61c39560186e24a27f95005fae8c46ce36d5796417` **core_text_read** — menu.cfg: lines 1–35 of 35 (UTF-8). (Seen it)
- `ev_90e09594c96923667d9e73c18e67e19a0ccfb7d0fadef7aecccbee4ba78cd3db` **core_text_read** — gui.txt: lines 1–120 of 937 (UTF-8). (Seen it)
- `ev_16e3cc42cc5ba9a0e0d3497312ec0397728e4757317053dab036befae593f79f` **core_text_read** — dogenerate.inc: lines 1901–2103 of 2103 (UTF-8). (Seen it)
- `ev_bb8041b65d295d042902dab88f937cc45a997e7aebc2efbb8b5406095263c3fd` **core_text_read** — dogenerate.inc: lines 1951–2103 of 2103 (UTF-8). (Seen it)
- `ev_a44201a25014c06c823b93c3c362b3801771a188373d708c85b86c1a22cb23c5` **native_function_pseudocode** — Pseudo-C for sub_401000 (202 lines, partly unstructured). (Best guess)
- `ev_c7d983f3b81252b8bf4f816d1d14293c1d3cc838f5eb7a9c0170ba8ddbce85e7` **core_text_read** — dogenerate.inc: lines 961–1220 of 2103 (UTF-8). (Seen it)
- `ev_1e8bf9a955c1220149060605d0a5b34443040df8df65a13de9f1f98c3621920b` **core_text_read** — menu.cfg: lines 1–35 of 35 (UTF-8). (Seen it)
- `ev_e00fea8c4b9b68117bca04a9d8aa229b6a9bd4dbed632882b730ee97ab55d170` **core_text_read** — initmapgen.inc: lines 1–289 of 289 (UTF-8). (Seen it)
- `ev_b7e35c260fef8279c6e2e54c8862f70b54e8de591e5cf15aa88279f01a9085d0` **core_text_read** — donewgame.inc: lines 1–120 of 171 (UTF-8). (Seen it)
- `ev_2c4d3cf46caa79adf1fc5e5ddb90965f809cf3f6a7093d617d27bcc85fb3495c` **core_text_read** — envscales.cfg: lines 1–200 of 869 (UTF-8). (Seen it)
- `ev_6b77a40231bc73767eb113d8fb47091d24bf21c87dfb6e1bf24bf044c73928c3` **core_text_read** — startingsettings.cfg: lines 1–120 of 3424 (UTF-8). (Seen it)
- `ev_2f2f15d9978753481d7bc5524ba311bcedd404b14be13db732763876a120975c` **core_text_read** — formations.cfg: lines 1–300 of 2307 (UTF-8). (Seen it)
- `ev_b0e5246a12e6fe1f1f18eb1d22acaecc02b13dc00be18a25c6c3fddd9eb15df8` **native_function_pseudocode** — Pseudo-C for FUN_00404628 from the Deep engine (41 lines). (Worked it out)
- `ev_4758c6cc7e573d6f09555c08684e28e2834cdcc92364853923ecd472de0931ad` **core_archive_show** — Cossacks 3 (directory) holds 22 files in 17528 entries (listing cut short by a limit); 0 nested container(s). (Seen it)
- `ev_7d1a56964099b20383ca660c2162b2d45c489e5ae30da1e8836213059ad0c81e` **core_text_read** — hotkeys.cfg: lines 121–243 of 243 (UTF-8). (Seen it)
- `ev_24a1cc1aed9646c2f96f6b4840f8a65eea72844486f61b443aeb6b5be2de8cd4` **core_text_read** — formations.cfg: lines 809–878 of 2307 (UTF-8). (Seen it)
- `ev_9f9d6302c5ce9953316a8040063e7d470868f018f45bc5252c3d64f4a12d2178` **core_text_read** — formations.cfg: lines 1–60 of 2307 (UTF-8). (Seen it)
- `ev_c1b8dc956703864d06789244eefc4b67e9a430c3ed237bfff8f1a9585e0a18a2` **core_text_read** — formations.cfg: lines 1–2000 of 2307 (UTF-8). (Seen it)
- `ev_7a4ce54050b712fdb4472d6b73331d7084ea27e6eb5adebf6de3f9fe968f65d1` **core_text_read** — formations.cfg: lines 2001–2307 of 2307 (UTF-8). (Seen it)
- `ev_5362cb79a3f8587392984555c63f8ed76fb29f10bae1913c30873085e1de887b` **native_strings_find** — 2 strings match "ortho". (Seen it)
- `ev_3a71ccb90786f19d3960ed53e8186e4978fb0ced0bbd8ebe4bedc2f99e242eea` **native_strings_find** — 4 strings match "camera". (Seen it)
- `ev_d106ada25c33c205cf3d6df1f19c82bd953681db13b0a70b806e06eb0a75054a` **native_strings_find** — 2 strings match "D3D". (Seen it)
- `ev_870074e4f0ef6e459c336493772445d36608d1471f8be4da7928baee6728e4f0` **native_strings_find** — 8 strings match "vertex". (Seen it)
- `ev_484b3f93a0effd88d6adfc7e2c29c70a3f0e8039f1c932314a71f5d6792606bd` **native_strings_find** — 6 strings match "shader". (Seen it)
- `ev_f9cd77bfe001532cde861fba504526e7cc0fc0df1d2affa410bf48a63998d383` **native_strings_find** — 3 strings match "fog". (Seen it)
- `ev_3bc31a1c3615193c455e4a91393ba996b65e5e387640b52d75ab041e10b6556e` **native_strings_find** — 3 strings match "shadow". (Seen it)
- `ev_670048a7fe2f3fbf290542d35cbd3c48cde2bb838520906bb43481698ba596ce` **native_strings_find** — 2 strings match "XWorld". (Seen it)
- `ev_800d07f5a716d1067a872f72904b0b840b5fa4f9501b1b7fb88eb4f1e3470427` **native_strings_find** — 3 strings match "XTile". (Seen it)
- `ev_c2e75a9e58721edd7f1a23ce94aa590e2d2d49d70aa777ed669c57480fca4e2b` **native_strings_find** — 1 strings match "XFOWRender". (Seen it)
- `ev_708f3b1fa7d1a034a781feb7b86ba1759855a8c673259fae9a7c2009fa2873c8` **native_strings_find** — 6 strings match "render". (Seen it)
- `ev_fdc530d7c6976391274b145ab8b6d0009e8411c4d194515437c6c25280871213` **native_strings_find** — 0 strings match "projection". (Seen it)
- `ev_6ce2723672a15ec785a686ef288be3993bd65fa7bdbee32aa4d3fa4bb025b336` **native_strings_find** — 1 strings match "perspective". (Seen it)
- `ev_b79d96aa18a85d0e15f9d6f950db6614da720970f662c0e93fdf5f02b6b5cadf` **native_strings_find** — 0 strings match "D3DX". (Seen it)
- `ev_53047fbca9c5d95581de503cf675e4e3db61115ef9fb805a4ae7e162a8ea5d58` **native_strings_find** — 0 strings match "CreateDevice". (Seen it)
- `ev_93ac2f615213c16f680fc4303b1d5928f451f2af5fedd0bae3b3002d69e6ef41` **native_strings_find** — 0 strings match "SetTransform". (Seen it)
- `ev_1985321e54d50c6a829c3e2ff01d91761e8194b2c0e93c76fb6e825b3ce39dd9` **native_strings_find** — 21 strings match "Light". (Seen it)
- `ev_f728c3f909871a953e7a56d631f2a64ba17f398c4e9487a4d650de1f34b25649` **native_strings_find** — 7 strings match "Texture". (Seen it)
- `ev_b2362c50ddc575d82077f4d0dc11530e24a045a9b13d77c3b9a858d704640a53` **native_strings_find** — 5 strings match "Mesh". (Seen it)
- `ev_a677748688513a7604a02eae7b7725c03c64b9dccba78b059ff91b3856062ab9` **native_strings_find** — 5 strings match "Material". (Seen it)
- `ev_d793693a3383e863e8281b135ba35c7c40ff3e6a563ceafb9c429de1f000b351` **native_strings_find** — 2 strings match "Sprite". (Seen it)
- `ev_ba6f3303d5f8bebca7bd7710ec71a84dbb2411f9f8badafc69820efbd02156dc` **native_strings_find** — 0 strings match "Billboard". (Seen it)
- `ev_e0795ff467236b68f3df5263481d0b0106a445cf37f8a9ff7a94b1ad9adc7adc` **native_strings_find** — 3 strings match "viewport". (Seen it)
- `ev_a4e01f800def34d2259f7b73a91ebd8cf43aa44efd71e1cb692141d4f577d514` **native_strings_find** — 2 strings match "frustum". (Seen it)
- `ev_4f0260708c1d04f1f5325724f28151d2a87452ab868a9468df07631c42153c40` **core_archive_show** — cameras (directory) holds 4 files in 4 entries; 0 nested container(s). (Seen it)
- `ev_300774a0e84c7ed0747cfd65a4d4736223fe01f43b1c8fcdfd4787646979ece7` **native_strings_browse** — 773 strings (showing 773). (Seen it)
- `ev_3e2611e359460b629cb1db1efd163e47f801a92f72130b2ecdcddcd9325bea5f` **native_name_xrefs_list** — glOrtho (0x907c48) is referenced from 2 places. (Worked it out)
- `ev_cc0ee18b3825c0168423c9c077becad0299ad47c7bdd3aa95aa7016cb9131d5d` **native_name_xrefs_list** — glFrustum (0x907c98) is referenced from 2 places. (Worked it out)
- `ev_c694939291946a2c756cdd05a85c18430c9f5f96b0ec03f64325517d5fca7dac` **native_name_xrefs_list** — gluPerspective (0x907b84) is referenced from 0 places. (Worked it out)
- `ev_9974b6a2da79fdd18197f61b662c3b9789868c24341644e277617747da3cb277` **native_name_xrefs_list** — gluOrtho2D (0x907b88) is referenced from 2 places. (Worked it out)
- `ev_d3d1bb1f7244e9fcd9e8363572a271bb1f3118f72d5c88feda92d629c795f218` **native_name_xrefs_list** — glViewport (0x907cec) is referenced from 9 places. (Worked it out)
- `ev_31440db6aa51fcfd4ab12dd9275e323ed448fadcb2c9858d7e9aadaaeb5083cc` **native_name_xrefs_list** — No function, symbol or import is named XRenderer. (Worked it out)
- `ev_cab2e1dfa51bf9fdf29fa7ba23f587086202d4d7c26b04017add7e457db74514` **native_name_xrefs_list** — glFogf (0x907ca4) is referenced from 0 places. (Worked it out)
- `ev_ff36e95fc8e7f303907b30f9efd4db37fb7e79e7c47b8dbaf98555cb03bdab65` **core_archive_show** — cameras (directory) holds 4 files in 4 entries; 0 nested container(s). (Seen it)
- `ev_38a2b1dfac404cf00629c85803979d45bac53cfe1fc211461186c4712da9de70` **core_text_read** — camera.cfg: lines 1–65 of 65 (UTF-8). (Seen it)
- `ev_8ea51abbe74a2ba608bf4c7d3b875c47e2860a822632d9bb166ba43b56245dc3` **core_text_read** — cameradebug.cfg: lines 1–63 of 63 (UTF-8). (Seen it)
- `ev_9a0fa20fc7a7bcc41bbf15d94db24a0545d580b13e1270e764324efeac5254e7` **core_text_read** — camerascreenshot.cfg: lines 1–69 of 69 (UTF-8). (Seen it)
- `ev_b57ab2cee4bf96ce92af3e6378e9f8290ddff9c7925317d4fe146435620725c3` **core_text_read** — default.cameras: lines 1–96 of 96 (UTF-8). (Seen it)
- `ev_5996e80ca396035e46edbd9d17c65b31fc7a7284c27c727aef7eb4d2593f8dc5` **native_functions_decompile** — Decompiled 1 of 1 functions. (Best guess)
- `ev_1846072273e01d74b54413d77c6f75451cfa1a498fed91efb4cfa01c3af08d6f` **core_archive_show** — shaders (directory) holds 109 files in 112 entries; 0 nested container(s). (Seen it)
- `ev_82034aa06f3d913c52d44e6c25b492cfbc35d8f406c0ad8b2fecda784382d847` **core_archive_show** — terrain (directory) holds 607 files in 616 entries; 0 nested container(s). (Seen it)
- `ev_d1e4ceb05a2c9dabc7fb446bb46845864532484440972d6063deb0f291ca9136` **core_archive_show** — materials (directory) holds 866 files in 899 entries; 0 nested container(s). (Seen it)
- `ev_31e62499eaacda4f892399f5772d898f5e42939e30fe9357c239480e737935a1` **native_name_xrefs_list** — Direct3DCreate9 (0x907e3c) is referenced from 0 places. (Worked it out)
- `ev_b5efb0c8e9c69c7dc91084bb500c31b5b6cdf8e706bfac11e255bfff874b25f6` **core_archive_show** — shaders (directory) holds 109 files in 112 entries; 0 nested container(s). (Seen it)
- `ev_030b5413491f9f2547e33ed38ca291dcffee5d1a02e5cf7bb2d739bae5099481` **core_text_read** — hf.pvl.sm.vert: lines 1–50 of 50 (UTF-8). (Seen it)
- `ev_82903f6e47bdf805468adadea80d573d048e3e4cef6fbdb14b3e3ce09d985fc0` **core_text_read** — hf.pvl.smx9.frag: lines 1–56 of 56 (UTF-8). (Seen it)
- `ev_a5296bd9f61f77ed28ba2d5e7ccf4842dfcf9711614ca5e605397907432b0001` **core_text_read** — tbn.sm.id4.vert: lines 1–37 of 37 (UTF-8). (Seen it)
- `ev_38033e7af5bd8f33d8f9281ea940596d7e40bfa1c20f58359c340a66c6327986` **core_text_read** — def.pvl.sm.vert: lines 1–46 of 46 (UTF-8). (Seen it)
- `ev_3c0fb95e6f9a165dcbfa51b8198839fc58b21f1b808bd346e58a23cbff6fe936` **core_text_read** — water.frag: lines 1–120 of 255 (UTF-8). (Seen it)
- `ev_1f58e44e3386c5bcdab7228a53332179d2e3d5ddcdd77d487c503704e1bfb299` **core_text_read** — tone.frag: lines 1–25 of 25 (UTF-8). (Seen it)
- `ev_b38315fb48ed22463c262b7dfce7c3584a4dfe65c4eccfbbe55a6a44c339220a` **core_text_read** — camera.cfg: lines 1–40 of 65 (UTF-8). (Seen it)
- `ev_49f2ee8c41081088f19b34dc07c04483f48a05c83c7b67847390d36bd36e8860` **core_text_read** — default.cameras: lines 1–40 of 96 (UTF-8). (Seen it)
- `ev_309bbbc5aa0910084d91442ceb96ed07bea9f3c629071c6fa2d9e09168c3b569` **core_text_read** — hf.pvl.sm.vert: lines 1–40 of 50 (UTF-8). (Seen it)
- `ev_383d4d0238d2c66eb43ff99c9e0bfb4953fa880a6d61af60ade931e7f529120b` **core_text_read** — hf.pvl.smx9.frag: lines 1–40 of 56 (UTF-8). (Seen it)
- `ev_c04b0a995ab4aea83690a3ee7145f48d3d0e02356165c7811f269e1889d26add` **core_text_read** — tbn.sm.id4.vert: lines 1–37 of 37 (UTF-8). (Seen it)
- `ev_bd3c28f2446d0202d84180681617920dbc85d54845de0a5fc362bae674a4e371` **core_text_read** — water.frag: lines 1–40 of 255 (UTF-8). (Seen it)
- `ev_93eac33458faf3c21072d9c8fe8c5821eecdcf13adccd7d3aa301b3f77b5e29d` **core_text_read** — tone.frag: lines 1–25 of 25 (UTF-8). (Seen it)
- `ev_6386775d57fcd7148a2e903fb91e641c8119318477c911afe4f7c45e5fd78d01` **core_text_read** — shaders.lib: lines 1–120 of 1813 (UTF-8). (Seen it)
- `ev_b58bb25b101db9133d3a8463d949e1397522cd2fc5afc7f6657baec78c173e10` **core_text_read** — camera.cfg: lines 1–5 of 65 (UTF-8). (Seen it)

