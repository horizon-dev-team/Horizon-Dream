/datum/movespeed_modifier/carry_weight
	variable = TRUE

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

/// Basic lift in kg. Original: STR^2/10 via attributes - Maybe it's worth adding attributes in the future;
/// Reduced while the carbon is hungry or thirsty.
/mob/living/carbon/proc/get_basic_lift()
	return ENCUMBRANCE_DEFAULT_BASIC_LIFT * get_needs_lift_multiplier()

/// Share of the basic lift we keep given hunger and thirst. The worse of the two applies, they do not stack.
/// Carbons that cannot get hungry or thirsty are not affected by that need.
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
		if(ENCUMBRANCE_IMPOSSIBLE)
			return NEEDS_DRAIN_MULT_IMPOSSIBLE
		if(ENCUMBRANCE_EXTREME)
			return NEEDS_DRAIN_MULT_EXTREME
		if(ENCUMBRANCE_STRENUOUS)
			return NEEDS_DRAIN_MULT_STRENUOUS
		if(ENCUMBRANCE_HEAVY)
			return NEEDS_DRAIN_MULT_HEAVY
		if(ENCUMBRANCE_MEDIUM)
			return NEEDS_DRAIN_MULT_MEDIUM
		if(ENCUMBRANCE_LIGHT)
			return NEEDS_DRAIN_MULT_LIGHT
	return NEEDS_DRAIN_MULT_NONE

/mob/living/carbon/proc/update_maximum_carry_weight()
	var/new_maximum = get_basic_lift() * ENCUMBRANCE_MAXIMUM_PER_LIFT
	if(new_maximum == maximum_carry_weight)
		return FALSE
	maximum_carry_weight = new_maximum
	return TRUE

/mob/living/carbon/proc/get_basic_slowdown()
	return ENCUMBRANCE_BASIC_SLOWDOWN

/// Aggregate carried weight and refresh encumbrance.
/// Base carbon version covers non-human carbons (monkeys, aliens): hands + carried contents, biology excluded.
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

/mob/living/carbon/human/update_carry_weight()
	. = 0
	var/list/inventory_items = list(back, wear_mask, wear_neck, head, gloves, shoes, glasses, ears, wear_suit, w_uniform, belt, wear_id, r_store, l_store, s_store, handcuffed, legcuffed)
	for(var/obj/item/thing in inventory_items)
		. += thing.get_carry_weight()
	for(var/obj/item/thing in held_items)
		. += thing.get_carry_weight()
	// Deployed MODsuit parts sit in our own slots, not in the control unit, so the servo relief is applied here.
	var/obj/item/mod/control/modsuit = back
	if(istype(modsuit))
		. -= modsuit.get_deployed_weight_relief()
	// Carrying another human on your back adds their body weight.
	for(var/mob/living/carbon/human/rider in buckled_mobs)
		. += HUMAN_WEIGHT * RIDER_WEIGHT_MULT
	carry_weight = .
	update_encumbrance()
	// Propagate to whoever we're buckled to (piggyback chain).
	if(buckled && ishuman(buckled))
		var/mob/living/carbon/human/carrier = buckled
		carrier.update_carry_weight()

