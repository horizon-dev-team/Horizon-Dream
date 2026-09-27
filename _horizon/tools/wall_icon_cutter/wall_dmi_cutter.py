#!/usr/bin/env python3
"""Slice a spriter wall sheet (32px-tall PNG strip, 5 tiles wide) into a
Byond .dmi whose layout matches `_horizon/code/game/modules_wall/wall_icon.dm`.

Each 32x32 source tile is split into four 16x16 quadrants; the quadrants
become the 4 directional frames (S, N, E, W) of a single `wallN`
icon_state — NOT four separate states. 8 wallN states (wall0..wall7) are
emitted from 5 source tiles; see WALL_STATE_LAYOUT below for the
duplicate/split rules.

Usage:
    python wall_dmi_cutter.py <input.png> <output.dmi>
    python wall_dmi_cutter.py --batch [--icons-dir ./icons]

In batch mode, every .png in <script_dir>/icons is converted to a sibling
.dmi. wall_dmi_cutter.bat is a thin wrapper around `--batch`.
"""

from __future__ import annotations

import argparse
import zlib
import math
import struct
import subprocess
import sys
from pathlib import Path


def _ensure_pillow() -> None:
    """Use the project's PIL if available; otherwise pip-install Pillow once."""
    try:
        from PIL import Image  # noqa: F401
        return
    except ImportError:
        pass

    import site
    print("[wall_dmi_cutter] Pillow not found. Installing via pip...")
    cmd = ([sys.executable, "-m", "pip", "install", "--user", "--upgrade", "Pillow"]
           if site.ENABLE_USER_SITE
           else [sys.executable, "-m", "pip", "install", "--upgrade", "Pillow"])
    try:
        subprocess.check_call(cmd)
    except subprocess.CalledProcessError as exc:
        print(f"[wall_dmi_cutter] pip install failed (exit {exc.returncode}).")
        print(f"  Command: {' '.join(cmd)}")
        print("  Install Pillow manually:  pip install Pillow")
        raise

    try:
        from PIL import Image  # noqa: F401
    except ImportError as exc:
        print(f"[wall_dmi_cutter] Pillow still not importable after install: {exc}")
        raise


_ensure_pillow()
from PIL import Image  # noqa: E402


TILE = 32
HALF = 16

# Byond dir order for `dirs = 4`: S, N, E, W. Cell quadrant = where the
# 16x16 sprite lives inside the 32x32 DMI cell (matches example.dmi).
DIRS_4 = [
    ("S", 1, (HALF, HALF, TILE, TILE)),  # BR
    ("N", 2, (0,    0,    HALF, HALF)),  # TL
    ("E", 4, (HALF, 0,    TILE, HALF)),  # TR
    ("W", 8, (0,    HALF, HALF, TILE)),  # BL
]
DIR_TO_QUAD = {"S": "BR", "N": "TL", "E": "TR", "W": "BL"}

# Each wallN state maps to its source(s):
#   ("tile",  N)          all 4 dirs from tile N
#   ("split", top, bot)   TL/TR (dir=N/E) from tile `top`, BL/BR (dir=S/W) from tile `bot`
#   ("dup",   M)          copy all 4 dir cells from wall state M
#
# wall2=wall0, wall3=wall1, wall6=wall4 because CORNER_DIAGONAL alone
# doesn't change the sprite. wall1/wall4 are mirror images, packed by
# the spriter into the tile 1/2 pair via split.
WALL_STATE_LAYOUT = [
    ("tile",  0),
    ("split", 2, 1),  # wall1: top=t2, bot=t1
    ("dup",   0),     # wall2 == wall0
    ("dup",   1),     # wall3 == wall1
    ("split", 1, 2),  # wall4: top=t1, bot=t2
    ("tile",  3),
    ("dup",   4),     # wall6 == wall4
    ("tile",  4),
]

TILES_USED_BY_LAYOUT = sorted({
    r for kind, *rest in WALL_STATE_LAYOUT if kind == "tile" for r in rest
} | {
    r for kind, *rest in WALL_STATE_LAYOUT if kind == "split" for r in rest
})
EXPECTED_TILE_COUNT = max(TILES_USED_BY_LAYOUT) + 1


def build_description(state_specs):
    lines = ["# BEGIN DMI", "version = 4.0", "\twidth = 32", "\theight = 32"]
    for name, dirs, frames in state_specs:
        escaped = name.replace("\\", "\\\\").replace("\"", "\\\"")
        lines.append(f'state = "{escaped}"')
        lines.append(f"\tdirs = {dirs}")
        lines.append(f"\tframes = {frames}")
    lines.append("# END DMI")
    return "\n".join(lines) + "\n"


def grid_size(num_cells):
    cols = max(1, math.ceil(math.sqrt(num_cells)))
    while cols * cols < num_cells:
        cols += 1
    rows = math.ceil(num_cells / cols)
    return cols, rows


def _crc32(data: bytes) -> int:
    return zlib.crc32(data) & 0xFFFFFFFF


