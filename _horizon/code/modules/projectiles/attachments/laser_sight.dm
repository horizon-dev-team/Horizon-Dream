/obj/item/attachment/laser_sight
	name = "laser sight"
	desc = "Designed to be rail-mounted on a compatible firearm to provide increased accuracy and decreased spread."
	icon = '_horizon/icons/obj/items/guns/attachments.dmi'
	icon_state = "laserpointer"
	w_class = WEIGHT_CLASS_TINY
	attachment_component_type = /datum/component/gun_attachment/laser_sight

/datum/component/gun_attachment/laser_sight
	slot = ATTACHMENT_SLOT_RAIL
	feature_flags = ATTACH_REMOVABLE_HAND|ATTACH_TOGGLE
	overlay_shift_x = 1
	overlay_shift_y = 4
	stat_modifiers = list("spread" = -3, "spread_unwielded" = -3)

/datum/component/gun_attachment/laser_sight/on_toggled(obj/item/gun/gun, mob/user, silent)
	. = ..()
	if(silent || !user)
		return
	playsound(user, 'sound/items/weapons/gun/general/mag_bullet_insert.ogg', 40, TRUE)
	to_chat(user, span_notice("[parent] [active ? "projects a red dot" : "powers down"]."))
