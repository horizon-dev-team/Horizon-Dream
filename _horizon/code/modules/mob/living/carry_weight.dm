// Horizon weight / encumbrance system.
//
// Reconciliation of the EscapeFromNevado (modular_septic) original with this TG build.
// The original ties carry capacity to an RPG attribute system (STAT_STRENGTH -> get_basic_lift)
// and encumbrance to a fatigue system; neither is ported here, so we keep the original's balance
// curve, proc layout and feedback, but drive it with stable TG-native hooks: a variable movespeed
// modifier + equip/unequip signals + a periodic refresh for silent content drift (players only).
// The component is attached from the core /mob/living/carbon/Initialize ([HORIZON-ADD] in carbon.dm),
// not from a duplicate Initialize override here, which would replace the core proc body.

/datum/movespeed_modifier/carry_weight
	variable = TRUE

/// Default item mass (kg) from bulk class. Original formula: w_class^2 / 4.
/// Default item mass (kg) from bulk class. Only used when an item has no explicit carry_weight.
/// The old w_class^2/4 curve made a normal item, a pistol and a vest the same couple of kilos.
/proc/weight_class_to_kg(weight_class)
	switch(weight_class)
		if(WEIGHT_CLASS_TINY)
			return 0.04
		if(WEIGHT_CLASS_SMALL)
			return 0.3
		if(WEIGHT_CLASS_NORMAL)
			return 1
		if(WEIGHT_CLASS_BULKY)
			return 3.2
		if(WEIGHT_CLASS_HUGE)
			return 8
		if(WEIGHT_CLASS_GIGANTIC)
			return 15
	return max(0.04, weight_class * 0.5)


/// Basic lift in kg. Original: STR^2/10 via attributes; stable fallback here,
/// reduced while the carbon is hungry or thirsty.
/mob/living/carbon/proc/get_basic_lift()
	return ENCUMBRANCE_DEFAULT_BASIC_LIFT * get_needs_lift_multiplier()

/// Share of the basic lift we keep given hunger and thirst. The worse of the two applies,
/// they do not stack. Carbons that cannot get hungry or thirsty are not affected by that need.
/mob/living/carbon/proc/get_needs_lift_multiplier()
	. = 1
	if(can_get_thirsty())
		switch(hydration)
			if(-INFINITY to HYDRATION_LEVEL_DEHYDRATED)
				. = min(., LIFT_MULT_DEHYDRATED)
			if(HYDRATION_LEVEL_DEHYDRATED to HYDRATION_LEVEL_THIRSTY)
				. = min(., LIFT_MULT_THIRSTY)
	if(!HAS_TRAIT(src, TRAIT_NOHUNGER))
		switch(nutrition)
			if(-INFINITY to NUTRITION_LEVEL_STARVING)
				. = min(., LIFT_MULT_STARVING)
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_VERY_HUNGRY)
				. = min(., LIFT_MULT_VERY_HUNGRY)
			if(NUTRITION_LEVEL_VERY_HUNGRY to NUTRITION_LEVEL_HUNGRY)
				. = min(., LIFT_MULT_HUNGRY)

/// How much faster hunger and thirst drain per step at the current encumbrance level.
/mob/living/carbon/proc/get_encumbrance_drain_multiplier()
	switch(encumbrance)
		if(ENCUMBRANCE_EXTREME)
			return NEEDS_DRAIN_MULT_EXTREME
		if(ENCUMBRANCE_HEAVY)
			return NEEDS_DRAIN_MULT_HEAVY
		if(ENCUMBRANCE_MEDIUM)
			return NEEDS_DRAIN_MULT_MEDIUM
		if(ENCUMBRANCE_LIGHT)
			return NEEDS_DRAIN_MULT_LIGHT
	return NEEDS_DRAIN_MULT_NONE

/// Recalculates maximum_carry_weight. Returns TRUE if it changed.
/mob/living/carbon/proc/update_maximum_carry_weight()
	var/new_maximum = get_basic_lift() * ENCUMBRANCE_MAXIMUM_PER_LIFT
	if(new_maximum == maximum_carry_weight)
		return FALSE
	maximum_carry_weight = new_maximum
	return TRUE

/// Base move-delay for scaling encumbrance slowdown (original: attribute/combat based).
/mob/living/carbon/proc/get_basic_slowdown()
	return ENCUMBRANCE_BASIC_SLOWDOWN

/// Aggregate carried weight and refresh encumbrance. Base carbon version covers
/// non-human carbons (monkeys, aliens): hands + carried contents, biology excluded.
/// Typed for-loops skip null entries (empty hands / slots) automatically.
/mob/living/carbon/proc/update_carry_weight()
	. = 0
	for(var/obj/item/thing in held_items)
		. += thing.get_carry_weight()
	for(var/obj/item/carried in contents)
		if(carried in held_items)
			continue
		if(istype(carried, /obj/item/organ) || istype(carried, /obj/item/bodypart) || istype(carried, /obj/item/implant) || istype(carried, /obj/item/offhand) || istype(carried, /obj/item/skillchip))
			continue
		. += carried.get_carry_weight()
	carry_weight = .
	update_encumbrance()

/// Human version: explicit equipment slots + hands + piggybacked riders.
/mob/living/carbon/human/update_carry_weight()
	. = 0
	var/list/inventory_items = list(back, wear_mask, wear_neck, head, gloves, shoes, glasses, ears, wear_suit, w_uniform, belt, wear_id, r_store, l_store, s_store, handcuffed, legcuffed)
	for(var/obj/item/thing in inventory_items)
		. += thing.get_carry_weight()
	for(var/obj/item/thing in held_items)
		. += thing.get_carry_weight()
	// Carrying another human on your back adds their body weight.
	for(var/mob/living/carbon/human/rider in buckled_mobs)
		. += HUMAN_WEIGHT
	carry_weight = .
	update_encumbrance()
	// Propagate to whoever we're buckled to (piggyback chain).
	if(buckled && ishuman(buckled))
		var/mob/living/carbon/human/carrier = buckled
		carrier.update_carry_weight()

