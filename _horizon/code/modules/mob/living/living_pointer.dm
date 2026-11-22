// Gun crosshair mouse pointer (GunRework): shown while the active hand
// holds a gun with mouse_pointer_icon and its safety is OFF.
// Chains to /mob/proc/update_mouse_pointer via ..(); the gun check only
// runs when neither a vehicle pointer nor a mouse_override_icon took
// priority (same precedence as the old full copy of the /mob proc).
/mob/living/update_mouse_pointer()
	. = ..()
	if(!client || client.mouse_override_icon || istype(loc, /obj/vehicle/sealed))
		return
	var/obj/item/gun/held_gun = get_active_held_item()
	if(istype(held_gun) && held_gun.mouse_pointer_icon && !(held_gun.safety_flags & GUN_SAFETY_ENABLED))
		client.mouse_pointer_icon = held_gun.mouse_pointer_icon
