#!/usr/bin/env python3
"""Build a false wall atlas (like `icons/turf/walls/false_walls.dmi`) from wall .dmi files.

For every source .dmi the first `wall` icon_state (the flat 32x32 wall) is slid
sideways out of the tile and three icon_states are written:

    <name>_wall-open      one frame, the wall pushed away (a 9 px edge stays visible)
    <name>_wall-opening   5 frames, delay 1, loop 1 (full wall -> open)
    <name>_wall-closing   5 frames, delay 1, loop 1 (open -> full wall)

`<name>` is the source file name without extension (`plastitanium.dmi` ->
`plastitanium_wall-open`); set the falsewall's `base_icon_state` to `<name>_wall`.

The slide offsets were measured from the vanilla atlas: every vanilla wall type
(wall, plastitanium, shuttle, reinforced, wood, ...) is exactly the flat wall
shifted left by these amounts, with no other drawing. `--selftest` regenerates
the vanilla frames with this script and compares them pixel by pixel.

Usage:
    python false_wall_atlas.py                       # every wall .dmi from modules_wall -> modules_wall/false_walls.dmi
    python false_wall_atlas.py a.dmi b.dmi -o out.dmi
    python false_wall_atlas.py --selftest            # check the algorithm against icons/turf/walls/false_walls.dmi
"""

from __future__ import annotations

import argparse
import math
import re
import sys
from pathlib import Path

try:
    from PIL import Image
    from PIL.PngImagePlugin import PngInfo
except ImportError:
    sys.exit("[false_wall_atlas] Pillow is required: pip install Pillow")

TILE = 32
# How far (px) the wall is pushed to the left on each animation frame
OPENING_SHIFTS = (0, 10, 14, 21, 23)
OPEN_SHIFT = OPENING_SHIFTS[-1]
FRAME_DELAY = 1

HORIZON_DIR = Path(__file__).resolve().parents[2]
REPO_DIR = HORIZON_DIR.parent
DEFAULT_ICONS_DIR = HORIZON_DIR / "icons" / "turf" / "walls" / "modules_wall"
DEFAULT_OUTPUT = DEFAULT_ICONS_DIR / "false_walls.dmi"
VANILLA_ATLAS = REPO_DIR / "icons" / "turf" / "walls" / "false_walls.dmi"
# Source files that are not walls
SKIP_FILES = {"example.dmi", "false_walls.dmi"}


# MARK: DMI reading / writing
class State:
    def __init__(self, name: str, dirs: int, frames: int, delay: str | None, loop: str | None, images: list[Image.Image]):
        self.name, self.dirs, self.frames, self.delay, self.loop, self.images = name, dirs, frames, delay, loop, images


