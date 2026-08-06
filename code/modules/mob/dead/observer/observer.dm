GLOBAL_VAR_INIT(observer_default_invisibility, INVISIBILITY_OBSERVER)

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "ghost"
	plane = GHOST_PLANE
	stat = DEAD
	density = FALSE
	see_invisible = SEE_INVISIBLE_OBSERVER
	lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
	invisibility = INVISIBILITY_OBSERVER
	hud_type = /datum/hud/ghost
	movement_type = GROUND | FLYING
	light_system = OVERLAY_LIGHT
	light_range = 2.5
	light_power = 0.6
	light_on = FALSE
	shift_to_open_context_menu = FALSE
// [HORIZON-ADD] - Tag-Consistent-Ghost
	alpha = 180
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	var/has_mob_appearance = FALSE
// [/HORIZON-ADD]
	var/can_reenter_corpse
	///This variable is set to 1 when you enter the game as an observer.
	///If you died in the game and are a ghost - this will remain as FALSE.
	///Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/started_as_observer = FALSE

	var/atom/movable/following = null

	///The time between being able to use boo(), if fun_verbs is TRUE.
	COOLDOWN_DECLARE(bootime)
	///Boolean on whether this ghost has access to 'fun' verbs in the ghost menu.
	var/fun_verbs = FALSE

	var/mob/observetarget = null //The target mob that the ghost is observing. Used as a reference in logout()

	///Flags of huds the ghost currently has enabled, data huds & ghost vision by default.
	///Selection: GHOST_DATA_HUDS | GHOST_VISION | GHOST_HEALTH | GHOST_CHEM | GHOST_GAS
	var/ghost_hud_flags = NONE
	///The shape the ghost will make while orbiting mobs.
	var/ghost_orbit = GHOST_ORBIT_CIRCLE

	// Used for displaying in ghost chat, without changing the actual name
	// of the mob
	var/deadchat_name
	var/datum/spawners_menu/spawners_menu
	var/datum/minigames_menu/minigames_menu

	/// The POI we're orbiting (orbit menu)
	var/orbiting_ref

	///The description camera obscuras have when they get a photo of us.
	var/photo_description = "You can also see a g-g-g-g-ghooooost!"
	var/static/list/observer_hud_traits = list(
		TRAIT_SECURITY_HUD,
		TRAIT_MEDICAL_HUD,
		TRAIT_DIAGNOSTIC_HUD,
		TRAIT_BOT_PATH_HUD
	)

/mob/dead/observer/Initialize(mapload)
	set_invisibility(GLOB.observer_default_invisibility)
// [HORIZON-ADD] - Tag-Consistent-Ghost
	//Filters - Do this once on init because it shouldn't matter otherwise
	add_filter("ghost_desaturation", 1, color_matrix_filter(list(0.5,0.25,0.25, //Colour
	0.25,0.5,0.25,
	0.25,0.25,0.5,
	0,0,0)))
// [/HORIZON-ADD]
	var/turf/T
	var/mob/body = loc
	if(ismob(body))
		T = get_turf(body) //Where is the body located?
		set_appearance(body) // [HORIZON-ADD] - Tag-Consistent-Ghost
		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.ghostname || body.mind.name
		else
			name = body.real_name || generate_random_mob_name(gender)


		mind = body.mind //we don't transfer the mind but we keep a reference to it.

		if(HAS_TRAIT_FROM_ONLY(body, TRAIT_SUICIDED, REF(body))) // transfer if the body was killed due to suicide
			ADD_TRAIT(src, TRAIT_SUICIDED, REF(body))

// [HORIZON-ADD] - Tag-Consistent-Ghost
	var/list/dims = get_icon_dimensions(icon)
	var/req_width = dims["width"]
	var/req_height = dims["height"]
	var/icon/mask_icon = icon('_horizon/icons/effect/32x32.dmi', "ghost_fade")
	if(!ishuman(body) || (req_width > 32 && req_height > 32))
		mask_icon.Scale(req_width, req_height)

	add_filter("ghost_fade", 3, alpha_mask_filter(icon = mask_icon))
