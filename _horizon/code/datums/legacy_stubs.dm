/datum/pollutant
	var/name = "Unknown Pollutant"
	var/color = "#808080"

/datum/pollutant/incredible_gas
	name = "Incredible Gas"
	color = "#00ff88"

// Turf pollution stub
/turf/proc/pollute_turf(datum/pollutant/pollutant, amount = 1)
	return

/obj/item/ammo_casing/batteries
	name = "battery casing"
	desc = "A standardized energy cell casing."
	icon_state = "s-casing"
	caliber = CALIBER_BATTERY
	projectile_type = /obj/projectile/energy
