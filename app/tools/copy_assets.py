# Copies the needed original assets from the installed game into the project.
# Run:  python tools/copy_assets.py [--game PATH] [--dst PATH]
#   (game path defaults to $COSSACKS3_DIR or C:\Games\Cossacks 3)
# Reads only from the game folder; writes only into app/assets/.
# Cross-platform: uses pathlib, forward slashes, no OS-specific calls.
# The converted PNGs and OGGs are already committed in app/assets/, so this
# script only needs to run again when re-copying from another install
# (for example on Linux/macOS with a different game path).
import argparse
import os
import shutil
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve()
APP = HERE.parents[1]
DEFAULT_DST = APP / "assets"
# Portable donor location: COSSACKS3_DIR overrides the historical Windows
# default so existing command lines keep working on Linux/macOS too.
# Donor is private use only — never redistribute its contents.
DEFAULT_GAME = Path(os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3"))

try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False


def ensure(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def copy_rel(game: Path, rel: str, dst: Path) -> bool:
    src = game.joinpath(*rel.replace("\\", "/").split("/"))
    if not src.exists():
        print("MISSING", rel)
        return False
    ensure(dst.parent)
    shutil.copyfile(src, dst)
    return True


def png_color_type(path: Path) -> int:
    """Return the PNG IHDR color type (bytes 25; 2=RGB, 6=RGBA)."""
    with open(path, "rb") as f:
        head = f.read(29)
    return struct.unpack(">B", head[25:26])[0]


def dds_to_png(game: Path, rel: str, dst: Path, max_size=None,
               require_alpha: bool = False) -> bool:
    """Convert a donor DDS to PNG.

    DXT5/DXT3 donor plates carry real alpha.  Historically the committed
    deco_png files were flattened to RGB (IHDR colorType 2) by some older
    step, losing the DXT5 coverage mask.  The donor DDS is private-use; this
    function reads it at bake time and writes only an RGBA PNG into the repo.

    ``.convert("RGBA")`` preserves the donor alpha byte-for-byte (Pillow's
    DXT5 decoder yields the exact alpha ramp).  When ``require_alpha`` is
    set we additionally assert the emitted PNG really is colorType 6, so a
    future accidental ``convert("RGB")`` / post-process flatten can never
    silently reintroduce the bug.
    """
    src = game.joinpath(*rel.replace("\\", "/").split("/"))
    if not src.exists():
        print("MISSING", rel)
        return False
    if not HAS_PIL:
        print("SKIP (Pillow not installed):", rel)
        return False
    ensure(dst.parent)
    im = Image.open(src).convert("RGBA")
    if max_size:
        im = im.resize(max_size, Image.BILINEAR)
    im.save(dst)
    if require_alpha:
        ct = png_color_type(dst)
        if ct != 6:
            raise RuntimeError(
                "alpha-preserving conversion failed: %s is colorType %d "
                "(expected 6 RGBA)" % (dst, ct))
        if Image.open(dst).getchannel("A").getextrema()[0] == \
           Image.open(dst).getchannel("A").getextrema()[1] == 255:
            raise RuntimeError(
                "alpha-preserving conversion failed: %s has no alpha "
                "variation (all 255)" % dst)
    return True


# The seven alpha-bearing env/pfx decals. Source is always private-use donor;
# destination is an RGBA PNG in app/assets/terrain/deco_png/.  Kept as one
# table so the regeneration path and the normal copy loop cannot drift apart.
DECO_SOURCES = (
    ("christmastreed", "data/terrain/decals/env/christmastreed.dds"),
    ("envfieldd", "data/terrain/decals/env/envfieldd.dds"),
    ("envfielddw", "data/terrain/decals/env/envfielddw.dds"),
    ("groundexp0", "data/terrain/decals/pfx/groundexp0.dds"),
    ("groundexp1", "data/terrain/decals/pfx/groundexp1.dds"),
    ("groundexp2", "data/terrain/decals/pfx/groundexp2.dds"),
    ("groundexp3", "data/terrain/decals/pfx/groundexp3.dds"),
)


def regen_deco_pngs(game: Path, dst_root: Path) -> int:
    """Regenerate only the seven deco PNGs, preserving donor DXT5 alpha.

    Verification: each output must be IHDR colorType 6, its alpha array must
    equal the donor's decoded alpha byte-for-byte, and its RGB must equal the
    donor's decoded RGB byte-for-byte (the conversion is a pure re-encode).
    Returns the number of files successfully written.
    """
    from PIL import Image  # noqa: F811 (HAS_PIL already checked by caller)
    import numpy as np
    done = 0
    for name, rel in DECO_SOURCES:
        dst = dst_root / ("terrain/deco_png/%s.png" % name)
        if not dds_to_png(game, rel, dst, require_alpha=True):
            continue
        src = game.joinpath(*rel.replace("\\", "/").split("/"))
        donor = np.asarray(Image.open(src).convert("RGBA"))
        port = np.asarray(Image.open(dst).convert("RGBA"))
        a_ok = np.array_equal(donor[:, :, 3], port[:, :, 3])
        r_ok = np.array_equal(donor[:, :, :3], port[:, :, :3])
        if not (a_ok and r_ok):
            raise RuntimeError(
                "deco round-trip mismatch for %s: alpha=%s rgb=%s" %
                (name, a_ok, r_ok))
        print("regen %-16s colorType=%d alpha%s rgb%s" %
              (name, png_color_type(dst), "OK" if a_ok else "BAD",
               "OK" if r_ok else "BAD"))
        done += 1
    return done


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", default=str(DEFAULT_GAME))
    ap.add_argument("--dst", default=str(DEFAULT_DST))
    ap.add_argument("--deco-only", action="store_true",
                    help="regenerate only the 7 alpha-bearing deco_png files")
    args = ap.parse_args()
    game = Path(args.game)
    dst_root = Path(args.dst)
    if args.deco_only:
        if not game.exists():
            print("game folder not found:", game)
            return 2
        n = regen_deco_pngs(game, dst_root)
        print("done: %d deco PNG -> %s" % (n, dst_root / "terrain/deco_png"))
        return 0 if n == len(DECO_SOURCES) else 1
    if not game.exists():
        print("game folder not found:", game)
        print("set COSSACKS3_DIR or pass --game PATH on Linux/macOS, "
              "e.g. --game ~/games/cossacks3")
        return 2

    # --- terrain tiles (DDS -> PNG) ---
    # The FULL donor set: every TileBlock texture (terrain.presets Summer +
    # smooth lists). Rendered 1:1 per map cell after SmoothTileMap insertion.
    _TERRAIN_TEX = (
        ["grass%d" % i for i in range(1, 11)]
        + ["ground1"]
        + ["grass_ground%d" % i for i in range(1, 4)]
        + ["grass_rock1"]
        + ["grass_sand%d" % i for i in range(1, 3)]
        + ["rock%d" % i for i in range(1, 10)]
        + ["sand%d" % i for i in range(1, 10)]
        + ["sandsea%d" % i for i in range(1, 7)]
        + ["sandrock%d" % i for i in range(1, 7)]
        + ["test%d" % i for i in range(26)]
        + ["desert%d" % i for i in range(1, 13)]
        + ["winter%d" % i for i in range(27)]   # donor winter season tiles
    )
    for _name in _TERRAIN_TEX:
        dds_to_png(game, "data/terrain/tiles/textures/%s.dds" % _name,
                   dst_root / "terrain/blocks/%s.png" % _name)
    # legacy single-file paths kept by the old terrain baker
    for i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:
        dds_to_png(game, f"data/terrain/tiles/textures/grass{i}.dds",
                   dst_root / f"terrain/grass{i}.png")
    for i in [1, 2, 3]:
        dds_to_png(game, f"data/terrain/tiles/textures/grass_ground{i}.dds",
                   dst_root / f"terrain/ground{i}.png")
    dds_to_png(game, "data/terrain/tiles/textures/ground1.dds",
               dst_root / "terrain/dirt1.png")
    dds_to_png(game, "data/terrain/tiles/textures/grass_rock1.dds",
               dst_root / "terrain/rockgrass1.png")
    dds_to_png(game, "data/terrain/tiles/textures/grass_sand1.dds",
               dst_root / "terrain/grasssand1.png")
    dds_to_png(game, "data/terrain/tiles/textures/grass_sand2.dds",
               dst_root / "terrain/grasssand2.png")
    for i in [1, 2, 3, 4, 5, 6, 7, 8, 9]:
        dds_to_png(game, f"data/terrain/tiles/textures/rock{i}.dds",
                   dst_root / f"terrain/rock{i}.png")
    for i in [1, 2, 3]:
        dds_to_png(game, f"data/terrain/tiles/textures/sandrock{i}.dds",
                   dst_root / f"terrain/sandrock{i}.png")

    # --- building ground decals (original dirt plates under each building,
    # data/terrain/decals/buildings/*.dds). Donor DDS reads natively in
    # Godot, so copy ALL of them as-is; _bld_decal picks nat+sid (+winter).
    for _dds in sorted((game / "data" / "terrain" / "decals" / "buildings").glob("*.dds")):
        copy_rel(game, "data/terrain/decals/buildings/%s" % _dds.name,
                 dst_root / "terrain/decals_dds/%s" % _dds.name)
    # --- env + pfx decals (field soil, scorch craters) + water waves ---
    # Alpha-bearing DXT5 plates: require_alpha=True guarantees colorType 6 and
    # preserves the donor coverage mask (see dds_to_png / regen_deco_pngs).
    for _x, _rel in DECO_SOURCES:
        dds_to_png(game, _rel, dst_root / "terrain/deco_png/%s.png" % _x,
                   require_alpha=True)
    for _x in ["diffusewaves0", "diffusewaves2"]:
        _src = game / "data" / "water" / "textures" / ("%s.bmp" % _x)
        if _src.exists():
            from PIL import Image as _PI
            _PI.open(_src).convert("RGB").save(
                dst_root / "terrain/water_png/%s.png" % _x)
    # NOTE: terrain/structs/*.json are generated by tools/parse_terrain.py
    # (tileblocks, presets_summer, smooth_summer, water) from the donor libs.
    # NOTE: terrain/dmask/d_*.png are generated from the donor alpha.bmp +
    # alphavert.bmp transition atlases (organic blend masks, see parse script).

    # --- UI atlases (BMP, used with AtlasTexture regions) ---
    copy_rel(game, "data/hud/textures/ui/icons.bmp", dst_root / "ui/icons.bmp")
    copy_rel(game, "data/hud/textures/ui/iconsunits.bmp", dst_root / "ui/iconsunits.bmp")

    # --- cursors ---
    for c in ["default", "attack", "gainfood", "gainwood", "gainstone",
              "construct", "gotomine", "captureattack", "patrol",
              "artillery", "wait"]:
        copy_rel(game, f"data/cursors/textures/bmp/{c}.bmp",
                 dst_root / f"ui/cursor_{c}.bmp")

    # --- sounds (ogg): every sound of the original, same name same use ---
    for folder in ["units", "interface"]:
        src_dir = game / "data" / "sounds" / folder
        if not src_dir.exists():
            print("MISSING", src_dir)
            continue
        for name in sorted(os.listdir(src_dir)):
            if name.lower().endswith(".ogg"):
                copy_rel(game, f"data/sounds/{folder}/{name}",
                         dst_root / f"sounds/{name}")

    # --- ambience and the music of the two nations ---
    for name in ["amb_atmosphere", "amb_wind", "amb_sea", "amb_towneur",
                 "amb_windmill", "ukr", "rus"]:
        copy_rel(game, f"data/sounds/ambient/{name}.ogg",
                 dst_root / f"sounds/{name}.ogg")

    print("done ->", dst_root)
    return 0


if __name__ == "__main__":
    sys.exit(main())
