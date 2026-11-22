// Horizon overrides for /obj/item/gun/ballistic: icons/overlays,
// suppressors, break-action gunplay, caliber modding, magazines and
// the canonical (un)loading interactions live here or in
// ballistic/stuff/wield_attack_self.dm.

/obj/item/gun/ballistic
	client_recoil_animation_information = list(
		"strength" = 0.35,
		"duration" = 2,
	)
	/// Whether the bolt drop sound should vary in pitch (upstream has
	/// bolt_drop_sound/volume but no vary toggle).
	var/bolt_drop_sound_vary = FALSE
	/// Wording for the cylinder, for break action guns
	var/cylinder_wording = "cylinder"
	/// If this is a break action bolt gun, is the cylinder open?
	var/cylinder_open = FALSE
	/// Do we have a unique open cylinder icon_state?
	var/cylinder_shows_open = FALSE
	/// Does the cylinder open sprite get updated depending on ammo count?
	var/cylinder_shows_ammo_count = FALSE
	/// Gives us an unique icon_state with an uncocked hammer, if we are a break action or revovler
	var/uncocked_icon_state = FALSE
	/// Unracking sound
	var/unrack_sound = '_horizon/sound/weapons/guns/decock_generic.wav'
	/// Volume of unracking sound
	var/unrack_sound_volume = 40
	/// Whether unracking sound should vary
	var/unrack_sound_vary = TRUE

/obj/item/gun/ballistic/update_icon_state()
	. = ..()
	if(empty_icon_state && !chambered)
		icon_state = "[icon_state]_empty"
	if((bolt_type == BOLT_TYPE_BREAK_ACTION) && uncocked_icon_state && bolt_locked)
		icon_state = "[icon_state]_uncocked"
	if(cylinder_open && cylinder_shows_open)
		icon_state = "[icon_state]_open"

/obj/item/gun/ballistic/update_overlays()
	. = ..()
	// Fire selector icon (upstream automatics like the C-20r use this).
	if(selector_switch_icon)
		if(burst_fire_selection)
			. += "[base_icon_state]_burst"
		else
			. += "[base_icon_state]_semi"
	if(suppressed && can_unsuppress) // integrated suppressors don't get an overlay
		var/image/suppressor_overlay = image(icon, "[base_icon_state]_suppressor")
		if(suppressor_x_offset)
			suppressor_overlay.pixel_x = suppressor_x_offset
		if(suppressor_y_offset)
			suppressor_overlay.pixel_y = suppressor_y_offset
		. += suppressor_overlay

	if(show_bolt_icon)
		if(bolt_type == BOLT_TYPE_LOCKING || bolt_type == BOLT_TYPE_OPEN || bolt_type == BOLT_TYPE_STANDARD)
			. += "[base_icon_state]_bolt[bolt_locked ? "_locked" : ""]"

	//this is duplicated in c20's update_overlayss due to a layering issue with the select fire icon
	if(!chambered && empty_indicator)
		. += "[base_icon_state]_empty"

	if(gun_flags & TOY_FIREARM_OVERLAY)
		. += "[base_icon_state]_toy"

	if(cylinder_open && cylinder_shows_open)
		. += "[base_icon_state]_cylinder[cylinder_shows_ammo_count ? "-[magazine ? magazine.ammo_count() : 0]" : ""]"

	if(!magazine || internal_magazine || !mag_display)
		return

	if(special_mags)
		. += "[base_icon_state]_mag_[initial(magazine.icon_state)]"
		if(mag_display_ammo && !magazine.ammo_count())
			. += "[base_icon_state]_mag_empty"
		return

	. += "[base_icon_state]_mag"
	if(!mag_display_ammo)
		return

	var/capacity_number
	switch(get_ammo() / magazine.max_ammo)
		if(1 to INFINITY) //cause we can have one in the chamber.
			capacity_number = 100
		if(0.8 to 1)
			capacity_number = 80
		if(0.6 to 0.8)
			capacity_number = 60
		if(0.4 to 0.6)
			capacity_number = 40
		if(0.2 to 0.4)
			capacity_number = 20
	if(capacity_number)
		. += "[base_icon_state]_mag_[capacity_number]"