// [/HORIZON-ADD]

	if(!T || is_secret_level(T.z))
		var/list/turfs = get_area_turfs(/area/shuttle/arrival)
		if(length(turfs))
			T = pick(turfs)
		else
			T = SSmapping.get_station_center()

	abstract_move(T)

	//To prevent nameless ghosts
	name ||= generate_random_mob_name(FALSE)
	real_name = name

	AddElement(/datum/element/movetype_handler)

	add_to_dead_mob_list()

	for(var/datum/atom_hud/alternate_appearance/alt_hud as anything in GLOB.active_alternate_appearances)
		alt_hud.apply_to_new_mob(src)

	. = ..()

	grant_all_languages()
	setup_hud_traits()
	toggle_ghost_hud_flag(GHOST_VISION | GHOST_DATA_HUDS)

	SSpoints_of_interest.make_point_of_interest(src)
	add_traits(list(TRAIT_HEAR_THROUGH_DARKNESS, TRAIT_GOOD_HEARING, TRAIT_DETECT_STORM, TRAIT_GHOSTLY_MOB), INNATE_TRAIT)

/mob/dead/observer/get_photo_description(obj/item/camera/camera)
	if(!invisibility || camera.see_ghosts)
		return photo_description

/mob/dead/observer/narsie_act()
	var/old_color = color
	color = COLOR_CULT_RED
	animate(src, color = old_color, time = 10, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 1 SECONDS)

/mob/dead/observer/Destroy()
	if(ghost_hud_flags & GHOST_DATA_HUDS)
		remove_data_huds()

	// Update our old body's medhud since we're abandoning it
	if(isliving(mind?.current))
		mind.current.med_hud_set_status()


	QDEL_NULL(spawners_menu)
	QDEL_NULL(minigames_menu)
	return ..()

// [HORIZON-ADD] - Tag-Consistent-Ghost
/*
 * Updates the ghost's icon. If the ghost has a mob-based appearance
 */
/mob/dead/observer/update_icon(updates=ALL, new_form)
	if(has_mob_appearance)
		return
	. = ..()

/*
 * Copies the full visual appearance of a target living mob onto this ghost.
 */
/mob/dead/observer/proc/set_appearance(mob/target, icon_override = null)
	transform = null
	cut_overlays()

	if(!target)
		icon = initial(icon)
		icon_state = initial(icon_state)
		has_mob_appearance = FALSE
		return
	if(isanimal(target))
		var/mob/living/simple_animal/animal = target
		if(animal.icon_living)
			icon_override = animal.icon_living
	else if(isbasicmob(target))
		var/mob/living/basic/basic = target
		if(basic.icon_living)
			icon_override = basic.icon_living

	icon = target.icon
	icon_state = icon_override ? icon_override : target.icon_state

	copy_overlays(target, TRUE)
	has_mob_appearance = TRUE

	// Sanity, icon_state null means the target was gibbed or has no base icon state.
	if(isnull(icon_state))
		icon = initial(icon)
		icon_state = initial(icon_state)
		cut_overlays()
		has_mob_appearance = FALSE
// [/HORIZON-ADD]

/**
 * # Ghostize
 *
 * Creates a /mob/dead/observer and moves the player's key into it (among other handling for player->observer)
 * Ignores things like adminghosts and corpselocked (ethereal) players.
 * Args:
 * can_reenter_corse: Whether the new Ghost will be able to click "Re-enter body", TRUE by default.
 * forced: Whether we are forcing this player to be ghosted, ignoring things like corpselocking, FALSE by default.
 */
/mob/proc/ghostize(can_reenter_corpse = TRUE, forced = FALSE)
	if(!key)
		return
	if(IS_FAKE_KEY(key)) // Skip aghosts.
		return

	if(HAS_TRAIT(src, TRAIT_CORPSELOCKED) && !forced)
		if(can_reenter_corpse) //If you can re-enter the corpse you can't leave when corpselocked
			return
		if(ishuman(usr)) //following code only applies to those capable of having an ethereal heart, ie humans
			var/mob/living/carbon/human/crystal_fella = usr
			var/our_heart = crystal_fella.get_organ_slot(ORGAN_SLOT_HEART)
			if(istype(our_heart, /obj/item/organ/heart/ethereal)) //so you got the heart?
				var/obj/item/organ/heart/ethereal/ethereal_heart = our_heart
				ethereal_heart.stop_crystalization_process(crystal_fella) //stops the crystallization process

	stop_sound_channel(CHANNEL_HEARTBEAT) //Stop heartbeat sounds because You Are A Ghost Now
	var/mob/dead/observer/ghost = new(src) // Transfer safety to observer spawning proc.
	SStgui.on_transfer(src, ghost) // Transfer NanoUIs.
	ghost.can_reenter_corpse = can_reenter_corpse
	ghost.PossessByPlayer(key)
	ghost.client?.init_verbs()
	if(!can_reenter_corpse)// Disassociates observer mind from the body mind
		ghost.mind = null

