Drop wall sprite PNGs here, then run `wall_dmi_cutter.bat` (or
`python ../wall_dmi_cutter.py --batch`). Each `foo.png` becomes a
sibling `foo.dmi`.

PNG format: 32 px tall, 5 tiles wide (160 px). Each 32x32 tile is one
full wall appearance; the four 16x16 quadrants become the 4 dirs of a
single `wallN` icon_state.

The 5 source tiles cover all 8 wallN states (wall0..wall7):
    tile 0 -> wall0   (wall2 = copy of wall0)
    tile 1 + tile 2 -> wall1, wall4 (diagonal split — see WALL_STATE_LAYOUT)
    tile 3 -> wall5
    tile 4 -> wall7

Tile 0 is also emitted as the single-dir `wall` state (no connections).
See WALL_STATE_LAYOUT in ../wall_dmi_cutter.py to customise the mapping.
