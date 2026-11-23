// Muzzle silencer attachment.
//
// It reuses the gun's own suppression: while installed the gun counts as suppressed, so it
// plays its own suppressed_sound at suppressed_volume and skips the muzzle flash, exactly
// as with a suppressor item.
//
// Guns have no suppressor overlay of their own for this, the silencer draws its sprite itself
// ("silencer-attached") at the gun's muzzle point from slot_offsets
// (see _gun_muzzle_offsets.dm). To stop a gun that does have a "_suppressor" state from
// drawing a second silencer, can_unsuppress is switched off while the attachment is fitted:
// the gun only draws that state, and offers the alt-click unscrew, when it is set.

/obj/item/attachment/silencer
	name = "silencer"
	desc = "A threaded silencer, designed to be fitted to the muzzle of a compatible firearm to muffle its report."
	icon = '_horizon/icons/obj/items/guns/attachments.dmi'
	icon_state = "silencer"
	w_class = WEIGHT_CLASS_SMALL
	attachment_component_type = /datum/component/gun_attachment/silencer

/datum/component/gun_attachment/silencer
	slot = ATTACHMENT_SLOT_MUZZLE
	feature_flags = ATTACH_REMOVABLE_HAND
	// The sprite is drawn from its own bottom-left corner, which sits exactly on the muzzle point.
	overlay_shift_x = 0
	overlay_shift_y = 0
	/// Weight added to the gun, so a suppressed pistol stops fitting in pockets, like with a suppressor item.
	var/added_weight = 0
	/// can_unsuppress of the gun before the silencer took it over.
	var/previous_can_unsuppress = FALSE

/// Only guns that take suppressors, and only if they are not suppressed already.
/datum/component/gun_attachment/silencer/get_attach_error(obj/item/gun/gun, mob/user)
	. = ..()
	if(.)
		return
	if(!gun.can_suppress)
		return "[parent] can't be fitted to the muzzle of [gun]!"
	if(gun.suppressed)
		return "[gun] is already suppressed!"

/datum/component/gun_attachment/silencer/on_attached(obj/item/gun/gun, mob/user)
	. = ..()
	var/obj/item/silencer_item = parent
	gun.suppressed = SUPPRESSED_QUIET
	previous_can_unsuppress = gun.can_unsuppress
	gun.can_unsuppress = FALSE
	added_weight = silencer_item.w_class
	gun.update_weight_class(gun.w_class + added_weight)
	if(user)
		playsound(user, 'sound/items/tools/screwdriver.ogg', 75, TRUE)

/datum/component/gun_attachment/silencer/on_detached(obj/item/gun/gun, mob/user)
	. = ..()
	gun.suppressed = SUPPRESSED_NONE
	gun.can_unsuppress = previous_can_unsuppress
	gun.update_weight_class(gun.w_class - added_weight)
	added_weight = 0
	if(user)
		playsound(user, 'sound/items/tools/screwdriver2.ogg', 75, TRUE)
