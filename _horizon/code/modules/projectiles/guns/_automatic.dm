/obj/item/gun/ballistic/automatic
	/// Position of the fire selector: 1 = semi, 2 = burst, 3 = full auto.
	var/select = 3
	/// The sound effect for switching your gun back to semi-automatic
	var/fireselector_semi = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	var/fireselector_semi_vary = FALSE
	var/fireselector_semi_volume = 90
	/// The sound effect for switching your gun to burst fire
	var/fireselector_burst = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	var/fireselector_burst_vary = FALSE
	var/fireselector_burst_volume = 90
	/// The sound effect for switching your gun to full auto fire
	var/fireselector_auto = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	var/fireselector_auto_vary = FALSE
	var/fireselector_auto_volume = 90
	/// Burst length while select == 2. Defaults to the gun's initial
	/// burst_size, which also marks the gun as having no separate burst mode.
	var/burst_size_toggled
	/// Fire delay while select == 2. Defaults to the gun's initial fire_delay.
	var/fire_delay_toggled
	/// Burst length while select == 3 (full auto).
	var/burst_size_auto
	/// Fire delay while select == 3 (full auto).
	var/fire_delay_auto

/obj/item/gun/ballistic/automatic/Initialize(mapload)
	. = ..()
	if(isnull(burst_size_toggled))
		burst_size_toggled = initial(burst_size)
	if(isnull(fire_delay_toggled))
		fire_delay_toggled = initial(fire_delay)
	if(isnull(burst_size_auto))
		burst_size_auto = initial(burst_size)
	if(isnull(fire_delay_auto))
		fire_delay_auto = initial(fire_delay)

/// The autofire component only fires while the selector is on full auto.
/obj/item/gun/ballistic/automatic/on_autofire_start(mob/living/shooter)
	if(select != 3)
		return NONE
	return ..()

/obj/item/gun/ballistic/automatic/do_autofire(datum/source, atom/target, mob/living/shooter, allow_akimbo, params)
	SIGNAL_HANDLER
	if(select != 3)
		return NONE
	return ..()

/// Full-auto automatics pass their full-auto fire delay to the component.
/obj/item/gun/ballistic/automatic/initialize_full_auto()
	if(!full_auto)
		return FALSE
	AddComponent(/datum/component/automatic_fire, fire_delay_auto)

/obj/item/gun/ballistic/automatic/burst_select()
	var/mob/living/carbon/human/user = usr
	var/datum/component/automatic_fire/autofire = GetComponent(/datum/component/automatic_fire)

	if(!autofire && burst_size_toggled == initial(burst_size))
		return ..()

	// Cycle the selector: semi -> burst -> auto -> semi.
	switch(select)
		if(1)
			select = (burst_size_toggled != initial(burst_size)) ? 2 : 3
		if(2)
			select = autofire ? 3 : 1
		else
			select = 1

	switch(select)
		if(1) // semi
			burst_size = 1
			fire_delay = initial(fire_delay)
			burst_fire_selection = FALSE
			autofire?.autofire_off()
			to_chat(user, span_notice("I switch [src] to semi-automatic."))
			playsound(user, fireselector_semi, fireselector_semi_volume, fireselector_semi_vary)
		if(2) // burst
			burst_size = burst_size_toggled
			fire_delay = fire_delay_toggled
			burst_fire_selection = TRUE
			if(autofire)
				autofire.autofire_stat = AUTOFIRE_STAT_IDLE
				autofire.autofire_on(user?.client)
			to_chat(user, span_notice("I switch [src] to [burst_size]-round burst."))
			playsound(user, fireselector_burst, fireselector_burst_volume, fireselector_burst_vary)
		if(3) // full auto
			burst_size = burst_size_auto
			fire_delay = initial(fire_delay)
			burst_fire_selection = TRUE
			if(autofire)
				autofire.autofire_stat = AUTOFIRE_STAT_IDLE
				autofire.autofire_on(user?.client)
			to_chat(user, span_notice("I switch [src] to automatic."))
			playsound(user, fireselector_auto, fireselector_auto_volume, fireselector_auto_vary)

	update_appearance()
	update_item_action_buttons()
