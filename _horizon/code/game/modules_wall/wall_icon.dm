// MARK: Algorithm
/mutable_appearance/frill
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/proc/get_wall_object(icon, icon_state, dir = 2, pixel_x = 0, pixel_y = 0, plane = GAME_PLANE, layer = ABOVE_MOB_LAYER, atom/offset_spokesman)
	var/mutable_appearance/frill/vis = new()
	vis.icon = icon
	vis.icon_state = icon_state
	vis.pixel_x = pixel_x
	vis.pixel_y = pixel_y
	vis.layer = layer
	if(isatom(offset_spokesman))
		SET_PLANE_EXPLICIT(vis, plane, offset_spokesman)
	else
		vis.plane = plane
	return make_mutable_appearance_directional(vis, dir)

/atom/proc/render_corner_frames(atom/A, list/wall_connections, plane, diagonal = FALSE)
	A.overlays.Cut()
	A.icon_state = "blank"
	for(var/i in 1 to 4)
		A.overlays += get_wall_object(A.icon, corner_icon_state(wall_connections[i], diagonal), 1<<(i-1), plane = plane, offset_spokesman = A)

/turf/closed/proc/build_wall_sprite(plane)
	var/mutable_appearance/frill/sprite = new()
	for(var/i in 1 to 4)
		sprite.overlays += get_wall_object(icon, corner_icon_state(wall_connections[i], diagonal), 1<<(i-1), plane = plane, offset_spokesman = src)
	return sprite

/proc/scan_blend_dirs(atom/source, list/blend_turfs, list/noblend_turfs, list/blend_objects, list/noblend_objects, list/see_through)
	var/list/wall_dirs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/current = get_step(source, direction)
		if(istype(current, /turf/closed))
			var/turf/closed/current_wall = current
			if(can_join_with(current_wall, source, blend_turfs, noblend_turfs))
				wall_dirs += direction
				if(!isnull(see_through) && !current_wall.opacity) // fakeglass & co: the wall merges with it, tag it for the shadow
					see_through += direction
			continue
		if(!(direction in GLOB.cardinals))
			continue
		for(var/obj/thing in current)
			if(can_join_with_object(thing, source, blend_objects, noblend_objects))
				wall_dirs += direction
				var/obj/machinery/door/current_door = thing
				if(!isnull(see_through) && (istype(current_door) ? current_door.glass : !thing.opacity)) // glass doors, see-through windows
					see_through += direction
				break
	return wall_dirs

/proc/can_join_with(turf/closed/W, atom/source, list/blend_turfs, list/noblend_turfs)
	if(W.type == source.type)
		return TRUE
	if(is_type_in_list(W, noblend_turfs))
		return FALSE
	if(is_type_in_list(W, blend_turfs))
		return TRUE
	return FALSE

/proc/can_join_with_object(obj/target, atom/source, list/blend_objects, list/noblend_objects)
	if(target.type == source.type)
		return TRUE
	if(is_type_in_list(target, noblend_objects))
		return FALSE
	if(is_type_in_list(target, blend_objects))
		return TRUE
	return FALSE

#define CORNER_NONE 0
#define CORNER_COUNTERCLOCKWISE 1
#define CORNER_DIAGONAL 2
#define CORNER_CLOCKWISE 4

/proc/dirs_to_corner_states(list/dirs)
	if(!istype(dirs))
		return

	var/list/ret = list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST)

	for(var/i = 1 to length(ret))
		var/dir = ret[i]
		. = CORNER_NONE
		if(dir in dirs)
			. |= CORNER_DIAGONAL
		if(turn(dir,45) in dirs)
			. |= CORNER_COUNTERCLOCKWISE
		if(turn(dir,-45) in dirs)
			. |= CORNER_CLOCKWISE
		ret[i] = "[.]"

	return ret

#undef CORNER_NONE
#undef CORNER_COUNTERCLOCKWISE
#undef CORNER_DIAGONAL
#undef CORNER_CLOCKWISE

