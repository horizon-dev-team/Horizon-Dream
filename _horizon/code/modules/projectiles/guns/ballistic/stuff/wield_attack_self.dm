// [HORIZON] Canonical /obj/item/gun/ballistic/attack_self() definition.
//
// WARNING: do NOT define attack_self on /obj/item/gun/ballistic anywhere else
// in _horizon - this file compiles after e.g. _ballistic.dm, so any other
// definition of the same proc gets silently shadowed by this one (that is
// exactly how the "revolvers can't be unloaded" bug happened).
//
// Click (Z / activate-in-hand) on a ballistic gun now does, in order:
//  1. two-handed wield toggle for wieldable guns (wielded_inhand_state);
//  2. eject empty external magazines (upstream behaviour);
//  3. break actions (revolvers, double barrels) - full reload cycle on one
//     key ("кнопка перезарядки"):
//       - cylinder open + spent brass inside -> eject ONLY the spent
//         casings (live rounds stay chambered, cylinder stays open, so you
//         can top up right after) - the "разряжает когда барабан открыт"
//         half;
//       - cylinder open, only live rounds/empty -> snap it shut (the old
//         behaviour dumped EVERY round here, so a loaded cylinder could
//         never be closed except via the hidden drag-onto-hand gesture);
//       - cylinder closed (double action, or single action with the hammer
//         already cocked) -> break the gun open;
//       - single action with the hammer down -> cock the hammer (rack),
//         the second click then opens the gun;
//  4. upstream logic: NO_BOLT dump-all, LOCKING bolt drop, rack.
//
// Right-click (attack_self_secondary below) with a broken-open gun is the
// hard unload: it dumps EVERYTHING, live rounds included.
// Dragging the gun onto a hand slot (see mouse_drop_dragged in _ballistic.dm)
// toggles the cylinder open/closed as well.

/obj/item/gun/ballistic/attack_self(mob/living/user, modifiers)
	// 1) Two-handed wield toggle.
	if(wielded_inhand_state && user?.is_holding(src) && istype(user, /mob/living/carbon))
		var/datum/component/two_handed/two_handed_component = GetComponent(/datum/component/two_handed)
		if(two_handed_component)
			if(two_handed_component.wielded)
				two_handed_component.unwield(user)
			else
				two_handed_component.wield(user)
			return
	// 2) Empty external magazine eject.
	if(!internal_magazine && magazine)
		if(!magazine.ammo_count())
			eject_magazine(user)
			return
	// 3) Break action guns: open / eject brass / close by clicking.
	if(bolt_type == BOLT_TYPE_BREAK_ACTION)
		if(cylinder_open)
			// [HORIZON-FIX] Spent brass goes first: pressing the reload key
			// with an open cylinder pops the empty casings out but keeps the
			// live rounds chambered, so the SAME key can then close the gun.
			// (The old behaviour dumped every round - including freshly loaded
			// ones - which made a loaded cylinder impossible to close.)
			var/live_rounds = get_ammo(FALSE, FALSE)
			var/all_rounds = get_ammo(FALSE, TRUE)
			if(all_rounds > live_rounds)
				eject_spent_casings(user)
				return
			toggle_cylinder_open(user) // only live rounds (or empty) left - snap it shut
			return
		if(semi_auto || !bolt_locked)
			// Double action revolvers/shotguns (and single actions that are
			// already cocked) break the gun open on click.
			toggle_cylinder_open(user)
			return
		// Single action revolver with the hammer down: cock it first.
		// Falls through to the rack below.
	// 4) Upstream behaviour.
	if(bolt_type == BOLT_TYPE_NO_BOLT)
		unload_ammo(user)
		return
	if(bolt_type == BOLT_TYPE_LOCKING && bolt_locked)
		drop_bolt(user)
		return
	if(recent_rack > world.time)
		return
	recent_rack = world.time + rack_delay
	rack(user)
