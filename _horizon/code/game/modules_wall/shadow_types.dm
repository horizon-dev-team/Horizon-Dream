// Base Asset
/atom/movable/atom_shadow
	name = "shadow"
	anchored = TRUE
	plane = ATOMS_FOV_SHADOWS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// The owner (door setDir / wall smoothing) controls our direction, the shuttle must not rotate us a second time
/atom/movable/atom_shadow/shuttleRotate(rotation, params)
	return

// MARK: Door Airlock
/atom/movable/atom_shadow/door
	icon = '_horizon/icons/obj/airlock_mask.dmi'
	icon_state = "closed"

/obj/machinery/door
	var/atom/movable/atom_shadow/door/shadow

/obj/machinery/door/Initialize(mapload)
	. = ..()
	if(glass)
		return

	shadow = new(loc)
	shadow.icon_state = icon_state
	shadow.dir = dir
	if(!mapload)
		QUEUE_SMOOTH_NEIGHBORS(src) //walls around a runtime-spawned door need to see it

/obj/machinery/door/setDir(newdir)
	. = ..()
	shadow?.dir = newdir

/obj/machinery/door/airlock/update_icon(updates = ALL)
	. = ..()
	if(shadow)
		switch(airlock_state)
			if(AIRLOCK_OPENING)
				shadow.icon_state = "opening"
			if(AIRLOCK_OPEN)
				shadow.icon_state = "open"
			if(AIRLOCK_CLOSING)
				shadow.icon_state = "closing"
			if(AIRLOCK_CLOSED)
				shadow.icon_state = "closed"

/obj/machinery/door/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src) //walls around need to close their junctions once we're gone
	qdel(shadow)
	return ..()

/obj/machinery/door/poddoor/update_icon(updates = ALL)
	. = ..()
	shadow?.icon_state = density ? "closed" : "open"
