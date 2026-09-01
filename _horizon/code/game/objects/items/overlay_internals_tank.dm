/obj/item/tank/internals
	//0 = empty, 1 = critical warning, 2 = warning, 3 = nominal
	var/alert_level = 3

/obj/item/tank/internals/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/tank/internals/process(seconds_per_tick)
	. = ..()
	pressure_alerts()

/obj/item/tank/internals/update_overlays()
	. = ..()
	if(istype(src, /obj/item/tank/internals/plasma))
		return
	var/status_overlay_icon_state = "status_empty"
	var/pressure = air_contents.return_pressure()
	switch(pressure)
		if((5 * ONE_ATMOSPHERE) to INFINITY)
			status_overlay_icon_state = "status_nominal"
		if((2 * ONE_ATMOSPHERE) to (5 * ONE_ATMOSPHERE))
			status_overlay_icon_state = "status_warning"
		if((0.75 * ONE_ATMOSPHERE) to (2 * ONE_ATMOSPHERE))
			status_overlay_icon_state = "status_alert"
		if((0.2 * ONE_ATMOSPHERE) to (0.75 * ONE_ATMOSPHERE))
			status_overlay_icon_state = "status_critical"
		else
			status_overlay_icon_state = "status_empty"

	var/mutable_appearance/status_overlay = mutable_appearance('_horizon/icons/obj/tank.dmi', status_overlay_icon_state)
	var/matrix/overlay_matrix = new
	switch(type)
		if(/obj/item/tank/internals/emergency_oxygen)
			overlay_matrix.Translate(-2, -3)
		if(/obj/item/tank/internals/emergency_oxygen/engi/clown)
			overlay_matrix.Translate(-2, -3)
		if(/obj/item/tank/internals/emergency_oxygen/engi)
			overlay_matrix.Translate(-1, -2)
		if(/obj/item/tank/internals/emergency_oxygen/double)
			overlay_matrix.Translate(1, 1)
	status_overlay.transform = overlay_matrix
	overlays += status_overlay

// adjusts sprites and issues text alerts depending on tank pressure
/obj/item/tank/internals/proc/pressure_alerts()
	if(istype(src, /obj/item/tank/internals/plasma))
		return

	// Checks the pressure of the tank while it's in use and sends an alert out when the pressure reaches a specific range.
	var/pressure = air_contents.return_pressure()
	switch(pressure)
		if((5 * ONE_ATMOSPHERE) to INFINITY)
			if(alert_level != 3)
				alert_level = 3
		if((2 * ONE_ATMOSPHERE) to (5 * ONE_ATMOSPHERE))
			if(alert_level != 2)
				alert_level = 2
		if((0.75 * ONE_ATMOSPHERE) to (2 * ONE_ATMOSPHERE))
			if(alert_level != 1)
				alert_level = 1
				playsound(src, 'sound/machines/beep/twobeep_high.ogg', 30, FALSE)
				say("Tank pressure low - Estimated time until depletion: [src.volume * 2.5] minutes.")
		if((0.2 * ONE_ATMOSPHERE) to (0.75 * ONE_ATMOSPHERE))
			if(alert_level != 0)
				alert_level = 0
				playsound(src, 'sound/machines/beep/twobeep_high.ogg', 30, FALSE)
				playsound(src, 'sound/machines/beep/beep.ogg', 30, FALSE)
				say("Tank is nearly empty! Replacement recommended!")

	update_appearance(UPDATE_OVERLAYS)
