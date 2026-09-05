/obj/item/tank/internals
	//0 = empty, 1 = critical warning, 2 = alert, 3 = warning, 4 = nominal
	var/alert_level = 4

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
	var/status_overlay_icon_state
	switch(alert_level)
		if(4)
			status_overlay_icon_state = "status_nominal"
		if(3)
			status_overlay_icon_state = "status_warning"
		if(2)
			status_overlay_icon_state = "status_alert"
		if(1)
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
	. += status_overlay

// adjusts sprites and issues text alerts depending on tank pressure
/obj/item/tank/internals/proc/pressure_alerts()
	if(istype(src, /obj/item/tank/internals/plasma))
		return

	// Checks the pressure of the tank while it's in use and sends an alert out when the pressure reaches a specific range.
	var/pressure = air_contents.return_pressure()
	var/old_alert = alert_level
	switch(pressure)
		if((5 * ONE_ATMOSPHERE) to INFINITY)
			if(alert_level != 4)
				alert_level = 4
		if((2 * ONE_ATMOSPHERE) to (5 * ONE_ATMOSPHERE))
			if(alert_level != 3)
				alert_level = 3
		if((0.75 * ONE_ATMOSPHERE) to (2 * ONE_ATMOSPHERE))
			if(alert_level != 2)
				alert_level = 2
				playsound(src, 'sound/machines/beep/twobeep_high.ogg', 30, FALSE)
				say("Tank pressure low - Estimated time until depletion: [src.volume * 2.5] minutes.")
		if((0.2 * ONE_ATMOSPHERE) to (0.75 * ONE_ATMOSPHERE))
			if(alert_level != 1)
				alert_level = 1
				playsound(src, 'sound/machines/beep/twobeep_high.ogg', 30, FALSE)
				playsound(src, 'sound/machines/beep/beep.ogg', 30, FALSE)
				say("Tank is nearly empty! Replacement recommended!")
		else
			alert_level = 0

	if(alert_level != old_alert)
		update_appearance(UPDATE_OVERLAYS)
