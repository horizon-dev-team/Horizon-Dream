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
