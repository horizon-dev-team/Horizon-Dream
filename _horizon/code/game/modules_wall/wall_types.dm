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

/turf/closed/wall/Initialize(mapload)
	. = ..()
	shadow = new(src)

/turf/closed/wall/Destroy()
	qdel(shadow)
	return ..()

/turf/closed/wall/setDir(newDir)
	..()
	QUEUE_SMOOTH(src)

// MARK: Types
/turf/closed/wall/r_wall
	icon = '_horizon/icons/turf/walls/modules_wall/reinforce.dmi'

/turf/closed/wall/r_wall/plastitanium
	icon = '_horizon/icons/turf/walls/modules_wall/pidopod.dmi'

/turf/closed/wall/mineral/plastitanium
	icon = '_horizon/icons/turf/walls/modules_wall/plastitanium.dmi'

/turf/closed/wall/mineral/plastitanium/survival
	icon = '_horizon/icons/turf/walls/modules_wall/EvaWall.dmi'

/turf/closed/wall/concrete
	icon = '_horizon/icons/turf/walls/modules_wall/concrete.dmi'

/turf/closed/wall/concrete/reinforced
	icon = '_horizon/icons/turf/walls/modules_wall/hexaconcrete.dmi'

/turf/closed/wall/mineral/titanium
	icon = '_horizon/icons/turf/walls/modules_wall/shuttle.dmi'

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
