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

/// A security flashlight on a rail clamp. Same light as the standard seclite.
/obj/item/attachment/gun_light/seclite
	name = "gun seclite"
	desc = "A seclite fitted with a rail clamp, designed to be mounted on a compatible firearm."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "seclite"
	attachment_component_type = /datum/component/gun_attachment/gun_light/seclite
	light_range = 5
	light_power = 0.8
	light_color = "#99ccff"

/datum/component/gun_attachment/gun_light/seclite
	// Anchor of the "flight" overlay: x 1 and the sprite height, the same rule the laser sight uses.
	overlay_shift_x = 1
	overlay_shift_y = 5

/// The seclite has no "-attached" sprite of its own, it uses the standard gun light overlay.
/datum/component/gun_attachment/gun_light/seclite/get_overlay()
	return mutable_appearance('_horizon/icons/obj/items/guns/attachments.dmi', active ? "flight_on" : "flight", overlay_layer)

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
