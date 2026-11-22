// [HORIZON-ADD] GunRework
// Gun attachment items (Shiptest-style attachment system).
// Components: code/datums/components/attachment.dm and attachment_holder.dm.
// Defines and slot helpers: code/__DEFINES/attachments.dm.

/// Base attachment item. Most logic is in the component.
/obj/item/attachment
	name = "broken attachment"
	desc = "alert coders"
	icon = '_horizon/icons/obj/guns/attachments.dmi'
	w_class = WEIGHT_CLASS_SMALL

	///Slot the attachment goes on, also used in descriptions
	var/slot = ATTACHMENT_SLOT_RAIL
	///various yes no flags associated with attachments
	var/attach_features_flags = ATTACH_REMOVABLE_HAND
	///Component that handles most of the logic of attachments
	var/datum/component/attachment/attachment_comp

	///If the attachment is on or off
	var/toggled = FALSE

	///Determines the amount of pixels to move the icon state for the overlay
	var/pixel_shift_x = 16
	var/pixel_shift_y = 16
	/// Determines what layer the icon state for the overlay renders on
	var/render_layer = FLOAT_LAYER
	var/render_plane = FLOAT_PLANE

/obj/item/attachment/Initialize()
	. = ..()
	attachment_comp = AddComponent( \
		/datum/component/attachment, \
		slot, \
		attach_features_flags, \
		CALLBACK(src, PROC_REF(apply_attachment)), \
		CALLBACK(src, PROC_REF(remove_attachment)), \
		CALLBACK(src, PROC_REF(toggle_attachment)), \
		CALLBACK(src, PROC_REF(toggle_ammo)), \
		CALLBACK(src, PROC_REF(on_fire_gun)), \
		CALLBACK(src, PROC_REF(on_preattack)), \
		CALLBACK(src, PROC_REF(on_attacked)), \
		CALLBACK(src, PROC_REF(on_ctrl_click)), \
		CALLBACK(src, PROC_REF(on_wield)), \
		CALLBACK(src, PROC_REF(on_unwield)), \
		CALLBACK(src, PROC_REF(on_examine)), \
		CALLBACK(src, PROC_REF(on_alt_click)), \
		CALLBACK(src, PROC_REF(on_attack_hand)), \
		list())

/obj/item/attachment/Destroy()
	qdel(attachment_comp)
	attachment_comp = null
	. = ..()

/obj/item/attachment/proc/toggle_attachment(obj/item/gun/gun, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	toggled = !toggled
	icon_state = "[initial(icon_state)][toggled ? "-on" : ""]"

/obj/item/attachment/proc/toggle_ammo(obj/item/gun/gun, mob/user)
	return FALSE

/// Checks if a user should be allowed to attach this attachment to the given parent
/obj/item/attachment/proc/apply_attachment(obj/item/gun/gun, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(toggled)
		to_chat(user, span_warning("You cannot attach [src] while it is active!"))
		return FALSE
	return TRUE

/obj/item/attachment/proc/remove_attachment(obj/item/gun/gun, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(toggled)
		toggle_attachment(gun, user)
	return TRUE

/obj/item/attachment/proc/on_fire_gun(obj/item/gun/gun, mob/user, atom/target, flag, params)
	return NONE

/obj/item/attachment/proc/on_preattack(obj/item/gun/gun, atom/target, mob/user, list/params)
	return FALSE

/obj/item/attachment/proc/on_wield(obj/item/gun/gun, mob/user, list/params)
	return FALSE

/obj/item/attachment/proc/on_unwield(obj/item/gun/gun, mob/user, list/params)
	return FALSE

/obj/item/attachment/proc/on_attacked(obj/item/gun/gun, mob/user, obj/item)
	return FALSE

/obj/item/attachment/proc/on_ctrl_click(obj/item/gun/gun, mob/user, params)
	return FALSE

/obj/item/attachment/proc/on_examine(obj/item/attachment/attach, mob/user, list/examine_list)
	return

/obj/item/attachment/proc/on_attack_hand(obj/item/gun/gun, mob/user, list/params)
	return FALSE

/obj/item/attachment/proc/on_alt_click(obj/item/gun/gun, mob/user, list/params)
	return FALSE

/obj/item/attachment/laser_sight
	name = "laser sight"
	desc = "Designed to be rail-mounted on a compatible firearm to provide increased accuracy and decreased spread."
	icon = '_horizon/icons/obj/items/guns/attachments.dmi'
	icon_state = "laserpointer"
	w_class = WEIGHT_CLASS_TINY
	attach_features_flags = ATTACH_REMOVABLE_HAND|ATTACH_TOGGLE
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 1
	pixel_shift_y = 4

/obj/item/attachment/laser_sight/toggle_attachment(obj/item/gun/gun, mob/user)
	. = ..()
	if(toggled)
		gun.spread -= 3
		gun.spread_unwielded -= 3
	else
		gun.spread += 3
		gun.spread_unwielded += 3
	playsound(user, 'sound/items/weapons/gun/general/mag_bullet_insert.ogg', 40, TRUE)
	to_chat(user, span_notice("[src] [toggled ? "projects a red dot" : "powers down"]."))

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
