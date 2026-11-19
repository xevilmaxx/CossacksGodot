# Copies the needed original assets from the installed game into the project.
# Run:  python tools/copy_assets.py [--game PATH] [--dst PATH]
# Reads only from the game folder; writes only into app/assets/.
# Cross-platform: uses pathlib, forward slashes, no OS-specific calls.
# The converted PNGs and OGGs are already committed in app/assets/, so this
# script only needs to run again when re-copying from another install
# (for example on Linux/macOS with a different game path).
import argparse
import os
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve()
APP = HERE.parents[1]
DEFAULT_DST = APP / "assets"
DEFAULT_GAME = Path(r"C:\Games\Cossacks 3")

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


def dds_to_png(game: Path, rel: str, dst: Path, max_size=None) -> bool:
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
    return True


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", default=str(DEFAULT_GAME))
    ap.add_argument("--dst", default=str(DEFAULT_DST))
    args = ap.parse_args()
    game = Path(args.game)
    dst_root = Path(args.dst)
    if not game.exists():
        print("game folder not found:", game)
        print("pass --game PATH on Linux/macOS, e.g. --game ~/games/cossacks3")
        return 2

    # --- terrain tiles (DDS -> PNG) ---
    # Full tile set of the original (all are used as biome variants in world.gd).
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
    # data/terrain/decals/buildings/*.dds). Copied as DDS; the game draws its
    # own dirt ellipse in the same role, the files stay in the folder as the
    # original reference. Only the two played nations + shared pieces.
    for name in ["ukrcend", "ukrhou", "ukrbar", "ukrsta", "ukrbla", "ukracad",
                 "ukrart", "ukrdip", "ukrtem", "ukrpor",
                 "ruscend", "rushou", "rusbar", "russta", "rusbla", "rusacad",
                 "rustem", "rusmar", "rusmil", "ruspor", "russto", "rustow",
                 "eurmard", "eurmild", "eurstod", "eurtowd",
                 "eurgold", "eurirod", "eurcoad", "bldsiz1", "bldsiz2",
                 "bldsiz3", "helper1"]:
        copy_rel(game, f"data/terrain/decals/buildings/{name}.dds",
                 dst_root / f"terrain/decals/{name}.dds")
        copy_rel(game, f"data/terrain/decals/buildings/{name}w.dds",
                 dst_root / f"terrain/decals/{name}w.dds")

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
