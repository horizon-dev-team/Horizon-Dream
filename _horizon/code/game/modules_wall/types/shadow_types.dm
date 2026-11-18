// Base Asset
/atom/movable/atom_shadow
	name = "shadow"
	anchored = TRUE
	plane = ATOMS_FOV_SHADOWS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// The owner (door setDir / wall smoothing) controls our direction, the shuttle must not rotate us a second time
/atom/movable/atom_shadow/shuttleRotate(rotation, params)
	return

/atom/movable/atom_shadow/Destroy()
	if(istype(loc, /turf/closed))
		var/turf/closed/owner = loc
		if(owner.shadow == src)
			owner.shadow = null
	return ..()

// MARK: Shadow Wall
/atom/movable/atom_shadow/wall
	icon = '_horizon/icons/obj/modular_shadow.dmi'
	icon_state = "wall"
	var/list/shadow_connections = list("0", "0", "0", "0")
	var/list/diag_connections = list()

/atom/movable/atom_shadow/wall/update_icon()
	. = ..()

	overlays.Cut()
	icon_state = "blank"

	var/static/list/corner_dirs = list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST)
	for(var/i in 1 to 4)
		var/frame = 1<<(i-1)
		overlays += get_wall_object(icon, "wall[shadow_connections[i]]", frame, plane = ATOMS_FOV_SHADOWS_PLANE, offset_spokesman = src)
		if(corner_dirs[i] in diag_connections) // the glass diagonal: a wall2 pipe on top of the base corner
			overlays += get_wall_object(icon, "wall2", frame, plane = ATOMS_FOV_SHADOWS_PLANE, offset_spokesman = src)

/atom/movable/atom_shadow/wall/proc/update_diagonals()
	if(!isturf(loc))
		return
	for(var/dir in diag_connections)
		var/diag = turn(dir, 45)
		if(!(diag in diag_connections) && mask_at(diag))
			diag_connections += diag
		diag = turn(dir, -45)
		if(!(diag in diag_connections) && mask_at(diag))
			diag_connections += diag

/// Does the tile on that side of us hold a mask the shadow could link with?
/atom/movable/atom_shadow/wall/proc/mask_at(dir)
	var/turf/current_turf = get_step(src, dir)
	if(istype(current_turf, /turf/closed))
		var/turf/closed/current_wall = current_turf
		if(current_wall.shadow) // walls own one, bare closed turfs don't
			return TRUE
	var/obj/machinery/door/current_door = locate(/obj/machinery/door) in current_turf
	if(current_door?.shadow) // solid doors own one, glass doors stay empty
		return TRUE
	var/obj/structure/falsewall/current_falsewall = locate(/obj/structure/falsewall) in current_turf
	return current_falsewall?.shadow?.visible_shadow // open and see-through fake walls keep their mask hidden

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

// MARK: False Wall
/atom/movable/atom_shadow/wall/falsewall
	var/obj/structure/falsewall/owner
	var/visible_shadow = TRUE

/atom/movable/atom_shadow/wall/falsewall/Initialize(mapload, obj/structure/falsewall/new_owner)
	. = ..()
	owner = new_owner

/atom/movable/atom_shadow/wall/falsewall/proc/set_visible(opacity)
	if(visible_shadow == opacity)
		return
	visible_shadow = opacity
	update_icon()

/atom/movable/atom_shadow/wall/falsewall/update_icon()
	if(!visible_shadow)
		overlays.Cut()
		icon_state = "blank"
		return NONE
	return ..()

/atom/movable/atom_shadow/wall/falsewall/Destroy()
	if(!QDELETED(owner) && owner.shadow == src)
		owner.shadow = null
	owner = null
	return ..()