/obj/item/gun/ballistic/screwdriver_act(mob/living/user, obj/item/tool)
	if(!can_modify_ammo)
		return ..()
	if(!user.is_holding(src))
		to_chat(user, span_warning("I need to hold [src] to modify it."))
		return TRUE

	if(bolt_type == BOLT_TYPE_STANDARD)
		if(get_ammo())
			to_chat(user, span_warning("I can't get at the internals while the gun has a bullet in it!"))
			return

		else if(!bolt_locked)
			to_chat(user, span_warning("I can't get at the internals while the bolt is down!"))
			return

	to_chat(user, span_notice("I begin to tinker with [src]..."))
	tool.play_tool_sound(src)
	if(!tool.use_tool(src, user, 3 SECONDS))
		return TRUE

	if(blow_up(user))
		user.visible_message(span_danger("[src] goes off!"), \
							span_userdanger("[src] goes off in my face!"))
		return

	if(magazine.caliber == initial_caliber)
		magazine.caliber = alternative_caliber
		if(alternative_ammo_misfires)
			never_misfire = FALSE
		fire_sound = alternative_fire_sound
		to_chat(user, span_notice("I modify [src]. Now it will fire [alternative_caliber] rounds."))
	else
		magazine.caliber = initial_caliber
		if(alternative_ammo_misfires)
			never_misfire = TRUE
		fire_sound = initial_fire_sound
		to_chat(user, span_notice("I reset [src]. Now it will fire [initial_caliber] rounds."))

/obj/item/gun/ballistic/attack_hand(mob/user, list/modifiers)
	if(cylinder_open && user.is_holding(src))
		add_fingerprint(user)
		var/obj/item/ammo_casing/casing = pull_cylinder_round()
		if(casing)
			casing.forceMove(drop_location())
			user.put_in_hands(casing)
			update_appearance()
			return
	return ..()

/obj/item/gun/ballistic/proc/pull_cylinder_round()
	if(!magazine)
		return null
	var/list/ammo = magazine.stored_ammo
	for(var/i in 1 to length(ammo))
		var/obj/item/ammo_casing/round = ammo[i]
		if(ispath(round)) // lazy map-spawned casings
			round = new round(magazine)
			ammo[i] = round
		if(QDELETED(round))
			continue // empty cylinder chamber (null slot)
		if(chambered == round)
			UnregisterSignal(chambered, COMSIG_MOVABLE_MOVED)
			chambered = null
		return round
	return null

/obj/item/gun/ballistic/proc/eject_spent_casings(mob/user)
	if(!magazine)
		return
	var/num_ejected = 0
	for(var/obj/item/ammo_casing/casing as anything in magazine.stored_ammo.Copy())
		if(ispath(casing) || QDELETED(casing))
			continue
		if(casing.loaded_projectile)
			continue
		if(casing == chambered)
			UnregisterSignal(chambered, COMSIG_MOVABLE_MOVED)
			chambered = null
		casing.forceMove(drop_location())
		casing.bounce_away(bounce_angle = null, still_warm = FALSE, sound_delay = 0)
		num_ejected++
	if(num_ejected)
		if(user)
			balloon_alert(user, "[num_ejected] spent [cartridge_wording]\s ejected")
		playsound(src, eject_sound, eject_sound_volume, eject_sound_vary)
		update_appearance()
		SEND_SIGNAL(src, COMSIG_UPDATE_AMMO_HUD) // [HORIZON-ADD] ammo counter refresh
	else if(user)
		balloon_alert(user, "no spent [cartridge_wording]s")

/obj/item/gun/ballistic/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(!isliving(user) || !user.Adjacent(src) || HAS_TRAIT(user, TRAIT_INCAPACITATED))
		return
	if(istype(over, /atom/movable/screen/inventory/hand))
		if(bolt_type == BOLT_TYPE_BREAK_ACTION)
			toggle_cylinder_open(user)
		else if(!internal_magazine && magazine)
			var/atom/movable/screen/inventory/hand/hand_slot = over
			eject_magazine(user, hand_index = hand_slot.held_index)
	else if(over == user && !user.is_holding(src) && isturf(loc))
		if(!internal_magazine && magazine)
			eject_magazine(user)

/obj/item/gun/ballistic/proc/toggle_cylinder_open(mob/user)
	cylinder_open = !cylinder_open
	if(cylinder_open)
		playsound(src, bolt_drop_sound, bolt_drop_sound_volume, bolt_drop_sound_vary)
		if(chambered)
			UnregisterSignal(chambered, COMSIG_MOVABLE_MOVED)
			chambered = null
	else
		playsound(src, lock_back_sound, lock_back_sound_volume, lock_back_sound_vary)
		chamber_round()
	if(user)
		// [HORIZON-ADD] players need feedback for the break-open state
		balloon_alert(user, "[cylinder_wording] [cylinder_open ? "open" : "closed"]")
	update_appearance()

