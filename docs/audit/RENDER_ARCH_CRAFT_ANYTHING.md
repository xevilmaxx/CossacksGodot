# Rendering architecture — Craft Anything binary/shader evidence (R-ARCH-CA)

**Agent:** R-ARCH-CA (Cossacks 3 → Godot port swarm). **Date:** 2026-11-21.
**Source of truth:** one Craft Anything session, donor target `C:\Games\Cossacks 3`,
`cossacks.exe` target `t_87f0f3c130b0` (sha256 `87f0f3c130b0…`).
**Constraints honoured:** private use only; read-only; no donor executable was ever run;
no donor asset was copied into this repo. Deep mode was used for static decompilation only.

Companion doc for the *configuration-only* camera parameter table:
[`RENDER_ARCH_CAMERA.md`](RENDER_ARCH_CAMERA.md). This doc adds the binary and shader
pipeline evidence and the 2D-vs-3D verdict.

---

## 1. Evidence ledger used (Craft Anything ids)

| CA evidence id | What it is |
|---|---|
| `ev_300774a0e84c7ed0747cfd65a4d4736223fe01f43b1c8fcdfd4787646979ece7` | full `.idata` import/string table of `cossacks.exe` (773 strings) |
| `ev_31e62499eaacda4f892399f5772d898f5e42939e30fe9357c239480e737935a1` | `Direct3DCreate9` xref query — 0 call sites |
| `ev_5362cb79a3f8587392984555c63f8ed76fb29f10bae1913c30873085e1de887b` | `ortho` string hits (`gluOrtho2D`, `glOrtho`) |
| `ev_3e2611e359460b629cb1db1efd163e47f801a92f72130b2ecdcddcd9325bea5f` | `glOrtho` xrefs (2) |
| `ev_cc0ee18b3825c0168423c9c077becad0299ad47c7bdd3aa95aa7016cb9131d5d` | `glFrustum` xrefs (2) |
| `ev_9974b6a2da79fdd18197f61b662c3b9789868c24341644e277617747da3cb277` | `gluOrtho2D` xrefs (2) |
| `ev_c694939291946a2c756cdd05a85c18430c9f5f96b0ec03f64325517d5fca7dac` | `gluPerspective` xrefs (0) |
| `ev_5996e80ca396035e46edbd9d17c65b31fc7a7284c27c727aef7eb4d2593f8dc5` | Deep pseudo-C of `sub_4cd334` (projection setup, 286 lines) |
| `ev_238c8015b7909d79fa22c73b8a440ac86b817dffbd2fda074063e1d4ec6ba92f` | 111 `X*` Delphi RTTI class names |
| `ev_3a71ccb90786f19d3960ed53e8186e4978fb0ced0bbd8ebe4bedc2f99e242eea` | `camera` strings (`XCamera`, `XCameraTrack`, `IXDScriptCamera`, `GetCameraByName3DS`) |
| `ev_800d07f5a716d1067a872f72904b0b840b5fa4f9501b1b7fb88eb4f1e3470427` | `XTile`, `XTileSmooth`, `dXTileSeason` strings |
| `ev_c2e75a9e58721edd7f1a23ce94aa590e2d2d49d70aa777ed669c57480fca4e2b` | `XFOWRender` string |
| `ev_38a2b1dfac404cf00629c85803979d45bac53cfe1fc211461186c4712da9de70` | `data\cameras\camera.cfg` (full, 65 lines) |
| `ev_b57ab2cee4bf96ce92af3e6378e9f8290ddff9c7925317d4fe146435620725c3` | `data\cameras\default.cameras` (full, 96 lines) |
| `ev_9a0fa20fc7a7bcc41bbf15d94db24a0545d580b13e1270e764324efeac5254e7` | `data\cameras\camerascreenshot.cfg` (full) |
| `ev_8ea51abbe74a2ba608bf4c7d3b875c47e2860a822632d9bb166ba43b56245dc3` | `data\cameras\cameradebug.cfg` (full) |
| `ev_b5efb0c8e9c69c7dc91084bb500c31b5b6cdf8e706bfac11e255bfff874b25f6` | `data\shaders` folder census — 109 GLSL files in 112 entries |
| `ev_6386775d57fcd7148a2e903fb91e641c8119318477c911afe4f7c45e5fd78d01` | `data\shaders\shaders.lib` (first 120 of 1813 lines) — shader registry |
| `ev_030b5413491f9f2547e33ed38ca291dcffee5d1a02e5cf7bb2d739bae5099481` | `obj\hf.pvl.sm.vert` (heightfield vertex shader, full) |
| `ev_82903f6e47bdf805468adadea80d573d048e3e4cef6fbdb14b3e3ce09d985fc0` | `obj\hf.pvl.smx9.frag` (heightfield fragment + 9-tap PCF shadows, full) |
| `ev_a5296bd9f61f77ed28ba2d5e7ccf4842dfcf9711614ca5e605397907432b0001` | `obj\tbn.sm.id4.vert` (tangent-space normal mapping, full) |
| `ev_3c0fb95e6f9a165dcbfa51b8198839fc58b21f1b808bd346e58a23cbff6fe936` | `water\water.frag` (dynamic reflective water, first 120 of 255 lines) |
| `ev_1f58e44e3386c5bcdab7228a53332179d2e3d5ddcdd77d487c503704e1bfb299` | `tone\tone.frag` (HDR tone mapping) |