/// Sets the encumbrance level from the load's share of the basic lift (= maximum_carry_weight / 10):
/// LIGHT >=20%, MEDIUM >=40%, STRENUOUS >=60%, HEAVY >=80%, EXTREME >=100%, IMPOSSIBLE >=120% of the maximum.
/// At IMPOSSIBLE the carbon is floored until it sheds weight (see /turf/handle_fall for why it keeps its items).
/mob/living/carbon/proc/update_encumbrance()
	var/basic_lift = maximum_carry_weight / ENCUMBRANCE_MAXIMUM_PER_LIFT
	var/old_level = encumbrance
	if(carry_weight >= (basic_lift * ENCUMBRANCE_COLLAPSE_PER_LIFT))
		encumbrance = ENCUMBRANCE_IMPOSSIBLE
	else if(carry_weight >= (basic_lift * 10))
		encumbrance = ENCUMBRANCE_EXTREME
	else if(carry_weight >= (basic_lift * 8))
		encumbrance = ENCUMBRANCE_HEAVY
	else if(carry_weight >= (basic_lift * 6))
		encumbrance = ENCUMBRANCE_STRENUOUS
	else if(carry_weight >= (basic_lift * 4))
		encumbrance = ENCUMBRANCE_MEDIUM
	else if(carry_weight >= (basic_lift * 2))
		encumbrance = ENCUMBRANCE_LIGHT
	else
		encumbrance = ENCUMBRANCE_NONE
	if(encumbrance == old_level)
		if(encumbrance < ENCUMBRANCE_EXTREME)
			return
		// Above 100% the slowdown scales with the load itself, so recompute on drift
		update_encumbrance_movespeed_modifier()
		return
	// At >=120% the load pins the carbon to the ground until it is shed
	if(encumbrance >= ENCUMBRANCE_IMPOSSIBLE)
		ADD_TRAIT(src, TRAIT_FLOORED, CARRY_WEIGHT_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_FLOORED, CARRY_WEIGHT_TRAIT)
	update_encumbrance_movespeed_modifier()
	notify_encumbrance_change()

/// Slowdown curve: get_basic_slowdown() * 0.2/0.4/0.5/0.6 below 100%, then from 100%
/// to the collapse point (120%) the factor grows linearly from 0.8 to 1.6 with the load itself.
/// The modifier is dropped entirely at NONE.
/mob/living/carbon/proc/update_encumbrance_movespeed_modifier()
	var/factor = 0
	switch(encumbrance)
		if(ENCUMBRANCE_IMPOSSIBLE)
			factor = 1.6 // crawl pace; the load also pins the carbon down (update_encumbrance)
		if(ENCUMBRANCE_EXTREME)
			var/collapse_ratio = ENCUMBRANCE_COLLAPSE_PER_LIFT / ENCUMBRANCE_MAXIMUM_PER_LIFT
			var/overload = maximum_carry_weight ? clamp(carry_weight / maximum_carry_weight, 1, collapse_ratio) : collapse_ratio
			factor = 0.8 + (overload - 1) / (collapse_ratio - 1) * 0.8
		if(ENCUMBRANCE_STRENUOUS)
			factor = 0.5
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

/// Player-facing encumbrance readout (original wording). For examine.
/mob/living/carbon/proc/encumbrance_text()
	switch(encumbrance)
		if(ENCUMBRANCE_IMPOSSIBLE)
			return span_userdanger(span_big("IMPOSSIBLE!!!"))
		if(ENCUMBRANCE_EXTREME)
			return span_userdanger("Overloaded.")
		if(ENCUMBRANCE_STRENUOUS)
			return span_warning("Quite heavy.")
		if(ENCUMBRANCE_HEAVY)
			return span_userdanger("Heavy.")
		if(ENCUMBRANCE_MEDIUM)
			return span_boldnotice("Moderate weight.")
		if(ENCUMBRANCE_LIGHT)
			return span_notice("Light.")
		if(ENCUMBRANCE_NONE)
			return span_tinynotice("Traveling light.")

/mob/living/carbon/proc/notify_encumbrance_change()
	var/atom/movable/screen/encumbrance/encumbrance_hud = hud_used?.screen_objects[HUD_MOB_ENCUMBRANCE]
	encumbrance_hud?.update_status()

/mob/living/carbon/human/post_buckle_mob(mob/living/buckled_mob)
	update_carry_weight()
	return ..()

/mob/living/carbon/human/post_unbuckle_mob(mob/living/unbuckled_mob)
	update_carry_weight()
	return ..()

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

/datum/component/carry_weight/proc/on_needs_change()
	SIGNAL_HANDLER
	var/mob/living/carbon/owner = parent
	if(QDELETED(owner))
		return
	if(owner.update_maximum_carry_weight())
		refresh()

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
