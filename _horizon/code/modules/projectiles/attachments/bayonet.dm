/// Existing combat knives double as attachments; no replacement knife item is needed.
/datum/component/gun_attachment/bayonet
	slot = ATTACHMENT_SLOT_BAYONET
	feature_flags = ATTACH_REMOVABLE_HAND
	hook_flags = ATTACH_HOOK_PRE_ATTACK_SECONDARY
	valid_parent_types = list(/obj/item/gun)
	excluded_slots = list(ATTACHMENT_SLOT_MUZZLE)
	overlay_shift_x = 0
	overlay_shift_y = 0

/datum/component/gun_attachment/bayonet/get_attach_error(obj/item/gun/gun, mob/user)
	. = ..()
	if(.)
		return .
	if(gun.sawn_off)
		return "[gun] no longer has a bayonet lug!"

/datum/component/gun_attachment/bayonet/get_overlay()
	var/obj/item/gun/gun = mount?.parent
	if(!gun)
		return null
	return mutable_appearance('icons/obj/weapons/guns/bayonets.dmi', gun.bayonet_overlay)

/datum/component/gun_attachment/bayonet/on_pre_attack_secondary(obj/item/gun/gun, atom/target, mob/living/user, list/modifiers)
	if(!user.combat_mode)
		return FALSE
	// Forward to the real knife, keeping its butchering, damage and other components.
	INVOKE_ASYNC(parent, TYPE_PROC_REF(/obj/item, melee_attack_chain), user, target, modifiers - RIGHT_CLICK)
	return TRUE
