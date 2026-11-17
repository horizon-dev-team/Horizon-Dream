/obj/structure/falsewall
	icon = '_horizon/icons/turf/walls/modules_wall/false_walls.dmi'
	base_icon_state = "metal_wall"
	fake_icon = '_horizon/icons/turf/walls/modules_wall/metal.dmi'
	icon_state = "metal_wall-open"

	var/atom/movable/atom_shadow/wall/falsewall/shadow
	var/list/wall_connections = list("0", "0", "0", "0")
	var/list/blend_turfs = list(/turf/closed, /turf/closed/wall/mineral/plastitanium)
	var/list/noblend_turfs = list(/turf/closed/mineral, /turf/closed/wall/mineral/titanium)
	var/list/blend_objects = list(/obj/structure/falsewall, /obj/structure/grille, /obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/shuttle, /obj/structure/window/reinforced/plasma/plastitanium, /obj/structure/window/plasma/fulltile, /obj/structure/window/reinforced/plasma/fulltile, /obj/structure/window/framed, /obj/structure/window_frame, /obj/machinery/door)
	var/list/noblend_objects = list()

	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null

/obj/structure/falsewall/Initialize(mapload)
	. = ..()
	shadow = new(src)
	shadow.set_visible(opacity)
	QUEUE_SMOOTH(src)
	if(!mapload)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/falsewall/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	qdel(shadow)
	return ..()

/obj/structure/falsewall/set_opacity(new_opacity)
	. = ..()
	if(isnull(.))
		return
	shadow.set_visible(opacity)

/obj/structure/falsewall/smooth_icon()
	smoothing_flags &= ~SMOOTH_QUEUED
	update_connections()
	update_icon(~UPDATE_SMOOTHING)
	if(shadow)
		shadow.shadow_connections = wall_connections
		shadow.update_diagonals()
		shadow.update_icon()

/obj/structure/falsewall/proc/update_connections()
	var/list/glass = list()
	wall_connections = dirs_to_corner_states(scan_blend_dirs(src, blend_turfs, noblend_turfs, blend_objects, noblend_objects, glass))
	if(shadow)
		shadow.diag_connections = glass

/obj/structure/falsewall/update_icon(updates = ALL)
	overlays.Cut()
	if(!density || opening)
		return ..()
	icon = fake_icon
	render_corner_frames(src, wall_connections, WALL_PLANE)

/obj/structure/falsewall/reinforced
	fake_icon = '_horizon/icons/turf/walls/modules_wall/reinforce.dmi'
	base_icon_state = "reinforce_wall"

/obj/structure/falsewall/uranium
	fake_icon = '_horizon/icons/turf/walls/modules_wall/uranium.dmi'
	base_icon_state = "uranium_wall"

/obj/structure/falsewall/gold
	fake_icon = '_horizon/icons/turf/walls/modules_wall/gold.dmi'
	base_icon_state = "gold_wall"

/obj/structure/falsewall/silver
	fake_icon = '_horizon/icons/turf/walls/modules_wall/silver.dmi'
	base_icon_state = "silver_wall"

/obj/structure/falsewall/diamond
	fake_icon = '_horizon/icons/turf/walls/modules_wall/diamond.dmi'
	base_icon_state = "diamond_wall"

/obj/structure/falsewall/plasma
	fake_icon = '_horizon/icons/turf/walls/modules_wall/plasma.dmi'
	base_icon_state = "plasma_wall"

// /obj/structure/falsewall/bananium

/obj/structure/falsewall/sandstone
	fake_icon = '_horizon/icons/turf/walls/modules_wall/sandstone.dmi'
	base_icon_state = "sandstone_wall"

/obj/structure/falsewall/wood
	fake_icon = '_horizon/icons/turf/walls/modules_wall/wood.dmi'
	base_icon_state = "wood_wall"

/obj/structure/falsewall/bamboo
	fake_icon = '_horizon/icons/turf/walls/modules_wall/wood.dmi'
	base_icon_state = "wood_wall"

/obj/structure/falsewall/iron
	fake_icon = '_horizon/icons/turf/walls/modules_wall/iron.dmi'
	base_icon_state = "iron_wall"

// /obj/structure/falsewall/abductor

/obj/structure/falsewall/titanium
	fake_icon = '_horizon/icons/turf/walls/modules_wall/shuttle.dmi'
	base_icon_state = "shuttle_wall"

/obj/structure/falsewall/plastitanium
	fake_icon = '_horizon/icons/turf/walls/modules_wall/plastitanium.dmi'
	base_icon_state = "plastitanium_wall"

/obj/structure/falsewall/plastitanium/darkpod
	fake_icon = '_horizon/icons/turf/walls/modules_wall/plastitanium_black.dmi'
	base_icon_state = "plastitanium_black_wall"

/obj/structure/falsewall/plastitanium/redpod
	fake_icon = '_horizon/icons/turf/walls/modules_wall/plastitanium_red.dmi'
	base_icon_state = "plastitanium_red_wall"

/obj/structure/falsewall/plastitanium/survival
	fake_icon = '_horizon/icons/turf/walls/modules_wall/EvaWall.dmi'
	base_icon_state = "evawall_wall"

/obj/structure/falsewall/material
	fake_icon = '_horizon/icons/turf/walls/modules_wall/material wall greyscale.dmi'
	base_icon_state = "material_wall_greyscale_wall"
