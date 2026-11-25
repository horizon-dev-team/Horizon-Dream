/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/resist
	hotkey_keys = list("B")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffed? on fire? Resist!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/owner = user.mob
	owner.resist()
	if (owner.hud_used?.screen_objects[HUD_MOB_RESIST])
		owner.hud_used.screen_objects[HUD_MOB_RESIST].icon_state = "[owner.hud_used.screen_objects[HUD_MOB_RESIST].base_icon_state]_on"
	return TRUE

/datum/keybinding/living/resist/up(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/owner = user.mob
	if (owner.hud_used?.screen_objects[HUD_MOB_RESIST])
		owner.hud_used.screen_objects[HUD_MOB_RESIST].icon_state = owner.hud_used.screen_objects[HUD_MOB_RESIST].base_icon_state

/datum/keybinding/living/look_up
	hotkey_keys = list("L")
	name = "look up"
	full_name = "Look Up"
	description = "Look up at the next z-level.  Only works if directly below open space."
	keybind_signal = COMSIG_KB_LIVING_LOOKUP_DOWN

/datum/keybinding/living/look_up/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_up()
	return TRUE

/datum/keybinding/living/look_up/up(client/user, turf/target)
	. = ..()
	var/mob/living/L = user.mob
	L.end_look()
	return TRUE

/datum/keybinding/living/look_down
	hotkey_keys = list(";")
	name = "look down"
	full_name = "Look Down"
	description = "Look down at the previous z-level.  Only works if directly above open space."
	keybind_signal = COMSIG_KB_LIVING_LOOKDOWN_DOWN

/datum/keybinding/living/look_down/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_down()
	return TRUE

/datum/keybinding/living/look_down/up(client/user, turf/target)
	. = ..()
	var/mob/living/L = user.mob
	L.end_look()
	return TRUE

/datum/keybinding/living/rest
	hotkey_keys = list("U")
	name = "rest"
	full_name = "Rest"
	description = "Lay down, or get up."
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN

/datum/keybinding/living/rest/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	living_mob.toggle_resting()
	return TRUE

/datum/keybinding/living/toggle_combat_mode
	hotkey_keys = list("F")
	name = "toggle_combat_mode"
	full_name = "Toggle Combat Mode"
	description = "Toggles combat mode. Like Help/Harm but cooler."
	keybind_signal = COMSIG_KB_LIVING_TOGGLE_COMBAT_DOWN


/datum/keybinding/living/toggle_combat_mode/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(!user_mob.combat_mode, FALSE)

/datum/keybinding/living/enable_combat_mode
	hotkey_keys = list("4")
	name = "enable_combat_mode"
	full_name = "Enable Combat Mode"
	description = "Enable combat mode."
	keybind_signal = COMSIG_KB_LIVING_ENABLE_COMBAT_DOWN

/datum/keybinding/living/enable_combat_mode/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(TRUE, silent = FALSE)

/datum/keybinding/living/disable_combat_mode
	hotkey_keys = list("1")
	name = "disable_combat_mode"
	full_name = "Disable Combat Mode"
	description = "Disable combat mode."
	keybind_signal = COMSIG_KB_LIVING_DISABLE_COMBAT_DOWN

/datum/keybinding/living/disable_combat_mode/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	user_mob.set_combat_mode(FALSE, silent = FALSE)

/datum/keybinding/living/toggle_move_intent
	hotkey_keys = list("C")
	name = "toggle_move_intent"
	full_name = "Hold to toggle move intent"
	description = "Held down to cycle to the other move intent, release to cycle back"
	keybind_signal = COMSIG_KB_LIVING_TOGGLEMOVEINTENT_DOWN

/datum/keybinding/living/toggle_move_intent/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/living/toggle_move_intent/up(client/user, turf/target)
	. = ..()
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/living/toggle_move_intent_alternative
	hotkey_keys = list(UNBOUND_KEY)
	name = "toggle_move_intent_alt"
	full_name = "press to cycle move intent"
	description = "Pressing this cycle to the opposite move intent, does not cycle back"
	keybind_signal = COMSIG_KB_LIVING_TOGGLEMOVEINTENTALT_DOWN

/datum/keybinding/living/toggle_move_intent_alternative/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/M = user.mob
	M.toggle_move_intent()
	return TRUE

/datum/keybinding/living/toggle_throw_mode
	hotkey_keys = list("R", "Southwest") // END
	name = "toggle_throw_mode"
	full_name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."
	keybind_signal = COMSIG_KB_LIVING_TOGGLETHROWMODE_DOWN

/datum/keybinding/living/toggle_throw_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/living_user = user.mob
	living_user.toggle_throw_mode()
	return TRUE

/datum/keybinding/living/hold_throw_mode
	hotkey_keys = list(UNBOUND_KEY)
	name = "hold_throw_mode"
	full_name = "Hold throw mode"
	description = "Hold this to turn on throw mode, and release it to turn off throw mode"
	keybind_signal = COMSIG_KB_LIVING_HOLDTHROWMODE_DOWN

/datum/keybinding/living/hold_throw_mode/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/living_user = user.mob
	living_user.throw_mode_on(THROW_MODE_HOLD)

/datum/keybinding/living/hold_throw_mode/up(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/living_user = user.mob
	living_user.throw_mode_off(THROW_MODE_HOLD)

/datum/keybinding/living/give
	hotkey_keys = list("G")
	name = "Give_Item"
	full_name = "Give item"
	description = "Give the item you're currently holding"
	keybind_signal = COMSIG_KB_LIVING_GIVEITEM_DOWN

/datum/keybinding/living/give/can_use(client/user)
	. = ..()
	if (!.)
		return FALSE
	var/mob/living/living_user = astype(user.mob, /mob/living)
	if(!living_user)
		return FALSE
	var/obj/item/object = living_user.get_active_held_item()
	if(isnull(object))
		return FALSE
	return living_user.can_hold_items(object) || HAS_TRAIT(object, TRAIT_BORG_GIVE)

/datum/keybinding/living/give/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/living_user = user.mob
	var/obj/item/held_item = living_user.get_active_held_item()
	if(isnull(held_item))
		return
	if(!living_user.can_hold_items(held_item) && !HAS_TRAIT(held_item, TRAIT_BORG_GIVE))
		return
	living_user.give()

/datum/keybinding/living/view_pet_data
	hotkey_keys = list("Shift")
	name = "view_pet_commands"
	full_name = "View Pet Commands"
	description = "Hold down to see all the commands you can give your pets!"
	keybind_signal = COMSIG_KB_LIVING_VIEW_PET_COMMANDS

/datum/keybinding/living/cancel_interactions
	name = "stop_interactions"
	full_name = "Cancel Interactions"
	description = "Cancels any ongoing interactions (such as using a tool, performing surgery, or climbing). \
		Note that some interactions cannot be interrupted, and you can't cancel other player's interaction with this hotkey."
	keybind_signal = COMSIG_KB_LIVING_STOP_INTERACTIONS_DOWN

// [HORIZON-ADD] GunRework
/datum/keybinding/living/rack_gun
	hotkey_keys = list("Space")
	name = "rack_gun"
	full_name = "Rack Gun Bolt"
	description = "Rack the bolt / drop bolt / unload the held ballistic gun. Works on both wieldable and non-wieldable guns."
	keybind_signal = COMSIG_KB_LIVING_RACKGUN_DOWN

/datum/keybinding/living/rack_gun/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/rack_gun/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/owner = user.mob
	if(!owner)
		return
	// Find the gun in the active hand
	var/obj/item/active_item = owner.get_active_held_item()
	if(!active_item || !istype(active_item, /obj/item/gun/ballistic))
		return
	var/obj/item/gun/ballistic/gun = active_item
	// Rack the bolt directly
	if(gun.bolt_type == BOLT_TYPE_NO_BOLT)
		gun.unload_ammo(owner)
		return TRUE
	if(gun.bolt_type == BOLT_TYPE_LOCKING && gun.bolt_locked)
		gun.drop_bolt(owner)
		return TRUE
	if(gun.recent_rack > world.time)
		return TRUE
	gun.recent_rack = world.time + gun.rack_delay
	gun.rack(owner)
	return TRUE
// [/HORIZON-ADD]
