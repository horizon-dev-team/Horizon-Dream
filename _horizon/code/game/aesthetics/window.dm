/obj/structure/window
	var/special_icon = FALSE
	var/list/wall_connections = list("0", "0", "0", "0")
	var/list/blend_turfs = list(/turf/closed)
	var/list/noblend_turfs = list(/turf/closed/mineral, /turf/closed/wall/mineral/titanium)
	var/list/blend_objects = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/shuttle, /obj/structure/window/reinforced/plasma/plastitanium, /obj/structure/window/plasma/fulltile, /obj/structure/window/reinforced/plasma/fulltile, /obj/structure/window/framed, /obj/structure/window_frame, /obj/machinery/door)
	var/list/noblend_objects = list()

/obj/structure/window/reinforced/fulltile
	icon = '_horizon/icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "wall"
	plane = ABOVE_WALL_PLANE
	special_icon = TRUE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null

/obj/structure/window/reinforced/shuttle
	icon = '_horizon/icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "wall"
	plane = ABOVE_WALL_PLANE
	special_icon = TRUE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null
	blend_turfs = list(/turf/closed/wall/mineral/titanium)
	noblend_turfs = list(/turf/closed/mineral)

/obj/structure/window/reinforced/plasma/plastitanium
	icon = '_horizon/icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "wall"
	plane = ABOVE_WALL_PLANE
	special_icon = TRUE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null

/obj/structure/window/fulltile
	icon = '_horizon/icons/obj/smooth_structures/window.dmi'
	icon_state = "wall"
	plane = ABOVE_WALL_PLANE
	special_icon = TRUE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null

/obj/structure/window/plasma/fulltile
	icon = '_horizon/icons/obj/smooth_structures/plasma_window.dmi'
	icon_state = "wall"
	plane = ABOVE_WALL_PLANE
	special_icon = TRUE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null

/obj/structure/window/reinforced/plasma/fulltile
	icon = '_horizon/icons/obj/smooth_structures/rplasma_window.dmi'
	icon_state = "wall"
	plane = ABOVE_WALL_PLANE
	special_icon = TRUE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null

/turf/closed/indestructible/fakeglass
	icon = '_horizon/icons/obj/smooth_structures/gold_shuttle_window.dmi'
	icon_state = "wall"
	special_icon = TRUE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null
	blend_turfs = list(/turf/closed, /turf/closed/indestructible/fakeglass)