/proc/corner_icon_state(corner, diagonal = FALSE)
	if(diagonal && (corner == "0" || corner == "5"))
		return "wall[corner]-diagonal"
	return "wall[corner]"

// MARK: Wall
/turf/closed/smooth_icon()
	if(!special_icon)
		return ..() //standard bitmask walls keep their normal smoothing
	smoothing_flags &= ~SMOOTH_QUEUED
	update_connections()
	update_icon()

	if(shadow)
		shadow.shadow_connections = wall_connections // the wall's corners are the shadow's corners
		shadow.update_diagonals() // the diagonals are the only math the shadow owns
		shadow.update_icon()

/turf/closed/update_icon()
	if(!special_icon)
		return ..()

	overlays.Cut()
	icon_state = "blank"
	overlays += build_wall_sprite(WALL_PLANE)

/turf/closed/mineral/update_icon()
	if(!special_icon)
		return ..()

	overlays.Cut()
	icon_state = "blank"
	overlays += build_wall_sprite(WALL_PLANE)
	overlays += build_wall_sprite(ABOVE_GAME_PLANE)

/turf/closed/proc/update_connections()
	var/list/glass = list()
	wall_connections = dirs_to_corner_states(scan_blend_dirs(src, blend_turfs, noblend_turfs, blend_objects, noblend_objects, glass))
	if(shadow)
		shadow.diag_connections = glass

// MARK: Shadow
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
	if(!istype(loc, /turf/closed))
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
	return current_door && current_door.shadow // solid doors own one, glass doors stay empty

// MARK: Window
/obj/structure/window/smooth_icon()
	if(!special_icon)
		return ..()
	smoothing_flags &= ~SMOOTH_QUEUED
	update_connections()
	update_icon(~UPDATE_SMOOTHING)

/obj/structure/window/update_icon()
	if(!special_icon)
		return ..()
	render_corner_frames(src, wall_connections, ABOVE_WALL_PLANE)

/obj/structure/window/proc/update_connections()
	wall_connections = dirs_to_corner_states(scan_blend_dirs(src, blend_turfs, noblend_turfs, blend_objects, noblend_objects))

// MARK: Window frame
/obj/structure/window_frame/smooth_icon()
	if(!special_icon)
		return ..()
	smoothing_flags &= ~SMOOTH_QUEUED
	update_connections()
	update_icon(~UPDATE_SMOOTHING)

/obj/structure/window_frame/update_icon()
	if(!special_icon)
		return ..()
	render_corner_frames(src, wall_connections, WALL_PLANE)

/obj/structure/window_frame/proc/update_connections()
	wall_connections = dirs_to_corner_states(scan_blend_dirs(src, blend_turfs, noblend_turfs, blend_objects, noblend_objects))

// MARK: Grille
/obj/structure/grille
	icon = '_horizon/icons/obj/smooth_structures/grille_simple.dmi'
	icon_state = "wall"
	var/list/wall_connections = list("0", "0", "0", "0")
	var/list/blend_turfs = list(/turf/closed)
	var/list/noblend_turfs = list(/turf/closed/mineral, /turf/closed/wall/mineral/titanium)
	var/list/blend_objects = list(/obj/structure/window/reinforced/fulltile, /obj/structure/window/framed, /obj/structure/window_frame, /obj/machinery/door)
	var/list/noblend_objects = list()
	var/special_icon = TRUE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null

/obj/structure/grille/smooth_icon()
	if(!special_icon)
		return ..()
	smoothing_flags &= ~SMOOTH_QUEUED
	update_connections()
	update_icon(~UPDATE_SMOOTHING)

/obj/structure/grille/update_icon()
	if(!special_icon)
		return ..()
	render_corner_frames(src, wall_connections, WALL_PLANE)

/obj/structure/grille/proc/update_connections()
	wall_connections = dirs_to_corner_states(scan_blend_dirs(src, blend_turfs, noblend_turfs, blend_objects, noblend_objects))
