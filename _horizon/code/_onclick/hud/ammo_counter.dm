#define ui_ammocounter "EAST-1:28,CENTER+1:25"

/atom/movable/screen/ammo_counter
	name = "ammo counter"
	icon = '_horizon/icons/ui/gun_hud.dmi'
	icon_state = "backing"
	screen_loc = ui_ammocounter
	invisibility = INVISIBILITY_ABSTRACT
	/// Color for the OTH backing, numbers and indicator
	var/backing_color = "#ff0000ff"
	/// OTH position X00 - 0X0 - 00X
	var/oth_o
	var/oth_t
	var/oth_h
	/// Custom indicator sprite (e.g. "bullet")
	var/indicator
	/// Revolver chamber overlays cylinder is list(icon_state, pixel_x, pixel_y)
	var/list/revolver_chambers

/atom/movable/screen/ammo_counter/proc/turn_off()
	invisibility = INVISIBILITY_ABSTRACT
	backing_color = "#ff0000ff"
	oth_o = ""
	oth_t = ""
	oth_h = ""
	indicator = ""
	icon_state = initial(icon_state)
	revolver_chambers = null
	update_appearance()

/atom/movable/screen/ammo_counter/proc/turn_on()
	invisibility = 0

/atom/movable/screen/ammo_counter/proc/set_hud(_backing_color, _oth_o, _oth_t, _oth_h, _indicator)
	icon_state = initial(icon_state)
	revolver_chambers = null
	backing_color = _backing_color
	oth_o = _oth_o
	oth_t = _oth_t
	oth_h = _oth_h
	indicator = _indicator
	update_appearance()

/// Cylinder HUD. backing_state is revolver_backing_6 / _7 / _8.
/atom/movable/screen/ammo_counter/proc/set_revolver_hud(backing_state, list/chambers)
	icon_state = backing_state
	revolver_chambers = chambers
	oth_o = ""
	oth_t = ""
	oth_h = ""
	indicator = ""
	update_appearance()

/atom/movable/screen/ammo_counter/update_overlays()
	. = ..()
	if(length(revolver_chambers))
		for(var/list/chamber as anything in revolver_chambers)
			var/mutable_appearance/casing_overlay = mutable_appearance(icon, chamber[1])
			casing_overlay.pixel_x = chamber[2]
			casing_overlay.pixel_y = chamber[3]
			. += casing_overlay
		return
	if(oth_o)
		var/mutable_appearance/o_overlay = mutable_appearance(icon, oth_o)
		o_overlay.color = backing_color
		. += o_overlay
	if(oth_t)
		var/mutable_appearance/t_overlay = mutable_appearance(icon, oth_t)
		t_overlay.color = backing_color
		. += t_overlay
	if(oth_h)
		var/mutable_appearance/h_overlay = mutable_appearance(icon, oth_h)
		h_overlay.color = backing_color
		. += h_overlay
	if(indicator)
		var/mutable_appearance/indicator_overlay = mutable_appearance(icon, indicator)
		indicator_overlay.color = backing_color
		. += indicator_overlay

// MARK: HUD component for ballistic guns
/datum/component/ammo_hud
	var/atom/movable/screen/ammo_counter/hud
	var/indicator = "bullet"
	var/backing_color = "#ff0000ff"

/datum/component/ammo_hud/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/gun))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(wake_up))

/datum/component/ammo_hud/Destroy()
	turn_off()
	return ..()

/datum/component/ammo_hud/proc/wake_up(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(ishuman(user))
		var/mob/living/carbon/human/shoter = user
		if(shoter.is_holding(parent))
			var/datum/hud/holder_hud = shoter.hud_used
			hud = holder_hud.screen_objects[HUD_MOB_AMMO_COUNTER]
			turn_on()
		else
			turn_off()

/datum/component/ammo_hud/proc/turn_on()
	// Mobs whose hud has no ammo counter (monkeys, custom hud types) simply get none.
	if(!hud)
		return
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(turn_off))
	RegisterSignals(parent, list(COMSIG_UPDATE_AMMO_HUD, COMSIG_GUN_CHAMBER_PROCESSED), PROC_REF(update_hud))
	hud.turn_on()
	update_hud()

/datum/component/ammo_hud/proc/turn_off()
	SIGNAL_HANDLER
	UnregisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_UPDATE_AMMO_HUD, COMSIG_GUN_CHAMBER_PROCESSED))
	if(hud)
		hud.turn_off()
		hud = null

/datum/component/ammo_hud/proc/update_hud()
	SIGNAL_HANDLER
	if(!hud)
		return
	if(update_revolver_hud())
		return
	var/obj/item/gun/ballistic/pew = parent
	if(!istype(pew))
		return
	if(!pew.magazine)
		hud.set_hud(backing_color, "oe", "te", "he", "no_mag")
		return
	if(!pew.get_ammo())
		hud.set_hud(backing_color, "oe", "te", "he", "empty_flash")
		return

	var/rounds = num2text(pew.get_ammo())
	var/oth_o
	var/oth_t
	var/oth_h

	switch(length(rounds))
		if(1)
			oth_o = "o[rounds[1]]"
		if(2)
			oth_o = "o[rounds[2]]"
			oth_t = "t[rounds[1]]"
		if(3)
			oth_o = "o[rounds[3]]"
			oth_t = "t[rounds[2]]"
			oth_h = "h[rounds[1]]"
		else
			oth_o = "o9"
			oth_t = "t9"
			oth_h = "h9"
	hud.set_hud(backing_color, oth_o, oth_t, oth_h, indicator)

/datum/component/ammo_hud/proc/update_revolver_hud()
	var/obj/item/gun/ballistic/revolver/revolver = parent
	if(!istype(revolver))
		return FALSE
	var/obj/item/ammo_box/magazine/internal/cylinder/cylinder = revolver.magazine
	if(!istype(cylinder))
		return FALSE
	var/chambers = cylinder.max_ammo
	var/list/offsets = revolver_chamber_offsets(chambers)
	if(!offsets)
		return FALSE

	var/list/drawn = list()
	var/limit = min(length(cylinder.stored_ammo), length(offsets))
	for(var/index in 1 to limit)
		var/entry = cylinder.stored_ammo[index]
		var/live
		if(ispath(entry, /obj/item/ammo_casing))
			live = TRUE
		else if(istype(entry, /obj/item/ammo_casing))
			var/obj/item/ammo_casing/bullet = entry
			live = !!bullet.loaded_projectile
		else
			continue
		var/list/offset = offsets[index]
		drawn.len++
		drawn[length(drawn)] = list(live ? "revolver_casing_live" : "revolver_casing", offset[1], offset[2])
	hud.set_revolver_hud("revolver_backing_[chambers]", drawn)
	return TRUE

/datum/component/ammo_hud/proc/revolver_chamber_offsets(chamber_count)
	switch(chamber_count)
		if(6)
			return list(
				list(12, 22),
				list(20, 17),
				list(20, 7),
				list(12, 2),
				list(4, 7),
				list(4, 17),
			)
		if(7)
			return list(
				list(12, 23),
				list(21, 19),
				list(23, 10),
				list(17, 3),
				list(7, 3),
				list(1, 10),
				list(3, 19),
			)
		if(8)
			return list(
				list(12, 23),
				list(21, 21),
				list(23, 12),
				list(21, 3),
				list(12, 1),
				list(3, 3),
				list(1, 12),
				list(3, 21),
			)
	return null

#undef ui_ammocounter
