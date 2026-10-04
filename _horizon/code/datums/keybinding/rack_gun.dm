// horizon-dev-sync[bot] port
// Custom keybinding for racking the bolt on ballistic guns.
//
// Upstream /tg/station uses Z (attack_self) for racking, but horizon
// overrides Z to toggle two-handed wield on heavy guns. This leaves no
// convenient way to rack the bolt.
//
// This keybinding (default: V) calls the gun's rack logic directly.
// Players can rebind it in Game Preferences -> Keybindings.

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
