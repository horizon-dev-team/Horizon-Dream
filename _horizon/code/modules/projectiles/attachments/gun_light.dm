/obj/item/flashlight/seclite/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gun_attachment/gun_light/seclite)

/datum/component/gun_attachment/gun_light
	slot = ATTACHMENT_SLOT_RAIL
	feature_flags = ATTACH_REMOVABLE_HAND|ATTACH_TOGGLE

/datum/component/gun_attachment/gun_light/on_toggled(obj/item/gun/gun, mob/user, silent)
	. = ..()
	var/obj/item/light_item = parent
	// Always applied, also when the attachment is switched off silently because it is being removed.
	light_item.set_light_on(active)
	if(silent || !user)
		return
	playsound(user, active ? 'sound/items/weapons/magin.ogg' : 'sound/items/weapons/magout.ogg', 40, TRUE)


/datum/component/gun_attachment/gun_light/seclite
	overlay_shift_x = 1
	overlay_shift_y = 5

/datum/component/gun_attachment/gun_light/seclite/get_overlay()
	return mutable_appearance('_horizon/icons/obj/items/guns/attachments.dmi', active ? "flight_on" : "flight", overlay_layer)

/datum/component/gun_attachment/gun_light/seclite/on_attached(obj/item/gun/gun, mob/user)
	var/obj/item/flashlight/seclite/light = parent
	active = light.light_on
	light.set_light_flags(light.light_flags | LIGHT_ATTACHED)
	RegisterSignal(light, COMSIG_ATOM_UPDATE_LIGHT_ON, PROC_REF(on_light_changed))
	return ..()

/datum/component/gun_attachment/gun_light/seclite/on_detached(obj/item/gun/gun, mob/user)
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_LIGHT_ON)
	var/obj/item/flashlight/seclite/light = parent
	light.set_light_flags(light.light_flags & ~LIGHT_ATTACHED)
	light.update_brightness()

/datum/component/gun_attachment/gun_light/seclite/set_active(new_state, mob/user, silent = FALSE)
	var/obj/item/flashlight/seclite/light = parent
	if(new_state && !COOLDOWN_FINISHED(light, disabled_time))
		return FALSE
	return ..()

/datum/component/gun_attachment/gun_light/seclite/on_toggled(obj/item/gun/gun, mob/user, silent)
	. = ..()
	var/obj/item/flashlight/seclite/light = parent
	light.update_brightness()
	light.update_item_action_buttons()

/// EMPs, saboteurs and the flashlight's own toggle must update the gun's overlay too.
/datum/component/gun_attachment/gun_light/seclite/proc/on_light_changed(obj/item/flashlight/seclite/source, old_value)
	SIGNAL_HANDLER
	if(!mount)
		return
	if(active != source.light_on)
		set_active(source.light_on, silent = TRUE)
	else
		var/obj/item/gun/gun = mount.parent
		gun.update_appearance()
