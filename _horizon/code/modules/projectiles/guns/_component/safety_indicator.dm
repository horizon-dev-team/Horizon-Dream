/datum/action/item_action/toggle_safety
	name = "Toggle Safety"
	button_icon = '_horizon/icons/ui/gun_actions.dmi'
	button_icon_state = "safety1"
	default_button_position = "EAST-1:28,SOUTH+1:27"

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
