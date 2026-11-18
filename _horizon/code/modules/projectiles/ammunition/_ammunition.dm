/obj/item/ammo_casing
	carry_weight = 20 GRAMS
	/// World icon for this bullet
	var/world_icon = '_horizon/icons/obj/items/ammo/casings_world.dmi'
	/// World icon state
	var/world_icon_state = "s-casing"
	/// The funny sound we make when we bounce on floors
	var/bounce_sound = list('_horizon/sound/bullet/casing_bounce1.wav', '_horizon/sound/bullet/casing_bounce2.wav', '_horizon/sound/bullet/casing_bounce3.wav')
	/// The volume of the bouncing
	var/bounce_volume = 40
	/// Should bouncing vary
	var/bounce_vary = FALSE

/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	if(world_icon)
		AddElement(/datum/element/world_icon, PROC_REF(update_icon_world))

/obj/item/ammo_casing/update_icon(updates)
	icon = initial(icon)
	return ..()

/obj/item/ammo_casing/update_icon_state()
	. = ..()
	var/casing_base = base_icon_state || initial(icon_state)
	icon_state = "[casing_base][loaded_projectile ? "-live" : null]"

/obj/item/ammo_casing/proc/update_icon_world()
	icon = world_icon
	icon_state = "[world_icon_state][loaded_projectile ? "-live" : ""]"
	return UPDATE_ICON_STATE | UPDATE_OVERLAYS