---

## 2. Findings (CA finding ids `fnd_27`–`fnd_33`)

### F1 — The camera is a full 3D camera (`fnd_27`, observed)

`camera.cfg` / `default.cameras` contain `TargetX/Y/Z`, `PosX/Y/Z`, `DirX/Y/Z`,
`UpX/Y/Z`, `FocalLength`, `DepthOfView`, spherical orbit limits (`SphereHeight`,
`SphereLength`) and free-rotation tilt angles. `Camera0` has `FocalLength=400`,
`DepthOfView=1200`, `DirZ=-1`, `UpY=1`, camera `PosY≈0.05` against `TargetY=49` — a
steep downward-looking 3D camera, not a 2D scroll offset. Screenshot/debug profiles
vary focal length (95 / 86–100) and tilt (−90…20° / −30…−48°). Dynamic fog keys
(`DynFogStart/End/Density/Power/Offset`) are present, enabled in screenshot mode.
[`ev_38a2b1df…`, `ev_b57ab2ce…`, `ev_9a0fa20f…`, `ev_8ea51abb…`]

### F2 — Renderer API: OpenGL fixed-function 3D, D3D9 present but unused (`fnd_28`, observed)

The `.idata` table contains the complete OpenGL 1.x 3D pipeline: `glVertex*`,
`glNormal*`, `glMatrixMode`, `glMultMatrixf`, `glDrawElements`, `glDrawArrays`,
`glLight*`, `glLightModel*`, `glMaterial*`, `glFog*`, `glGenTextures`,
`glBindTexture`, `glTexGen*`, `glViewport`, `glFrustum`, `glOrtho`, `gluOrtho2D`,
`gluPerspective`, plus `wglCreateContext`/`wglMakeCurrent` and `SwapBuffers`.
`opengl32.dll`, `d3d9.dll` and `Direct3DCreate9` are all imported, but
`Direct3DCreate9` has **zero** code xrefs and there are no `D3DX`, `CreateDevice`
or `SetTransform` strings — OpenGL is the live path. [`ev_300774a0…`,
`ev_31e62499…`, `ev_5362cb79…`, `ev_870074e4…`, `ev_f9cd77bf…`]

### F3 — Projection is selected in code, with perspective/ortho/2D modes (`fnd_29`, derived)

Deep-decompiled `sub_4cd334` branches on a byte at `renderer+0xc8`:

| Mode | Call | Meaning |
|---|---|---|
| one value | `glFrustum(...)` | 3D perspective projection |
| another | `glOrtho(...)` | 3D orthographic projection |
| 2 / 3 | `gluOrtho2D(0,0,0,0)` | flat 2D overlay (HUD) |
| 4 | x87 matrix computation + `glMultMatrixf` | custom projection callback path |

All three projection imports resolve to calls from this one function (xrefs:
`glOrtho` ×2, `glFrustum` ×2, `gluOrtho2D` ×2; `gluPerspective` ×0 — imported but
not called). World geometry therefore goes through a real 3D projection matrix,
with a separate 2D pass for UI. This refutes the "pure 2D sprite compositor"
alternative. [`ev_5996e80c…`, `ev_3e2611e3…`, `ev_cc0ee18b…`, `ev_9974b6a2…`,
`ev_c6949392…`]

### F4 — Engine subsystem names confirm a 3D world/renderer (`fnd_30`, observed)

Delphi RTTI and strings expose `XCamera`, `XCameraTrack`, `IXDScriptCamera`,
`XWorld`, `XWorldViewer`, `XTile`, `XTileSmooth`, `dXTileSeason`, `XFOWRender`,
`XHorizonRender`, `XRenderPool`, `XLightShader`, `XShadowMap`, `XWaterShader`,
`XMeshObjectsLibrary`, `XViewFrustum`, `OSWTextureCombiners`, `OSWMesh` and
`OSWAnimatedSprite`. A resource string references `GetCameraByName3DS`, i.e. a
3DS-style mesh/camera asset path. [`ev_238c8015…`, `ev_3a71ccb9…`, `ev_800d07f5…`,
`ev_c2e75a9e…`]