/// Set the encumbrance level from the original thresholds (multiples of basic_lift
/// = maximum_carry_weight/10): LIGHT >=2, MEDIUM >=3, HEAVY >=6, EXTREME >=10.
/mob/living/carbon/proc/update_encumbrance()
	var/basic_lift = maximum_carry_weight / ENCUMBRANCE_MAXIMUM_PER_LIFT
	var/old_level = encumbrance
	if(carry_weight >= (basic_lift * 10))
		encumbrance = ENCUMBRANCE_EXTREME
	else if(carry_weight >= (basic_lift * 6))
		encumbrance = ENCUMBRANCE_HEAVY
	else if(carry_weight >= (basic_lift * 3))
		encumbrance = ENCUMBRANCE_MEDIUM
	else if(carry_weight >= (basic_lift * 2))
		encumbrance = ENCUMBRANCE_LIGHT
	else
		encumbrance = ENCUMBRANCE_NONE
	// NOTE: the original also fed /datum/fatigue_modifier/weight here (-50/-25/0/0).
	// The fatigue system is not ported; hook it here once it lands.
	if(encumbrance == old_level)
		return
	update_encumbrance_movespeed_modifier()
	notify_encumbrance_change(old_level)

/// Original slowdown curve: get_basic_slowdown() * 0.2/0.4/0.6/0.8 per level.
/// Only called when the level actually changes, and the modifier is dropped entirely at NONE.
/mob/living/carbon/proc/update_encumbrance_movespeed_modifier()
	var/factor = 0
	switch(encumbrance)
		if(ENCUMBRANCE_EXTREME)
			factor = 0.8
		if(ENCUMBRANCE_HEAVY)
			factor = 0.6
		if(ENCUMBRANCE_MEDIUM)
			factor = 0.4
		if(ENCUMBRANCE_LIGHT)
			factor = 0.2
	if(!factor)
		remove_movespeed_modifier(/datum/movespeed_modifier/carry_weight)
		return
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/carry_weight, TRUE, get_basic_slowdown() * factor)

/// Player-facing encumbrance readout (original wording). For examine / a future HUD.
/mob/living/carbon/proc/encumbrance_text()
	switch(encumbrance)
		if(ENCUMBRANCE_EXTREME)
			return span_userdanger(span_big("ТЯЖЕЛО!!!"))
		if(ENCUMBRANCE_HEAVY)
			return span_userdanger("Тяжело.")
		if(ENCUMBRANCE_MEDIUM)
			return span_boldnotice("Приемлемо.")
		if(ENCUMBRANCE_LIGHT)
			return span_notice("Налегке.")
		if(ENCUMBRANCE_NONE)
			return span_tinynotice("Почти не чувствую.")

/mob/living/carbon/proc/notify_encumbrance_change(old_level)
	if(encumbrance > old_level)
		switch(encumbrance)
			if(ENCUMBRANCE_MEDIUM)
				src.balloon_alert(src, "тяжело нести")
			if(ENCUMBRANCE_HEAVY)
				src.balloon_alert(src, "очень тяжело")
			if(ENCUMBRANCE_EXTREME)
				src.balloon_alert(src, "еле двигаешься")
	else if(encumbrance == ENCUMBRANCE_NONE)
		src.balloon_alert(src, "полегчало")

/// Drives the system: immediate recalc on equip/unequip, periodic catch-all for
/// silent content changes. Calculation itself lives on the carbon (see above).
/datum/component/carry_weight
	var/refresh_timer

/datum/component/carry_weight/Initialize()
	if(!istype(parent, /mob/living/carbon))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_gear_change))
	RegisterSignal(parent, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_gear_change))
	// Hunger and thirst change how much we can lift.
	RegisterSignals(parent, list(COMSIG_LIVING_UPDATE_NUTRITION, COMSIG_LIVING_UPDATE_HYDRATION), PROC_REF(on_needs_change))
	var/mob/living/carbon/owner = parent
	owner.update_maximum_carry_weight()
	refresh_timer = addtimer(CALLBACK(src, PROC_REF(on_timer)), ENCUMBRANCE_REFRESH_INTERVAL, TIMER_LOOP | TIMER_STOPPABLE)
	refresh()

/datum/component/carry_weight/Destroy()
	if(refresh_timer)
		deltimer(refresh_timer)
		refresh_timer = null
	var/mob/living/carbon/owner = parent
	if(owner)
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/carry_weight)
	return ..()

/datum/component/carry_weight/proc/on_gear_change()
	SIGNAL_HANDLER
	refresh()

/// Hunger or thirst changed. The lift multiplier is stepwise, so the full recalc only runs when it moved a step.
/datum/component/carry_weight/proc/on_needs_change()
	SIGNAL_HANDLER
	var/mob/living/carbon/owner = parent
	if(QDELETED(owner))
		return
	if(owner.update_maximum_carry_weight())
		refresh()

/// Periodic catch-all for silent content drift. Only players are polled, NPCs update on gear signals.
/datum/component/carry_weight/proc/on_timer()
	var/mob/living/carbon/owner = parent
	if(QDELETED(owner) || !owner.client)
		return
	refresh()

/datum/component/carry_weight/proc/refresh()
	var/mob/living/carbon/owner = parent
	if(QDELETED(owner))
		return
	owner.update_carry_weight()