def make_ztxt_chunk(keyword: str, text: str) -> bytes:
    comp = zlib.compress(text.encode("latin-1", errors="replace"))
    payload = keyword.encode("latin-1") + b"\x00\x00" + comp
    chunk_type = b"zTXt"
    return struct.pack(">I", len(payload)) + chunk_type + payload + \
        struct.pack(">I", _crc32(chunk_type + payload))


def write_dmi(path: Path, grid_image: Image.Image, description: str) -> None:
    """Write grid_image to path as a DMI: PNG with a zTXt Description chunk
    injected right after IHDR."""
    import io
    buf = io.BytesIO()
    grid_image.save(buf, format="PNG", optimize=False)
    raw = buf.getvalue()

    if raw[:8] != b"\x89PNG\r\n\x1a\n":
        raise RuntimeError("PIL did not produce a valid PNG signature")

    out = bytearray(raw[:8])
    pos = 8
    injected = False
    while pos < len(raw):
        length = struct.unpack(">I", raw[pos:pos + 4])[0]
        chunk_type = raw[pos + 4:pos + 8]
        out += raw[pos:pos + 8 + length + 4]
        if chunk_type == b"IHDR" and not injected:
            out += make_ztxt_chunk("Description", description)
            injected = True
        pos += 8 + length + 4
        if chunk_type == b"IEND":
            break

    path.write_bytes(bytes(out))


def slice_tile_quadrants(tile_img: Image.Image) -> dict[str, Image.Image]:
    """Slice a 32x32 tile into {"TL","TR","BL","BR"} 16x16 RGBA images."""
    if tile_img.mode != "RGBA":
        tile_img = tile_img.convert("RGBA")
    return {
        "TL": tile_img.crop((0,    0,    HALF, HALF)),
        "TR": tile_img.crop((HALF, 0,    TILE, HALF)),
        "BL": tile_img.crop((0,    HALF, HALF, TILE)),
        "BR": tile_img.crop((HALF, HALF, TILE, TILE)),
    }


def assemble_dir_cell(quad_name: str, quad_img: Image.Image) -> Image.Image:
    """Paste a 16x16 quadrant into a transparent 32x32 cell at its position."""
    cell = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    pos = {"TL": (0, 0), "TR": (HALF, 0), "BL": (0, HALF), "BR": (HALF, HALF)}
    cell.paste(quad_img, pos[quad_name])
    return cell


