/obj/item/attachment/silencer
	name = "silencer"
	desc = "A threaded silencer, designed to be fitted to the muzzle of a compatible firearm to muffle its report."
	icon = '_horizon/icons/obj/items/guns/attachments.dmi'
	icon_state = "silencer"
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT)
	attachment_component_type = /datum/component/gun_attachment/silencer

/datum/component/gun_attachment/silencer
	slot = ATTACHMENT_SLOT_MUZZLE
	feature_flags = ATTACH_REMOVABLE_HAND
	overlay_shift_x = 0
	overlay_shift_y = 0
	/// Before values ​​before installing a silencer.
	var/previous_can_unsuppress = FALSE
	var/previous_can_muzzle_flash = TRUE

/datum/component/gun_attachment/silencer/get_attach_error(obj/item/gun/gun, mob/user)
	. = ..()
	if(.)
		return
	if(!gun.can_suppress)
		return "[parent] can't be fitted to the muzzle of [gun]!"
	if(gun.suppressed)
		return "[gun] is already suppressed!"
	if(gun.sawn_off)
		return "[gun] no longer has a threaded muzzle!"

/datum/component/gun_attachment/silencer/on_attached(obj/item/gun/gun, mob/user)
	. = ..()
	gun.suppressed = SUPPRESSED_QUIET
	previous_can_unsuppress = gun.can_unsuppress
	gun.can_unsuppress = FALSE
	previous_can_muzzle_flash = gun.can_muzzle_flash
	gun.can_muzzle_flash = FALSE
	gun.muzzle_flash_off()
	if(user)
		playsound(user, 'sound/items/tools/screwdriver.ogg', 75, TRUE)

/datum/component/gun_attachment/silencer/on_detached(obj/item/gun/gun, mob/user)
	. = ..()
	gun.suppressed = SUPPRESSED_NONE
	gun.can_unsuppress = previous_can_unsuppress
	gun.can_muzzle_flash = previous_can_muzzle_flash
	if(user)
		playsound(user, 'sound/items/tools/screwdriver2.ogg', 75, TRUE)

/obj/item/attachment/silencer/integrated
	name = "integrated silencer"
	desc = "A silencer machined into the barrel shroud of a firearm, fitted to that weapon alone."
	attachment_component_type = /datum/component/gun_attachment/silencer/integrated

/datum/component/gun_attachment/silencer/integrated
	feature_flags = ATTACH_NO_SPRITE
