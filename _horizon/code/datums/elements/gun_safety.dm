/datum/action/item_action/toggle_safety
	name = "Toggle Safety"
	button_icon = '_horizon/icons/ui/gun_actions.dmi'
	button_icon_state = "safety1"
	default_button_position = "CENTER+2:3,SOUTH+1:4"
	background_icon = NONE
	button_can_move = FALSE

/datum/action/item_action/toggle_safety/New(Target)
	. = ..()
	update_icon()

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
