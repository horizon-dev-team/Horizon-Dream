/obj/item/ammo_box/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/ammo_box/magazine/ammo_stack))
		var/obj/item/ammo_box/magazine/ammo_stack/stack = tool
		return stack.try_take_round(user, src)
	if(isammocasing(tool))
		var/obj/item/ammo_casing/casing = tool
		return try_stack_with_round(user, casing)
	if(istype(tool, /obj/item/ammo_box))
		src.balloon_alert(user, "need an ammo stack!")
		return ITEM_INTERACT_BLOCKING
	return NONE

/obj/item/ammo_box/magazine/ammo_stack/proc/try_take_round(mob/living/user, obj/item/ammo_box/source)
	if(length(stored_ammo) >= max_ammo)
		source.balloon_alert(user, "stack is full!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/ammo_casing/chosen
	var/any_live_rounds = FALSE
	for(var/obj/item/ammo_casing/candidate in source.ammo_list())
		if(!candidate.loaded_projectile)
			continue
		any_live_rounds = TRUE
		if(is_compatible_round(candidate))
			chosen = candidate
			break
	if(!chosen)
		if(!length(source.stored_ammo))
			source.balloon_alert(user, "no rounds left!")
		else if(!any_live_rounds)
			source.balloon_alert(user, "only spent casings!")
		else
			source.balloon_alert(user, "wrong ammo type!")
		return ITEM_INTERACT_BLOCKING

	if(!give_round(chosen))
		source.balloon_alert(user, "stack is full!")
		return ITEM_INTERACT_BLOCKING
	playsound(src, 'sound/items/weapons/gun/general/mag_bullet_insert.ogg', 60, TRUE)
	to_chat(user, span_notice("You take \a [chosen] from \the [source]."))
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/ammo_box/proc/try_stack_with_round(mob/living/user, obj/item/ammo_casing/hand_casing)
	if(!hand_casing.stack_type)
		src.balloon_alert(user, "not stackable!")
		return ITEM_INTERACT_BLOCKING
	if(!hand_casing.loaded_projectile)
		src.balloon_alert(user, "spent casing!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/ammo_casing/chosen
	var/any_live_rounds = FALSE
	for(var/obj/item/ammo_casing/candidate in ammo_list())
		if(!candidate.loaded_projectile)
			continue
		any_live_rounds = TRUE
		if(candidate.stack_type == hand_casing.stack_type)
			chosen = candidate
			break
	if(!chosen)
		if(!length(stored_ammo))
			src.balloon_alert(user, "no rounds left!")
		else if(!any_live_rounds)
			src.balloon_alert(user, "only spent casings!")
		else
			src.balloon_alert(user, "wrong ammo type!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/ammo_box/magazine/ammo_stack/new_stack = new hand_casing.stack_type(drop_location())
	user.transferItemToLoc(hand_casing, new_stack, silent = TRUE)
	new_stack.give_round(hand_casing)
	new_stack.give_round(chosen) // forceMove inside triggers Exited -> src.remove_from_stored_ammo
	user.put_in_hands(new_stack)
	new_stack.update_appearance()
	update_appearance()
	playsound(src, 'sound/items/weapons/gun/general/mag_bullet_insert.ogg', 60, TRUE)
	to_chat(user, span_notice("You stack \the [hand_casing] with \a [chosen] from \the [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/ammo_box/attack_hand(mob/user, list/modifiers)
	if(loc == user && !istype(src, /obj/item/ammo_box/magazine/recharge))
		var/obj/item/ammo_casing/round = get_round()
		if(round)
			round.forceMove(drop_location())
			if(!user.put_in_hands(round))
				round.bounce_away(bounce_angle = null, spread_multiplier = 0.75, still_warm = FALSE, sound_delay = 0)
			playsound(src, 'sound/items/weapons/gun/general/mag_bullet_insert.ogg', 60, TRUE)
			to_chat(user, span_notice("You remove a [casing_phrasing] from [src]!"))
			update_appearance()
			return TRUE
	return ..()