### F5 — 109 GLSL shaders implement per-pixel lighting, shadows, normal maps and post (`fnd_31`, observed)

`shaders.lib` registers `HeightField`, `ShadersSM20`, `tangentSpace`, `shadowColor`,
`cameraMVM`, `fogMode`, `shadowed`, `texGen`, `postProc` and binds `texUnit0/1`,
`texShadow`. The shader families are `hf.*` (heightfield), `def.pvl.*` /
`build.pvl.*` / `dec.pvl.*` (per-vertex-lighting → per-fragment), `tbn.*`
(tangent-space normal maps), `sm`/`smx3`/`smx9` (shadow-map variants), `env.*`
(environment/reflection), `tree.*`, `unit.*`, `water/*`, `tone/*`, `fx.*`.
`hf.pvl.sm.vert` computes `gl_ModelViewMatrix*gl_Vertex`, Blinn-Phong
ambient/diffuse/specular from `gl_LightSource[0]` and `gl_FrontMaterial.shininess`,
plus shadow coordinates via `cameraMVM`. `hf.pvl.smx9.frag` samples two colour
textures and does 9-tap percentage-closer filtering against `sampler2DShadow`.
`tbn.sm.id4.vert` builds a `mat3(t,b,n)` tangent basis. `tone.frag` does HDR tone
mapping; sibling filenames add SSAO, FXAA, Gaussian blur and depth-of-field.
[`ev_b5efb0c8…`, `ev_6386775d…`, `ev_030b5413…`, `ev_82903f6e…`,
`ev_a5296bd9…`, `ev_1f58e44e…`]

### F6 — Water is a dynamic 3D surface with terrain-height shore blending (`fnd_32`, observed)

`water/water.frag` uses animated `waveMap`, `reflectionMap`, an `hmapTex` with
`hmapMin`/`hmapMax`, large/small wave height and size, soft/glossy specular, depth-
dependent `watercolor`/`watercolor2` and `coast2water_fadedepth`. A comment records
that the real water height "hits terrain" and is visible on shadow. Shorelines are
therefore computed from 3D geometry and a height map at shaded pixel level, not
painted into a 2D tile. [`ev_3c0fb95e…`]

### F7 — Verdict (`fnd_33`, inferred)

The donor is a **low-poly 3D renderer** with an orthographic-leaning / steep tilted
camera, a heightfield terrain, live 3D meshes, GLSL per-pixel lighting, normal
mapping, 9-tap PCF shadow maps, dynamic reflective water with height-map shore
blending, and HDR/SSAO/FXAA post-processing. It is **not** a 2D sprite compositor.
A 2D baked-tile port cannot reproduce its geometry, lighting, shadows or shore
transition; the Godot port needs a 3D (ortho-leaning) rendering mode, or the gap
must be explicitly documented as an accepted approximation.

---

## 3. Hypothesis state

`hyp_1` ("low-poly 3D with an orthographic/isometric camera; ground/water are textured
3D surfaces with per-pixel shaders; the 2D port cannot reproduce the look") was moved
from `testing` to **`supported`** with the 16 evidence ids above, and the note that
"2D sprite compositor" is refuted. The one unresolved nuance is which of the
perspective/ortho branches drives the normal gameplay view.

---

## 4. Open unknowns

| id | Severity | Question |
|---|---|---|
| `unk_a6b4c11945b0a5fa` | medium | Which `renderer+0xc8` value selects the main world view — `glFrustum` or `glOrtho`? `FocalLength=400` fixed suggests a long-lens near-ortho perspective, but both branches exist. |
| `unk_0e66382df3a69687` | low | Is the `d3d9`/`Direct3DCreate9` import a live alternative renderer or dead legacy fallback (0 xrefs)? |
| `unk_48db9a938053a100` | high | Terrain heightfield mesh resolution/LOD and how the `.map` numeric grid becomes vertices for the `hf.pvl.*` shaders. |

---

## 5. Port action implied (for the coordinator, not enacted here)

1. Treat 2D-baked terrain/water as an approximation, not a fidelity target.
2. If a fidelity mode is funded, use Godot 3D with a steep tilted camera and a
   long effective focal length (ortho-leaning), a heightfield terrain and the
   donor's `.dds` albedo/normal masks; port the `hf.pvl`/`hf.smx9` lighting and
   9-tap PCF shadow behaviour and the water height-map shore blend.
3. Preserve the existing 2D path as a fallback; do not delete it on this evidence.
