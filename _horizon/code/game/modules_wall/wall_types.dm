/turf/closed
	var/atom/movable/atom_shadow/wall/shadow

	var/list/wall_connections = list("0", "0", "0", "0")
	var/list/blend_turfs = list(/turf/closed, /turf/closed/wall/mineral/plastitanium)
	var/list/noblend_turfs = list(/turf/closed/mineral, /turf/closed/wall/mineral/titanium)
	var/list/blend_objects = list(/obj/structure/grille, /obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/shuttle, /obj/structure/window/reinforced/plasma/plastitanium, /obj/structure/window/plasma/fulltile, /obj/structure/window/reinforced/plasma/fulltile, /obj/structure/window/framed, /obj/structure/window_frame, /obj/machinery/door)
	var/list/noblend_objects = list()

	var/special_icon = TRUE
	var/diagonal = FALSE /// Special wall0-diagonal and wall5-diagonal states
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null

/turf/closed/Initialize(mapload)
	. = ..()
	shadow = new(src)

/turf/closed/Destroy()
	QDEL_NULL(shadow)
	return ..()

/turf/closed/setDir(newDir)
	..()
	QUEUE_SMOOTH(src)

/// A shuttle recreates the wall (and its shadow) on the new turf, so the corners must be recalculated once everything has arrived
/turf/closed/afterShuttleMove(turf/oldT, rotation)
	. = ..()
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)

// MARK: Types
/turf/closed/wall/r_wall
	icon = '_horizon/icons/turf/walls/modules_wall/reinforce.dmi'

/turf/closed/wall/r_wall/plastitanium
	icon = '_horizon/icons/turf/walls/modules_wall/pidopod.dmi'

/*
/turf/closed/wall/mineral/bananium
	icon = 'icons/turf/walls/bananium_wall.dmi'

/turf/closed/wall/mineral/bamboo
	icon = 'icons/turf/walls/bamboo_wall.dmi'

/turf/closed/wall/mineral/abductor
	icon = 'icons/turf/walls/abductor_wall.dmi'
*/

// MARK: Mineral
/turf/closed/wall/mineral
	blend_turfs = list(/turf/closed/wall/mineral)
	noblend_turfs = list()

/turf/closed/wall/mineral/plastitanium
	icon = '_horizon/icons/turf/walls/modules_wall/plastitanium.dmi'

/turf/closed/wall/mineral/plastitanium/nodiagonal
//	icon = MAP_SWITCH('_horizon/icons/turf/walls/plastitanium_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
//	icon_state = MAP_SWITCH("plastitanium_wall-0", "plastitanium_nd")

/turf/closed/wall/mineral/plastitanium/overspace
//	icon = MAP_SWITCH('_horizon/icons/turf/walls/plastitanium_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
//	icon_state = MAP_SWITCH("plastitanium_wall-0", "plastitanium_overspace")

/turf/closed/wall/mineral/plastitanium/survival
	icon = '_horizon/icons/turf/walls/modules_wall/EvaWall.dmi'

/turf/closed/wall/concrete
	icon = '_horizon/icons/turf/walls/modules_wall/concrete.dmi'

/turf/closed/wall/concrete/reinforced
	icon = '_horizon/icons/turf/walls/modules_wall/hexaconcrete.dmi'

/turf/closed/wall/mineral/titanium
	icon = '_horizon/icons/turf/walls/modules_wall/shuttle.dmi'
	diagonal = FALSE

/turf/closed/wall/mineral/titanium/nodiagonal
	diagonal = TRUE

/turf/closed/wall/mineral/titanium/overspace
	diagonal = TRUE
	fixed_underlay = list("space" = TRUE)

/*
// MARK: Titan
/turf/closed/wall/mineral/titanium/survival
	icon = '_horizon/icons/turf/walls/survival_pod_walls.dmi'

/turf/closed/wall/mineral/titanium/survival/nodiagonal
	icon = '_horizon/icons/turf/walls/survival_pod_walls.dmi'
*/

// MARK: Generic Walls
/turf/closed/wall/mineral/snow
	icon = '_horizon/icons/turf/walls/modules_wall/snow.dmi'

/turf/closed/wall/mineral/sandstone
	icon = '_horizon/icons/turf/walls/modules_wall/sandstone.dmi'

/turf/closed/wall/mineral/iron
	icon = '_horizon/icons/turf/walls/modules_wall/iron.dmi'

/turf/closed/wall/mineral/gold
	icon = '_horizon/icons/turf/walls/modules_wall/gold.dmi'

/turf/closed/wall/mineral/silver
	icon = '_horizon/icons/turf/walls/modules_wall/silver.dmi'

/turf/closed/wall/mineral/wood
	icon = '_horizon/icons/turf/walls/modules_wall/wood.dmi'

/turf/closed/wall/mineral/uranium
	icon = '_horizon/icons/turf/walls/modules_wall/uranium.dmi'

/turf/closed/wall/mineral/diamond
	icon = '_horizon/icons/turf/walls/modules_wall/diamond.dmi'

/turf/closed/wall/mineral/plasma
	icon = '_horizon/icons/turf/walls/modules_wall/plasma.dmi'

/*
/turf/closed/indestructible/riveted
	icon = '_horizon/icons/turf/walls/riveted.dmi'
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_SYNDICATE_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_SYNDICATE_WALLS

/turf/closed/indestructible/riveted/boss
	icon = '_horizon/icons/turf/walls/boss_wall.dmi'
*/
