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

/atom/movable/screen/ammo_counter/proc/turn_off()
	invisibility = INVISIBILITY_ABSTRACT
	backing_color = "#ff0000ff"
	oth_o = ""
	oth_t = ""
	oth_h = ""
	indicator = ""
	update_appearance()

/atom/movable/screen/ammo_counter/proc/turn_on()
	invisibility = 0

/atom/movable/screen/ammo_counter/proc/set_hud(_backing_color, _oth_o, _oth_t, _oth_h, _indicator)
	backing_color = _backing_color
	oth_o = _oth_o
	oth_t = _oth_t
	oth_h = _oth_h
	indicator = _indicator
	update_appearance()

/atom/movable/screen/ammo_counter/update_overlays()
	. = ..()
	cut_overlays()
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
/datum/hud
	var/atom/movable/screen/ammo_counter

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
		var/mob/living/carbon/human/H = user
		if(H.is_holding(parent))
			if(H.hud_used)
				hud = H.hud_used.ammo_counter
				turn_on()
		else
			turn_off()

/datum/component/ammo_hud/proc/turn_on()
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

// MARK: Attachment item
/obj/item/attachment/ammo_counter
	name = "ammunition counter"
	desc = "A computerized ammunition tracker for use on conventional firearms. Includes a small toggle for telling the user when ammo is depleted. Capable of mounting on both a railing or a scope, depending on the user's preference."
	icon = '_horizon/icons/obj/items/guns/attachments.dmi'
	icon_state = "ammo_counter"
	w_class = WEIGHT_CLASS_TINY

	attach_features_flags = ATTACH_REMOVABLE_HAND|ATTACH_TOGGLE|ATTACH_NO_SPRITE
	slot = ATTACHMENT_SLOT_SCOPE
	pixel_shift_x = 0
	pixel_shift_y = 0

	/// Whether the empty-magazine alarm beep is enabled (uses the gun's empty_alarm).
	var/alarm_enabled = TRUE

/// Attaching to a ballistic gun adds the ammo HUD component to it.
/obj/item/attachment/ammo_counter/apply_attachment(obj/item/gun/gun, mob/user)
	. = ..()
	if(!istype(gun, /obj/item/gun/ballistic))
		to_chat(user, span_notice("[gun] has no magazine for [src] to track!"))
		return FALSE
	if(gun.GetComponent(/datum/component/ammo_hud))
		to_chat(user, span_notice("[gun] already has an ammo counter installed!"))
		return FALSE
	gun.AddComponent(/datum/component/ammo_hud)
	gun.GetComponent(/datum/component/ammo_hud).wake_up(source = gun, user = user, slot = ITEM_SLOT_HANDS)
	return TRUE

/// Detaching removes the ammo HUD component again.
/obj/item/attachment/ammo_counter/remove_attachment(obj/item/gun/gun, mob/user)
	. = ..()
	var/datum/component/ammo_hud/old_counter = gun.GetComponent(/datum/component/ammo_hud)
	if(old_counter)
		old_counter.turn_off()
		qdel(old_counter)
		return TRUE

/// In-hand use: switch between the scope and rail mounting slots.
/obj/item/attachment/ammo_counter/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/items/click.ogg', 25)
	if(slot == initial(slot))
		slot = ATTACHMENT_SLOT_RAIL
	else
		slot = initial(slot)
	SEND_SIGNAL(src, COMSIG_ATTACHMENT_CHANGE_SLOT, slot)
	to_chat(user, span_notice("You adjust [src] to fit on a gun's [slot]."))

/// Toggle action button: turn the gun's empty-magazine alarm on/off.
/obj/item/attachment/ammo_counter/toggle_attachment(obj/item/gun/gun, mob/user)
	. = ..()
	var/obj/item/gun/ballistic/ballistic_gun = gun
	if(!istype(ballistic_gun))
		return
	if(initial(ballistic_gun.empty_alarm))
		return
	alarm_enabled = !alarm_enabled
	ballistic_gun.empty_alarm = alarm_enabled
	to_chat(user, span_notice("You turn [src]'s alarm [alarm_enabled ? "on" : "off"]."))

#undef ui_ammocounter