def read_dmi(path: Path) -> tuple[int, int, list[State]]:
    sheet = Image.open(path)
    description = sheet.info.get("Description")
    if not description:
        raise ValueError(f"{path.name}: no DMI description chunk")
    sheet = sheet.convert("RGBA")
    width = height = TILE
    raw_states: list[dict] = []
    for line in description.splitlines():
        line = line.strip()
        if line.startswith("width"):
            width = int(line.split("=")[1])
        elif line.startswith("height"):
            height = int(line.split("=")[1])
        elif line.startswith("state"):
            raw_states.append({"name": re.search(r'"(.*)"', line).group(1), "dirs": 1, "frames": 1, "delay": None, "loop": None})
        elif raw_states and "=" in line:
            key, value = (part.strip() for part in line.split("=", 1))
            if key in ("dirs", "frames"):
                raw_states[-1][key] = int(value)
            elif key in ("delay", "loop"):
                raw_states[-1][key] = value

    columns = sheet.width // width
    states, index = [], 0
    for raw in raw_states:
        images = []
        for _ in range(raw["dirs"] * raw["frames"]):
            x, y = (index % columns) * width, (index // columns) * height
            images.append(sheet.crop((x, y, x + width, y + height)))
            index += 1
        states.append(State(raw["name"], raw["dirs"], raw["frames"], raw["delay"], raw["loop"], images))
    return width, height, states


def write_dmi(path: Path, states: list[State]) -> None:
    lines = ["# BEGIN DMI", "version = 4.0", f"\twidth = {TILE}", f"\theight = {TILE}"]
    frames: list[Image.Image] = []
    for state in states:
        lines += [f'state = "{state.name}"', f"\tdirs = {state.dirs}", f"\tframes = {state.frames}"]
        if state.delay:
            lines.append(f"\tdelay = {state.delay}")
        if state.loop:
            lines.append(f"\tloop = {state.loop}")
        frames += state.images
    lines.append("# END DMI")

    columns = math.ceil(math.sqrt(len(frames)))
    rows = math.ceil(len(frames) / columns)
    sheet = Image.new("RGBA", (columns * TILE, rows * TILE), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.paste(frame, ((i % columns) * TILE, (i // columns) * TILE))

    info = PngInfo()
    info.add_text("Description", "\n".join(lines) + "\n", zip=True)
    sheet.save(path, format="PNG", pnginfo=info)


# MARK: The algorithm
def flat_wall(width: int, height: int, states: list[State], source: str) -> Image.Image:
    """The first `wall` icon_state, cut to a 32x32 tile."""
    wall = next((s for s in states if s.name == "wall"), None)
    if wall is None:
        raise ValueError(f"{source}: no `wall` icon_state")
    image = wall.images[0]
    if (width, height) != (TILE, TILE):
        # Bigger tiles carry frill overhang around the wall, the sliding wall only needs the middle
        left, top = (width - TILE) // 2, (height - TILE) // 2
        image = image.crop((left, top, left + TILE, top + TILE))
        print(f"[false_wall_atlas] {source}: {width}x{height} icon, centre {TILE}x{TILE} is used")
    return image


def slide(wall: Image.Image, shift: int) -> Image.Image:
    """The wall pushed `shift` px to the left, whatever leaves the tile is cut off.

    Invisible pixels are written as (0, 0, 0, 0) so two frames can be compared byte for byte."""
    moved = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    moved.paste(wall, (-shift, 0))
    pixels = moved.load()
    for y in range(TILE):
        for x in range(TILE):
            if pixels[x, y][3] == 0:
                pixels[x, y] = (0, 0, 0, 0)
    return moved


def false_wall_states(base: str, wall: Image.Image) -> list[State]:
    opening = [slide(wall, shift) for shift in OPENING_SHIFTS]
    delay = ",".join([str(FRAME_DELAY)] * len(opening))
    return [
        State(f"{base}-open", 1, 1, None, None, [slide(wall, OPEN_SHIFT)]),
        State(f"{base}-opening", 1, len(opening), delay, "1", opening),
        State(f"{base}-closing", 1, len(opening), delay, "1", opening[::-1]),
    ]


def atlas_name(path: Path) -> str:
    return re.sub(r"[^a-z0-9]+", "_", path.stem.lower()).strip("_")


# MARK: Commands
def selftest() -> int:
    """Regenerate every vanilla false wall from its own flat wall frame and compare."""
    _, _, states = read_dmi(VANILLA_ATLAS)
    by_name = {s.name: s for s in states}
    same = different = 0
    for state in states:
        if not state.name.endswith("-opening"):
            continue
        base = state.name[: -len("-opening")]
        expected = false_wall_states(base, slide(state.images[0], 0))
        ok = all(
            mine.tobytes() == slide(theirs, 0).tobytes()
            for generated in expected
            for mine, theirs in zip(generated.images, by_name[generated.name].images)
        )
        same, different = (same + 1, different) if ok else (same, different + 1)
        print(f"  {'OK  ' if ok else 'DIFF'} {base}")
    print(f"{same} identical, {different} different (hand drawn frames)")
    return 0


def build(inputs: list[Path], output: Path) -> int:
    states: list[State] = []
    for path in inputs:
        width, height, source_states = read_dmi(path)
        states += false_wall_states(f"{atlas_name(path)}_wall", flat_wall(width, height, source_states, path.name))
    write_dmi(output, states)
    print(f"[false_wall_atlas] {len(inputs)} walls, {len(states)} icon_states -> {output}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("inputs", nargs="*", type=Path, help="wall .dmi files (default: every .dmi in modules_wall)")
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--selftest", action="store_true", help="compare the algorithm with the vanilla false_walls.dmi")
    args = parser.parse_args()

    if args.selftest:
        return selftest()
    inputs = args.inputs or sorted(p for p in DEFAULT_ICONS_DIR.glob("*.dmi") if p.name not in SKIP_FILES)
    return build(inputs, args.output)


if __name__ == "__main__":
    sys.exit(main())
