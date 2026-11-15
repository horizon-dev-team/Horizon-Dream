/mob/living/Logout()
	update_z(null)
	..()
	set_sight(initial(sight)) // [HORIZON-ADD] NPCs must not keep x-ray, AI uses sight for view()
	if(!key && mind) //key and mind have become separated.
		mind.active = FALSE //This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
	med_hud_set_status()