/obj/item/gun/ballistic/before_can_shoot_checks(mob/living/user)
	. = ..()
	if((bolt_type == BOLT_TYPE_BREAK_ACTION) && !cylinder_open && semi_auto && bolt_locked)
		bolt_locked = FALSE
		chamber_round(TRUE)
		update_appearance()

/obj/item/gun/ballistic/can_shoot()
	. = ..()
	if(!.)
		return .
	if(cylinder_open)
		return FALSE
	if((bolt_type == BOLT_TYPE_BREAK_ACTION) && bolt_locked)
		return FALSE
	return TRUE

///Cock / decock the hammer on break action guns; behave like upstream otherwise.
/obj/item/gun/ballistic/rack(mob/user = null)
	if(bolt_type == BOLT_TYPE_BREAK_ACTION)
		if(cylinder_open)
			if(user)
				balloon_alert(user, "[cylinder_wording] is open!")
			return
		if(bolt_locked)
			bolt_locked = FALSE
			chamber_round(TRUE)
			playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
		else
			bolt_locked = TRUE
			playsound(src, unrack_sound, unrack_sound_volume, unrack_sound_vary)
		update_appearance()
		return
	return ..()

///Chamber a round. Break action guns rotate their cylinder instead of running
///upstream's magazine chambering, and the round stays inside the cylinder.
/obj/item/gun/ballistic/chamber_round(spin_cylinder = TRUE, replace_new_round)
	if(bolt_type == BOLT_TYPE_BREAK_ACTION)
		if(!magazine)
			return
		var/list/ammo = magazine.stored_ammo
		if(istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
			if(isnull(spin_cylinder) || spin_cylinder)
				chambered = magazine.get_round()
			else if(length(ammo))
				chambered = ammo[1]
			else
				chambered = null
		else if(length(ammo))
			var/obj/item/ammo_casing/rotated = ammo[length(ammo)]
			if(ispath(rotated))
				rotated = new rotated(magazine)
				ammo[length(ammo)] = rotated
			ammo -= rotated
			ammo.Insert(1, rotated)
			chambered = rotated
		else
			chambered = null
		if(replace_new_round && chambered)
			magazine.give_round(new chambered.type)
		return
	return ..()

/obj/item/gun/ballistic/handle_chamber(mob/living/user, empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	if(bolt_type == BOLT_TYPE_BREAK_ACTION)
		return
	return ..()

/obj/item/gun/ballistic/load_gun(obj/item/ammo, mob/living/user)
	if(bolt_type == BOLT_TYPE_BREAK_ACTION && !cylinder_open)
		balloon_alert(user, "[cylinder_wording] is closed!")
		return FALSE
	return ..()

/obj/item/gun/ballistic/postfire_empty_checks(last_shot_succeeded)
	. = ..()
	if(bolt_type == BOLT_TYPE_BREAK_ACTION && !cylinder_open)
		bolt_locked = TRUE
		update_appearance()

/obj/item/gun/ballistic/proc/chamber_examine(mob/user)
	. = list()
	var/p_Their = p_their(TRUE)
	var/p_have = p_have()
	if(bolt_type == BOLT_TYPE_BREAK_ACTION)
		. += "[p_Their] [cylinder_wording] is [cylinder_open ? span_green("open") : span_red("closed")]."
		if(cylinder_open)
			. += span_notice("Z ejects spent [cartridge_wording]s or closes it; right-click dumps everything.")
	if(cylinder_open)
		var/all_ammo = get_ammo(FALSE, FALSE)
		. += "[p_they(TRUE)] [p_have] [all_ammo ? all_ammo : "no"] round\s remaining."
		if(all_ammo)
			var/live_ammo = get_ammo(TRUE, FALSE)
			. += "[live_ammo ? live_ammo : "None"] of those are live rounds."

/obj/item/gun/ballistic/get_ammo(countchambered = TRUE, countempties = TRUE)
	if(bolt_type == BOLT_TYPE_BREAK_ACTION)
		countchambered = FALSE
	var/bullets = 0
	if(chambered && countchambered)
		bullets++
	if(magazine)
		bullets += magazine.ammo_count(countempties)
	return bullets

/obj/item/gun/ballistic/examine(mob/user)
	. = ..()
	if(bolt_type == BOLT_TYPE_BREAK_ACTION)
		. += chamber_examine(user)
