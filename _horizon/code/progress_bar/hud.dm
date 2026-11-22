/datum/hud/human/initialize_screen_objects()
	. = ..()
	ammo_counter = add_screen_object(/atom/movable/screen/ammo_counter, HUD_MOB_AMMO_COUNTER, HUD_GROUP_INFO)
