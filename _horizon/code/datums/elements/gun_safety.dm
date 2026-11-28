/datum/action/item_action/toggle_safety
	name = "Toggle Safety"
	button_icon = '_horizon/icons/ui/gun_actions.dmi'
	button_icon_state = "safety1"
	default_button_position = "CENTER+2:3,SOUTH+1:4"
	background_icon = NONE
	button_can_move = FALSE
	var/list/safety_button_positions = list(
		"CENTER+1:16,SOUTH:5",
		"CENTER-1.5:16,SOUTH:5",
		"CENTER+1:16,SOUTH+1:5",
		"CENTER-1.5:16,SOUTH+1:5",
	)

/datum/action/item_action/toggle_safety/New(Target)
	. = ..()
	update_icon()

/datum/action/item_action/toggle_safety/Grant(mob/grant_to)
	. = ..()
	update_button_position(grant_to)
	RegisterSignal(grant_to, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_hands_swapped), override = TRUE)

/datum/action/item_action/toggle_safety/Remove(mob/remove_from)
	if(remove_from)
		UnregisterSignal(remove_from, COMSIG_MOB_SWAP_HANDS)
	return ..()

/datum/action/item_action/toggle_safety/proc/on_hands_swapped(datum/source, obj/item/new_active, obj/item/old_active)
	update_button_position(owner)

/datum/action/item_action/toggle_safety/proc/update_button_position(mob/action_owner = owner)
	if(!action_owner || !istype(target, /obj/item/gun))
		return

	var/obj/item/gun/G = target
	var/hand_index = action_owner.get_held_index_of_item(G)
	if(!hand_index)
		return

	var/position_index = clamp(hand_index, 1, 4)
	default_button_position = safety_button_positions[position_index]

	for(var/datum/hud/hud as anything in viewers)
		hud.position_action(viewers[hud], default_button_position)

/datum/action/item_action/toggle_safety/proc/update_icon()
	if(!target || !istype(target, /obj/item/gun))
		return
	var/obj/item/gun/G = target
	if(G.safety_flags & GUN_SAFETY_ENABLED)
		button_icon_state = "safety1"
	else
		button_icon_state = "safety0"
	build_all_button_icons()

/obj/item/gun/proc/safety_examine(mob/user)
	. = list()
	if(safety_flags & GUN_SAFETY_HAS_SAFETY)
		var/safety_text = span_red("OFF")
		if(safety_flags & GUN_SAFETY_ENABLED)
			safety_text = span_green("ON")
		. += "<b>Safety:</b> [safety_text]"

/obj/item/gun/proc/toggle_safety(mob/user)
	if(!(safety_flags & GUN_SAFETY_HAS_SAFETY))
		return
	if(safety_flags & GUN_SAFETY_ENABLED)
		safety_flags &= ~GUN_SAFETY_ENABLED
		if(safety_off_sound)
			playsound(src, safety_off_sound, 50, FALSE)
	else
		safety_flags |= GUN_SAFETY_ENABLED
		if(safety_on_sound)
			playsound(src, safety_on_sound, 50, FALSE)
	if(user)
		to_chat(user, span_notice("I [safety_flags & GUN_SAFETY_ENABLED ? "enable" : "disable"] [src]'s safety."))
		user.update_mouse_pointer()
	update_appearance()
	// Update safety HUD button icon
	for(var/datum/action/item_action/toggle_safety/safety_action in actions)
		safety_action.update_icon()