// [HORIZON-ADD] - Tag-Consistent-Ghost
	// Client is now available, if appearance wasn't set, fall back to charslot appearance
	if(!ghost.has_mob_appearance)
		INVOKE_ASYNC(ghost, TYPE_PROC_REF(/mob/dead/observer, set_ghost_appearance))
// [/HORIZON-ADD]

	var/recordable_time = world.time
	var/mob/living/former_mob = ghost.mind?.current
	if(isliving(former_mob))
		recordable_time = former_mob.timeofdeath

	ghost.persistent_client?.time_of_death = recordable_time
	SEND_SIGNAL(src, COMSIG_MOB_GHOSTIZED)
	return ghost

/mob/dead/observer/ghostize(can_reenter_corpse, forced) //Sanity override // [HORIZON-ADD] - Tag-Consistent-Ghost
	return

/mob/living/ghostize(can_reenter_corpse = TRUE, forced = FALSE)
	. = ..()
	if(. && can_reenter_corpse)
		var/mob/dead/observer/ghost = .
		ghost.mind.current?.med_hud_set_status()

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
GAME_VERB_DESC(/mob/living, ghost, "Ghost", "Relinquish your life and enter the land of the dead.", "OOC")

	if(stat != STABLE && stat != DEAD)
		succumb()
	if(stat == DEAD)
		if(!HAS_TRAIT(src, TRAIT_CORPSELOCKED)) //corpse-locked have to confirm with the alert below
			ghostize(TRUE)
			return TRUE
	var/response = tgui_alert(usr, "Are you sure you want to ghost? You won't be able to re-enter your body!", "Confirm Ghost Observe", list("Ghost", "Stay in Body"))
	if(response != "Ghost")
		return FALSE//didn't want to ghost after-all
	ghostize(FALSE) // FALSE parameter is so we can never re-enter our body. U ded.
	return TRUE

GAME_VERB_DESC(/mob/eye, ghost, "Ghost", "Relinquish your life and enter the land of the dead.", "OOC")

	var/response = tgui_alert(usr, "Are you sure you want to ghost? If you ghost whilst still alive you cannot re-enter your body!", "Confirm Ghost Observe", list("Ghost", "Stay in Body"))
	if(response != "Ghost")
		return
	ghostize(FALSE)

/mob/dead/observer/Move(NewLoc, direct, glide_size_override = 32)
	setDir(direct) // [HORIZON-EDIT] - Tag-Consistent-Ghost

	if(glide_size_override)
		set_glide_size(glide_size_override)
	if(NewLoc)
		abstract_move(NewLoc)
	else
		var/turf/destination = get_turf(src)

		if((direct & NORTH) && y < world.maxy)
			destination = get_step(destination, NORTH)

		else if((direct & SOUTH) && y > 1)
			destination = get_step(destination, SOUTH)

		if((direct & EAST) && x < world.maxx)
			destination = get_step(destination, EAST)

		else if((direct & WEST) && x > 1)
			destination = get_step(destination, WEST)

		abstract_move(destination)//Get out of closets and such as a ghost

/mob/dead/observer/forceMove(atom/destination)
	abstract_move(destination) // move like the wind
	return TRUE

/mob/dead/observer/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/area/new_area = get_area(src)
	if(new_area != ambience_tracked_area)
		update_ambience_area(new_area)

GAME_VERB(/mob/dead/observer, reenter_corpse, "Re-enter Corpse", null)

	if(!client)
		return
	if(!mind || QDELETED(mind.current))
		to_chat(src, span_warning("You have no body."))
		return
	if(!can_reenter_corpse)
		to_chat(src, span_warning("You cannot re-enter your body."))
		return
	if(mind.current.key && !IS_FAKE_KEY(mind.current.key)) //makes sure we don't accidentally kick any clients
		to_chat(usr, span_warning("Another consciousness is in your body...It is resisting you."))
		return
	client.view_size.resetToDefault()//Let's reset so people can't become allseeing gods
	SStgui.on_transfer(src, mind.current) // Transfer NanoUIs.
	if(mind.current.stat == DEAD && SSlag_switch.measures[DISABLE_DEAD_KEYLOOP] && !client.holder)
		to_chat(src, span_warning("To leave your body again use the 'Ghost verb' (in the command bar)."))
	mind.current.PossessByPlayer(key)
	mind.current.client.init_verbs()
	return TRUE