def build_dmi(input_png: Path, output_dmi: Path,
              state_prefix: str = "wall",
              full_state_name: str | None = "wall",
              tile_size: int = TILE) -> None:
    src = Image.open(input_png).convert("RGBA")
    if src.height != tile_size:
        raise ValueError(
            f"Source PNG height is {src.height}px; expected {tile_size}px.")
    if src.width % tile_size != 0:
        raise ValueError(
            f"Source PNG width {src.width} is not a multiple of {tile_size}.")
    num_tiles = src.width // tile_size
    if num_tiles < EXPECTED_TILE_COUNT:
        raise ValueError(
            f"Source PNG has {num_tiles} tile(s) but WALL_STATE_LAYOUT "
            f"requires at least {EXPECTED_TILE_COUNT} (tiles 0.."
            f"{EXPECTED_TILE_COUNT - 1}).")

    tile_quads_cache: dict[int, dict[str, Image.Image]] = {}

    def get_tile_quads(tile_idx: int) -> dict[str, Image.Image]:
        if tile_idx not in tile_quads_cache:
            tile = src.crop((tile_idx * tile_size, 0,
                             (tile_idx + 1) * tile_size, tile_size))
            tile_quads_cache[tile_idx] = slice_tile_quadrants(tile)
        return tile_quads_cache[tile_idx]

    wall_state_cells: dict[int, list[Image.Image]] = {}
    for wall_idx, entry in enumerate(WALL_STATE_LAYOUT):
        kind = entry[0]

        if kind == "dup":
            ref = entry[1]
            if ref not in wall_state_cells:
                raise ValueError(
                    f"WALL_STATE_LAYOUT: wall{wall_idx} duplicates wall{ref} "
                    f"but wall{ref} is defined later. Reorder the layout.")
            wall_state_cells[wall_idx] = [c.copy() for c in wall_state_cells[ref]]
            continue

        if kind == "tile":
            t = entry[1]
            quad_to_tile = {"TL": t, "TR": t, "BL": t, "BR": t}
        elif kind == "split":
            top, bot = entry[1], entry[2]
            quad_to_tile = {"TL": top, "TR": top, "BL": bot, "BR": bot}
        else:
            raise ValueError(f"Unknown WALL_STATE_LAYOUT kind: {kind!r}")

        cells_for_state: list[Image.Image] = []
        for dir_name, _bit, _cell_quad in DIRS_4:
            quad_name = DIR_TO_QUAD[dir_name]
            quads = get_tile_quads(quad_to_tile[quad_name])
            cells_for_state.append(assemble_dir_cell(quad_name, quads[quad_name]))
        wall_state_cells[wall_idx] = cells_for_state

    cells: list[Image.Image] = []
    state_specs: list[tuple[str, int, int]] = []

    if full_state_name is not None:
        cells.append(src.crop((0, 0, tile_size, tile_size)).convert("RGBA"))
        state_specs.append((full_state_name, 1, 1))

    for wall_idx in range(len(WALL_STATE_LAYOUT)):
        cells.extend(wall_state_cells[wall_idx])
        state_specs.append((f"{state_prefix}{wall_idx}", 4, 1))

    cols, rows = grid_size(len(cells))
    grid = Image.new("RGBA", (cols * tile_size, rows * tile_size), (0, 0, 0, 0))
    for idx, cell in enumerate(cells):
        grid.paste(cell, ((idx % cols) * tile_size, (idx // cols) * tile_size))

    write_dmi(output_dmi, grid, build_description(state_specs))

    dup_summary = ", ".join(
        f"{state_prefix}{i}={state_prefix}{e[1]}"
        for i, e in enumerate(WALL_STATE_LAYOUT) if e[0] == "dup")
    split_summary = ", ".join(
        f"{state_prefix}{i}(top=t{e[1]},bot=t{e[2]})"
        for i, e in enumerate(WALL_STATE_LAYOUT) if e[0] == "split")
    unused = sorted(set(range(num_tiles)) - set(TILES_USED_BY_LAYOUT))
    print(f"[wall_dmi_cutter] {input_png} -> {output_dmi}")
    print(f"  tiles read : {num_tiles} (used: {len(TILES_USED_BY_LAYOUT)})"
          + (f", unused: {unused}" if unused else ""))
    print(f"  states     : {len(state_specs)} "
          f"({full_state_name or '(no full state)'} + "
          f"{len(WALL_STATE_LAYOUT)} x {state_prefix}0.."
          f"{state_prefix}{len(WALL_STATE_LAYOUT)-1})")
    print(f"  duplicates : {sum(1 for e in WALL_STATE_LAYOUT if e[0] == 'dup')} "
          f"({dup_summary})")
    if split_summary:
        print(f"  splits     : {split_summary}")
    print(f"  cells      : {len(cells)}  ({cols} cols x {rows} rows grid)")


def run_batch(icons_dir: Path,
              state_prefix: str = "wall",
              full_state_name: str | None = "wall",
              tile_size: int = TILE) -> int:
    """Convert every .png in icons_dir to a sibling .dmi. Returns count."""
    if not icons_dir.is_dir():
        print(f"[wall_dmi_cutter] ERROR: icons dir not found: {icons_dir}")
        return 0

    pngs = sorted(p for p in icons_dir.iterdir()
                  if p.is_file() and p.suffix.lower() == ".png")
    if not pngs:
        print(f"[wall_dmi_cutter] No .png files found in {icons_dir}")
        return 0

    print(f"[wall_dmi_cutter] Batch mode: {len(pngs)} PNG(s) in {icons_dir}")
    print(f"[wall_dmi_cutter] Output DMI(s) will be written to the same folder.")
    print()

    ok = 0
    failed = 0
    for png in pngs:
        out = png.with_suffix(".dmi")
        try:
            build_dmi(png, out, state_prefix=state_prefix,
                      full_state_name=full_state_name, tile_size=tile_size)
            ok += 1
        except Exception as exc:  # noqa: BLE001
            failed += 1
            print(f"  FAIL  {png.name}: {exc}")

    print()
    print(f"[wall_dmi_cutter] Done: {ok} converted, {failed} failed.")
    return ok


def main(argv=None):
    p = argparse.ArgumentParser(
        description="Slice a spriter wall sheet into a Byond DMI "
                    "with directional wallN icon_states.")
    p.add_argument("input", type=Path, nargs="?",
                   help="Source PNG (single-file mode).")
    p.add_argument("output", type=Path, nargs="?",
                   help="Destination .dmi (single-file mode).")
    p.add_argument("--batch", action="store_true",
                   help="Convert every .png in the icons dir to a sibling .dmi.")
    p.add_argument("--icons-dir", type=Path, default=None,
                   help="Icons folder for batch mode (default: <script_dir>/icons).")
    p.add_argument("--tile", type=int, default=TILE, help="Tile size in px.")
    p.add_argument("--state-name", default="wall",
                   help="Prefix for directional states (default 'wall').")
    p.add_argument("--full-state", default="wall",
                   help="Single-dir full-tile state name, or 'none' to omit.")
    args = p.parse_args(argv)

    full_state = None if args.full_state.lower() == "none" else args.full_state

    if args.batch:
        if args.icons_dir is not None:
            icons_dir = args.icons_dir.resolve()
        else:
            icons_dir = (Path(__file__).resolve().parent / "icons").resolve()
        converted = run_batch(icons_dir, state_prefix=args.state_name,
                              full_state_name=full_state, tile_size=args.tile)
        sys.exit(0 if converted > 0 else 1)

    if not args.input or not args.output:
        p.error("single-file mode requires input and output "
                "(or use --batch for batch mode)")
    build_dmi(args.input, args.output, state_prefix=args.state_name,
              full_state_name=full_state, tile_size=args.tile)


if __name__ == "__main__":
    main()
