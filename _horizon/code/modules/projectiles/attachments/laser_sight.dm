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