GAME_VERB(/mob/dead/observer, do_not_resuscitate, "Do Not Resuscitate", null)

	if(!can_reenter_corpse)
		to_chat(usr, span_warning("You're already stuck out of your body!"))
		return FALSE

	var/response = tgui_alert(usr, "Are you sure you want to prevent (almost) all means of resuscitation? This cannot be undone.", "Are you sure you want to stay dead?", list("DNR","Save Me"))
	if(response == "DNR")
		stay_dead()

/mob/dead/observer/proc/stay_dead()
	if(!can_reenter_corpse)
		to_chat(usr, span_warning("You're already stuck out of your body!"))
		return FALSE

	can_reenter_corpse = FALSE
	var/mob/living/current_mob = mind.current
	if(istype(current_mob))
		// Update med huds
		current_mob.med_hud_set_status()
		current_mob.log_message("had their player ([key_name(src)]) do-not-resuscitate / DNR", LOG_GAME, color = COLOR_GREEN, log_globally = FALSE)
		SEND_SIGNAL(current_mob, COMSIG_LIVING_DNR, src)

	log_message("has opted to do-not-resuscitate / DNR from their body ([current_mob])", LOG_GAME, color = COLOR_GREEN)

	// Disassociates observer mind from the body mind
	mind = null

	to_chat(src, span_boldnotice("You can no longer be brought back into your body."))
	return TRUE

/mob/dead/observer/proc/send_revival_notification(message, sound, atom/source, flashwindow)
	if(flashwindow)
		window_flash(client)
	if(message)
		to_chat(src, span_ghostalert("[message]"))
		if(source)
			var/atom/movable/screen/alert/A = throw_alert("[REF(source)]_revival", /atom/movable/screen/alert/revival)
			if(A)
				var/ui_style = client?.prefs?.read_preference(/datum/preference/choiced/ui_style)
				if(ui_style)
					A.icon = ui_style2icon(ui_style)
				A.desc = message
				var/old_layer = source.layer
				var/old_plane = source.plane
				source.layer = FLOAT_LAYER
				source.plane = FLOAT_PLANE
				A.add_overlay(source)
				source.layer = old_layer
				source.plane = old_plane
	to_chat(src, span_ghostalert("<a href=byond://?src=[REF(src)];reenter=1>(Click to re-enter)</a>"))
	if(sound)
		SEND_SOUND(src, sound(sound))

GAME_VERB(/mob/dead/observer, dead_tele, "Teleport", null)

	if(!isobserver(usr))
		to_chat(usr, span_warning("Not when you're not dead!"))
		return
	var/list/filtered = list()
	for(var/area/A as anything in get_sorted_areas())
		if(!(A.area_flags & HIDDEN_AREA))
			filtered += A
	var/area/thearea = tgui_input_list(usr, "Area to jump to", "BOOYEA", filtered)

	if(isnull(thearea))
		return
	if(!isobserver(usr))
		to_chat(usr, span_warning("Not when you're not dead!"))
		return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !length(L))
		to_chat(usr, span_warning("No area available."))
		return

	usr.abstract_move(pick(L))

GAME_VERB(/mob/dead/observer, follow, "Orbit", null)

	GLOB.orbit_menu.show(src)

GAME_VERB(/mob/dead/observer, jumptomob, "Jump to Mob", null) //Moves the ghost instead of just changing the ghosts's eye -Nodrak

	if(!isobserver(usr)) //Make sure they're an observer!
		return

	var/list/possible_destinations = SSpoints_of_interest.get_mob_pois()
	var/target = null

	target = tgui_input_list(usr, "Please, select a player!", "Jump to Mob", possible_destinations)
	if(isnull(target))
		return
	if (!isobserver(usr))
		return

	var/mob/destination_mob = possible_destinations[target] //Destination mob

	// During the break between opening the input menu and selecting our target, has this become an invalid option?
	if(!SSpoints_of_interest.is_valid_poi(destination_mob))
		return

	var/mob/source_mob = src  //Source mob
	var/turf/destination_turf = get_turf(destination_mob) //Turf of the destination mob

	if(isturf(destination_turf))
		source_mob.abstract_move(destination_turf)
	else
		to_chat(source_mob, span_danger("This mob is not located in the game world."))

