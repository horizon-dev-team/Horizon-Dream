// Gun mounted lights: a seclite and a rail light.
//
// The light belongs to the attachment item itself. LIGHT_ATTACHED makes it shine from
// the gun it sits in, the same way a seclite fitted with /datum/component/seclite_attachable
// does, so the gun's own light and stats are never touched. The toggle button, the
// ctrl-shift-click radial and switching off on removal all come from ATTACH_TOGGLE.

/// Shared base of the gun mounted lights. Subtypes set the light stats and the sprites.
/obj/item/attachment/gun_light
	name = "broken gun light"
	desc = "alert coders"
	icon = '_horizon/icons/obj/items/guns/attachments.dmi'
	w_class = WEIGHT_CLASS_SMALL
	attachment_component_type = /datum/component/gun_attachment/gun_light
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_flags = LIGHT_ATTACHED
	light_on = FALSE

/datum/component/gun_attachment/gun_light
	slot = ATTACHMENT_SLOT_RAIL
	feature_flags = ATTACH_REMOVABLE_HAND|ATTACH_TOGGLE

/// Switching the attachment on or off switches its light.
/datum/component/gun_attachment/gun_light/on_toggled(obj/item/gun/gun, mob/user, silent)
	. = ..()
	var/obj/item/light_item = parent
	// Always applied, also when the attachment is switched off silently because it is being removed.
	light_item.set_light_on(active)
	if(silent || !user)
		return
	playsound(user, active ? 'sound/items/weapons/magin.ogg' : 'sound/items/weapons/magout.ogg', 40, TRUE)

// MARK: Seclite

/// The ordinary seclite doubles as a rail attachment, just like a combat knife.
/obj/item/flashlight/seclite/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gun_attachment/gun_light/seclite)

/datum/component/gun_attachment/gun_light/seclite
	// Anchor of the "flight" overlay: x 1 and the sprite height, the same rule the laser sight uses.
	overlay_shift_x = 1
	overlay_shift_y = 5

/// The seclite has no "-attached" sprite of its own, it uses the standard gun light overlay.
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

/// Use the flashlight's disruption checks rather than bypassing them with set_light_on().
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

// MARK: Rail light

/// A compact tactical light built for the rail.
/obj/item/attachment/gun_light/raillight
	name = "rail light"
	desc = "A compact tactical light, designed to be rail-mounted on a compatible firearm."
	icon_state = "raillight"
	w_class = WEIGHT_CLASS_TINY
	attachment_component_type = /datum/component/gun_attachment/gun_light/raillight
	light_range = 4
	light_power = 1
	light_color = "#ffecd0"

/datum/component/gun_attachment/gun_light/raillight
	overlay_shift_x = 1
	overlay_shift_y = 5
