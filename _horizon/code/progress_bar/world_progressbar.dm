#define PROGRESSBAR_HEIGHT 6
#define PROGRESSBAR_ANIMATION_TIME 5


/atom/movable/screen/progbar_container/Initialize(mapload, datum/hud/hud_owner)
	if(hud_owner)
		RegisterSignal(hud_owner.mymob, COMSIG_LIVING_CHANGENEXT_MOVE, PROC_REF(on_changenext))
		if(hud_owner.progbar_icon)
			icon = hud_owner.progbar_icon
	. = ..()
	if(hud_owner?.progbar_icon && progbar?.bar)
		progbar.bar.icon = hud_owner.progbar_icon

/datum/world_progressbar
	///The progress bar visual element.
	var/obj/effect/abstract/progbar/bar
	///The atom who "created" the bar
	var/atom/movable/owner
	///Effectively the number of steps the progress bar will need to do before reaching completion.
	var/goal = 1
	///Control check to see if the progress was interrupted before reaching its goal.
	var/last_progress = 0
	///Variable to ensure smooth visual stacking on multiple progress bars.
	var/listindex = 0
	///Does this qdelete on completion?
	var/qdel_when_done = TRUE

/datum/world_progressbar/New(atom/movable/_owner, _goal, image/underlay)
	if(!_owner)
		return

	owner = _owner
	goal = _goal

	bar = new()

	if(underlay)
		if(!istype(underlay))
			underlay = image(underlay, dir = SOUTH)
			underlay.filters += filter(type = "outline", size = 1)
			underlay.maptext = null

		underlay.pixel_y = 2
		underlay.alpha = 200
		underlay.plane = GAME_PLANE
		underlay.layer = FLY_LAYER
		underlay.appearance_flags = APPEARANCE_UI
		bar.underlays += underlay

	owner.add_viscontents(bar)

	animate(bar, alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

	RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(owner_delete))

/datum/world_progressbar/Destroy()
	owner = null
	QDEL_NULL(bar)
	return ..()


/datum/world_progressbar/proc/owner_delete()
	qdel(src)

///Updates the progress bar image visually.
/datum/world_progressbar/proc/update(progress)
	progress = clamp(progress, 0, goal)
	if(progress == last_progress)
		return
	last_progress = progress
	bar.icon_state = "[round((progress / goal) * 16)]"

/datum/world_progressbar/proc/end_progress()
	if(last_progress != goal)
		bar.icon_state = "[bar.icon_state]_fail"

	if(qdel_when_done)
		animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)
	else
		bar.icon_state = "16"

#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT

/obj/effect/abstract/progbar
	icon = null
	icon_state = "16"
	plane = GAME_PLANE
	layer = FLY_LAYER
	appearance_flags = APPEARANCE_UI | KEEP_APART
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = NONE //We don't want VIS_INHERIT_PLANE


/mob/living/changeNext_move(num)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIVING_CHANGENEXT_MOVE, next_move)

/// Add an atom or list of atoms to our vis_contents
/atom/proc/add_viscontents(atom/A)
	src:vis_contents += A