GAME_VERB(/mob/dead/observer, change_view_range, "View Range", null)

	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !client?.holder)
		to_chat(usr, span_notice("That verb is currently globally disabled."))
		return

	var/max_view = GHOST_MAX_VIEW_RANGE_DEFAULT // [HORIZON-EDIT] - Tag-Consistent-Ghost
	if(client.view_size.getView() == client.view_size.default)
		var/list/views = list()
		for(var/i in 7 to max_view)
			views |= i
		var/new_view = tgui_input_list(usr, "New view", "Modify view range", views)
		if(new_view)
			client.view_size.setTo(clamp(new_view, 7, max_view) - 7)
	else
		client.view_size.resetToDefault()

GAME_VERB(/mob/dead/observer, toggle_ghostsee, "Toggle Ghost Vision", null)

	toggle_ghost_hud_flag(GHOST_VISION)
	update_sight()
	to_chat(usr, span_boldnotice("You [(ghost_hud_flags & GHOST_VISION) ? "now" : "no longer"] have ghost vision."))

GAME_VERB(/mob/dead/observer, toggle_darkness, "Toggle Darkness", null)

	switch(lighting_cutoff)
		if (LIGHTING_CUTOFF_VISIBLE)
			lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
		if (LIGHTING_CUTOFF_MEDIUM)
			lighting_cutoff = LIGHTING_CUTOFF_HIGH
		if (LIGHTING_CUTOFF_HIGH)
			lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
		else
			lighting_cutoff = LIGHTING_CUTOFF_VISIBLE

	update_sight()

GAME_VERB(/mob/dead/observer, view_manifest, "View Crew Manifest", null)

	GLOB.manifest.ui_interact(src)

GAME_VERB(/mob/dead/observer, observe, "Observe", null)

	if(!isobserver(usr) || HAS_TRAIT(src, TRAIT_NO_OBSERVE)) //Make sure they're an observer!
		return

	reset_perspective(null)

	var/list/possible_destinations = SSpoints_of_interest.get_mob_pois()
	var/target = null

	target = tgui_input_list(usr, "Please, select a player!", "Jump to Mob", possible_destinations)
	if(isnull(target))
		return
	if (!isobserver(usr))
		return

	reset_perspective(null) // Reset again for sanity

	var/mob/chosen_target = possible_destinations[target]

	// During the break between opening the input menu and selecting our target, has this become an invalid option?
	if(!SSpoints_of_interest.is_valid_poi(chosen_target))
		return

	if (chosen_target == usr)
		return

	do_observe(chosen_target)

GAME_VERB(/mob/dead/observer, tray_view, "T-ray scan", null)

	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !client?.holder)
		to_chat(usr, span_notice("That verb is currently globally disabled."))
		return

	t_ray_scan(src)

GAME_VERB(/mob/dead/observer, toggle_data_huds, "Toggle Sec/Med/Diag HUD", null)

	toggle_ghost_hud_flag(GHOST_DATA_HUDS)
	if(ghost_hud_flags & GHOST_DATA_HUDS)
		to_chat(src, span_notice("Data HUDs enabled."))
	else
		to_chat(src, span_notice("Data HUDs disabled."))

GAME_VERB(/mob/dead/observer, toggle_health_scan, "Toggle Health Scan", null)

	toggle_ghost_hud_flag(GHOST_HEALTH)
	if(ghost_hud_flags & GHOST_HEALTH)
		to_chat(src, span_notice("Health scan enabled."))
	else
		to_chat(src, span_notice("Health scan disabled."))

GAME_VERB(/mob/dead/observer, toggle_chem_scan, "Toggle Chem Scan", null)

	toggle_ghost_hud_flag(GHOST_CHEM)
	if(ghost_hud_flags & GHOST_CHEM)
		to_chat(src, span_notice("Chem scan enabled."))
	else
		to_chat(src, span_notice("Chem scan disabled."))

GAME_VERB(/mob/dead/observer, toggle_gas_scan, "Toggle Gas Scan", null)

	toggle_ghost_hud_flag(GHOST_GAS)
	if(ghost_hud_flags & GHOST_GAS)
		to_chat(src, span_notice("Gas scan enabled."))
	else
		to_chat(src, span_notice("Gas scan disabled."))

