Builds a false wall atlas (same states as icons/turf/walls/false_walls.dmi) from the
flat `wall` icon_state of every wall .dmi in _horizon/icons/turf/walls/.

    false_wall_atlas.bat                    -> modules_wall/false_walls.dmi
    python false_wall_atlas.py a.dmi b.dmi -o out.dmi
    false_wall_atlas.bat --selftest         -> compare with the vanilla atlas

For `plastitanium.dmi` you get three states (set the falsewall's base_icon_state to
"plastitanium_wall"):
    plastitanium_wall-open       the wall is pushed away, a 9 px edge stays in the tile
    plastitanium_wall-opening    5 frames, delay 1, loop 1
    plastitanium_wall-closing    the same 5 frames in reverse

The algorithm is the vanilla one: the flat wall slides left by 0, 10, 14, 21, 23 px,
whatever leaves the tile is cut off (`-open` is the 23 px frame). Vanilla walls are
generated exactly this way, --selftest checks it pixel by pixel (only the hand drawn
meat_wall differs). 40x40 sources (diamond, plasma) use their centre 32x32.
Requires Pillow.
