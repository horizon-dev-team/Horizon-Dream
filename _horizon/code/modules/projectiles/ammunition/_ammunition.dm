// Horizon overrides for /obj/item/ammo_casing: world-sprite element.
// The -live icon suffix already lives on the upstream casing.

/obj/item/ammo_casing
	carry_weight = 20 GRAMS
	/// World icon for this bullet
	var/world_icon = '_horizon/icons/obj/items/ammo/casings_world.dmi'
	/// World icon state
	var/world_icon_state = "s-casing"

/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	if(world_icon)
		AddElement(/datum/element/world_icon, PROC_REF(update_icon_world))

/obj/item/ammo_casing/update_icon(updates)
	// update_icon_world swaps the inventory icon for the floor sprite.
	icon = initial(icon)
	return ..()

/obj/item/ammo_casing/proc/update_icon_world()
	icon = world_icon
	icon_state = "[world_icon_state][loaded_projectile ? "-live" : ""]"
	return UPDATE_ICON_STATE | UPDATE_OVERLAYS