GAME_VERB(/mob/dead/observer, restore_ghost_appearance, "Restore Ghost Character", null)

	set_ghost_appearance()
	if(client?.prefs)
		var/real_name = client.prefs.read_preference(/datum/preference/name/real_name)
		deadchat_name = real_name
		if(mind)
			mind.ghostname = real_name
		name = real_name

/// Toggles a flag from ghost hud and updates the mob accordingly
/mob/dead/observer/proc/toggle_ghost_hud_flag(toggled)
	ghost_hud_flags ^= toggled
	if(ghost_hud_flags & GHOST_DATA_HUDS)
		show_data_huds()
	else
		remove_data_huds()
	update_sight()
	for(var/hud_key in hud_used?.screen_objects)
		var/atom/movable/screen/ghost/hudbox/hud = hud_used.screen_objects[hud_key]
		if(istype(hud) && (hud.relevant_flag & toggled))
			hud.update_appearance(UPDATE_ICON_STATE)

// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(atom/movable/target)
	if (!istype(target) || (is_secret_level(target.z) && !client?.holder))
		return

	var/list/icon_dimensions = get_icon_dimensions(target.icon)
	var/orbitsize = (icon_dimensions["width"] + icon_dimensions["height"]) * 0.5
	orbitsize -= (orbitsize/ICON_SIZE_ALL)*(ICON_SIZE_ALL*0.25)

	var/rot_seg

	switch(ghost_orbit)
		if(GHOST_ORBIT_TRIANGLE)
			rot_seg = 3
		if(GHOST_ORBIT_SQUARE)
			rot_seg = 4
		if(GHOST_ORBIT_PENTAGON)
			rot_seg = 5
		if(GHOST_ORBIT_HEXAGON)
			rot_seg = 6
		else //Circular
			rot_seg = 36 //360/10 bby, smooth enough aproximation of a circle

	orbit(target,orbitsize, FALSE, 20, rot_seg)

/mob/dead/observer/orbit()
	setDir(2)//reset dir so the right directional sprites show up
	return ..()

/mob/dead/observer/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	//restart our floating animation after orbit is done.
	pixel_y = base_pixel_y
	// if we were autoobserving, reset perspective
	if (!isnull(client) && !isnull(client.eye))
		reset_perspective(null)

GAME_VERB_HIDDEN(/mob/dead/observer, add_view_range, "Add View Range")
	VERB_ARG(input, VERB_ARG_TYPE_NUM, VERB_ARG_SOURCE_INPUT)

	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !client?.holder)
		to_chat(usr, span_notice("That verb is currently globally disabled."))
		return

	var/max_view = GHOST_MAX_VIEW_RANGE_DEFAULT // [HORIZON-EDIT] - Tag-Consistent-Ghost
	if(input)
		client.rescale_view(input, 0, ((max_view * 2) + 1) - 15)

/mob/dead/observer/proc/boo()
	if(!COOLDOWN_FINISHED(src, bootime))
		return
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L?.flicker())
		COOLDOWN_START(src, bootime, 60 SECONDS)
	//Maybe in the future we can add more <i>spooky</i> code here!

/mob/dead/observer/update_sight()
	if(!(ghost_hud_flags & GHOST_VISION))
		set_invis_see(SEE_INVISIBLE_LIVING)
	else
		set_invis_see(SEE_INVISIBLE_OBSERVER)

	..()

/mob/dead/observer/proc/possess()
	var/list/possessible = list()
	for(var/mob/living/L in GLOB.alive_mob_list)
		if(istype(L,/mob/living/carbon/human/dummy) || !get_turf(L)) //Haha no.
			continue
		if(!(L in GLOB.player_list) && !L.mind)
			possessible += L

	var/mob/living/target = tgui_input_list(usr, "Your new life begins today!", "Possess Mob", sort_names(possessible))

	if(!target)
		return FALSE

	if(ismegafauna(target))
		to_chat(src, span_warning("This creature is too powerful for you to possess!"))
		return FALSE

	if(can_reenter_corpse && mind?.current)
		if(tgui_alert(usr, "Your soul is still tied to your former life as [mind.current.name], if you go forward there is no going back to that life. Are you sure you wish to continue?", "Move On", list("Yes", "No")) == "No")
			return FALSE
	if(target.key)
		to_chat(src, span_warning("Someone has taken this body while you were choosing!"))
		return FALSE

	target.PossessByPlayer(key)
	target.set_faction(list(FACTION_NEUTRAL))
	return TRUE

