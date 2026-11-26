/mob/living/Logout()
	update_z(null)
	..()
	set_sight(initial(sight)) // [HORIZON-ADD] Shadow-Render - NPCs must not keep x-ray
	if(!key && mind) //key and mind have become separated.
		mind.active = FALSE //This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
	med_hud_set_status()
