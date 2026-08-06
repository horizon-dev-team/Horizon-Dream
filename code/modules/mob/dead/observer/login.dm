/mob/dead/observer/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	ghost_orbit = client.prefs.read_preference(/datum/preference/choiced/ghost_orbit)
	client.set_right_click_menu_mode(FALSE)
	lighting_cutoff = default_lighting_cutoff()
	update_sight()