/mob/dead/observer/_pointed(atom/pointed_at)
	if(!..())
		return FALSE

	visible_message(span_deadsay("<b>[src]</b> points to [pointed_at]."))

//this is called when a ghost is drag clicked to something.
/mob/dead/observer/mouse_drop_dragged(atom/over, mob/user)
	if (isobserver(user) && user.client.holder && (isliving(over) || iseyemob(over)))
		user.client.holder.cmd_ghost_drag(src, over)

/mob/dead/observer/Topic(href, href_list)
	..()
	if(usr == src)
		if(href_list["follow"])
			var/atom/movable/target = locate(href_list["follow"])
			if(istype(target) && (target != src))
				ManualFollow(target)
				return

		if(href_list["x"] && href_list["y"] && href_list["z"])
			var/tx = text2num(href_list["x"])
			var/ty = text2num(href_list["y"])
			var/tz = text2num(href_list["z"])
			var/turf/target = locate(tx, ty, tz)
			if(istype(target))
				abstract_move(target)
				return

		if(href_list["reenter"])
			reenter_corpse()
			return

		if(href_list["view"])
			var/atom/target = locate(href_list["view"])
			observer_view(target)
			return

		if(href_list["play"])
			var/atom/movable/target = locate(href_list["play"])
			jump_to_interact(target)

/// We orbit and interact with the target
/mob/dead/observer/proc/jump_to_interact(atom/target)
	if(isnull(target) || target == src)
		return

	ManualFollow(target)
	target.attack_ghost(usr)

/// We orbit the target or jump if its a turf
/mob/dead/observer/proc/observer_view(atom/target)
	if(isnull(target) || target == src)
		return

	if(isturf(target))
		abstract_move(target)
		return

	ManualFollow(target)

//We don't want to update the current var
//But we will still carry a mind.
/mob/dead/observer/mind_initialize()
	return

/mob/dead/observer/proc/show_data_huds()
	PRIVATE_PROC(TRUE)
	ghost_hud_flags |= GHOST_DATA_HUDS // only for safety, it should be set already.
	add_traits(observer_hud_traits, REF(src))

/mob/dead/observer/proc/remove_data_huds()
	PRIVATE_PROC(TRUE)
	ghost_hud_flags &= ~GHOST_DATA_HUDS // only for safety, it should be unset already.
	remove_traits(observer_hud_traits, REF(src))

/**
 * Builds character appearance from client preferences using a dummy mob
 */
/mob/dead/observer/proc/set_ghost_appearance()
	if(!client?.prefs)
		return

	client.prefs.apply_character_randomization_prefs()

// [HORIZON-EDIT] - Tag-Consistent-Ghost
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy("ghost_appearance")
	mannequin.wipe_state()

	client.prefs.apply_prefs_to(mannequin, TRUE)

	// Dress the dummy in the player's preferred job outfit + loadout
	var/datum/job/no_job = SSjob.get_job_type(/datum/job/unassigned)
	var/datum/job/preview_job = client.prefs.get_highest_priority_job() || no_job
	mannequin.dress_up_as_job(
		equipping = preview_job,
		visual_only = TRUE,
		player_client = client,
		consistent = TRUE,
	)

	set_appearance(mannequin)
	unset_busy_human_dummy("ghost_appearance")
// [/HORIZON-EDIT]

/mob/dead/observer/can_perform_action(atom/movable/target, action_bitflags)
	return isAdminGhostAI(usr)

/mob/dead/observer/is_literate()
	return TRUE

/mob/dead/observer/can_read(atom/viewed_atom, reading_check_flags, silent)
	return TRUE // we want to bypass all the checks

/mob/dead/observer/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name) // [HORIZON-EDIT] - Tag-Consistent-Ghost
		if(NAMEOF(src, invisibility))
			set_invisibility(invisibility) // updates light

/mob/dead/observer/reset_perspective(atom/A)
	if(client)
		if(ismob(client.eye) && (client.eye != src))
			cleanup_observe()
	if(..())
		if(hud_used)
			client.clear_screen()
			hud_used.show_hud(hud_used.hud_version)


/mob/dead/observer/proc/cleanup_observe()
	if(isnull(observetarget))
		return
	var/mob/target = observetarget
	observetarget = null
	client?.perspective = initial(client.perspective)
	set_sight(initial(sight))
	if(target)
		UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)
		hide_other_mob_action_buttons(target)
		LAZYREMOVE(target.observers, src)

