/atom/movable/screen/progbar_container
	name = "swing cooldown"
	icon_state = "progress_bar"
	screen_loc = "CENTER-1:0,SOUTH+1:5"
	var/datum/world_progressbar/progbar
	var/iteration = 0

/atom/movable/screen/progbar_container/Initialize(mapload)
	. = ..()
	progbar = new(src)
	progbar.qdel_when_done = FALSE
	progbar.bar.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	progbar.bar.appearance_flags = APPEARANCE_UI

/atom/movable/screen/progbar_container/Destroy()
	QDEL_NULL(progbar)
	return ..()

/atom/movable/screen/progbar_container/proc/on_changenext(datum/source, next_move)
	SIGNAL_HANDLER

	iteration++
	progbar.goal = next_move - world.time
	progbar.bar.icon_state = "0"

	progbar_process(next_move)

/atom/movable/screen/progbar_container/proc/progbar_process(next_move)
	set waitfor = FALSE

	var/start_time = world.time
	var/iteration = src.iteration
	while(iteration == src.iteration && (world.time < next_move))
		progbar.update(world.time - start_time)
		sleep(1)

	if(iteration == src.iteration)
		progbar.end_progress()
