/// Really fast ticking subsystem for ticking /datum/component/movable_physics instances
PROCESSING_SUBSYSTEM_DEF(movable_physics)
	name = "Movable Physics"
	priority = FIRE_PRIORITY_MOVABLE_PHYSICS
	wait = 0.05 SECONDS
	stat_tag = "MPhys"
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

/*
/datum/controller/subsystem/processing/movablephysics/fire(resumed = FALSE)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/component/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else
			if(thing.process(wait * 0.1) == PROCESS_KILL)
				// fully stop so that a future START_PROCESSING will work
				STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return
*/