/mob/dead/observer/proc/do_observe(mob/mob_eye)
	if(isnewplayer(mob_eye))
		stack_trace("/mob/dead/new_player: \[[mob_eye]\] is being observed by [key_name(src)]. This should never happen and has been blocked.")
		message_admins("[ADMIN_LOOKUPFLW(src)] attempted to observe someone in the lobby: [ADMIN_LOOKUPFLW(mob_eye)]. This should not be possible and has been blocked.")
		return

	if(!isnull(observetarget))
		stack_trace("do_observe called on an observer ([src]) who was already observing something! (observing: [observetarget], new target: [mob_eye])")
		message_admins("[ADMIN_LOOKUPFLW(src)] attempted to observe someone while already observing someone, \
			this is a bug (and a past exploit) and should be investigated.")
		return

	if(HAS_TRAIT(src, TRAIT_NO_OBSERVE))
		return

	//Istype so we filter out points of interest that are not mobs
	if(client && mob_eye && istype(mob_eye))
		client.set_eye(mob_eye)
		client.perspective = EYE_PERSPECTIVE
		if(is_secret_level(mob_eye.z) && !client?.holder)
			set_sight(null) //we dont want ghosts to see through walls in secret areas
		RegisterSignal(mob_eye, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_observing_z_changed))
		if(mob_eye.hud_used)
			client.clear_screen()
			LAZYOR(mob_eye.observers, src)
			mob_eye.hud_used.show_hud(mob_eye.hud_used.hud_version, src)
			observetarget = mob_eye

/mob/dead/observer/proc/on_observing_z_changed(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER

	if(is_secret_level(new_turf.z) && !client?.holder)
		set_sight(null) //we dont want ghosts to see through walls in secret areas
	else
		set_sight(initial(sight))

/mob/dead/observer/AltClickOn(atom/target)
	client.loot_panel.open(get_turf(target))

/mob/dead/observer/AltClickSecondaryOn(atom/target)
	if(client && check_rights_for(client, R_DEBUG))
		client.toggle_tag_datum(src)

/mob/dead/observer/CtrlShiftClickOn(atom/target)
	if(isobserver(target) && check_rights(R_SPAWN))
		var/mob/dead/observer/target_ghost = target

		target_ghost.change_mob_type(/mob/living/carbon/human , null, null, TRUE) //always delmob, ghosts shouldn't be left lingering

/mob/dead/observer/examine(mob/user)
	. = ..()
	if(!invisibility)
		. += "It seems extremely obvious."

/mob/dead/observer/examine_more(mob/user)
	if(!isAdminObserver(user))
		return ..()
	. = list(span_notice("<i>You examine [src] closer, and note the following...</i>"))
	. += list("\t>[span_admin("[ADMIN_FULLMONTY(src)]")]")


/mob/dead/observer/proc/set_invisibility(value)
	SetInvisibility(value, id=type)
	set_light_on(!value ? TRUE : FALSE)


// Ghosts have no momentum, being massless ectoplasm
/mob/dead/observer/Process_Spacemove(movement_dir, continuous_move = FALSE)
	return TRUE

/proc/set_observer_default_invisibility(amount, message=null)
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.set_invisibility(amount)
		if(message)
			to_chat(G, message)
	GLOB.observer_default_invisibility = amount

GAME_VERB_PROC(/mob/dead/observer, open_spawners_menu, "Spawners Menu", null)
	if(!spawners_menu)
		spawners_menu = new(src)

	spawners_menu.ui_interact(src)

GAME_VERB_PROC(/mob/dead/observer, open_minigames_menu, "Minigames Menu", null)
	if(!client)
		return
	if(!isobserver(src))
		to_chat(usr, span_warning("You must be a ghost to play minigames!"))
		return
	if(!minigames_menu)
		minigames_menu = new(src)

	minigames_menu.ui_interact(src)

/mob/dead/observer/default_lighting_cutoff()
	var/datum/preferences/prefs = client?.prefs
	if(!prefs || (client?.combo_hud_enabled && prefs.toggles & COMBOHUD_LIGHTING))
		return ..()
	return GLOB.ghost_lightings[prefs.read_preference(/datum/preference/choiced/ghost_lighting)]

/// Called when we exit the orbiting state
/mob/dead/observer/proc/on_deorbit(datum/source)
	SIGNAL_HANDLER

	orbiting_ref = null
