// Horizon additions to /obj/item/gun/ballistic/attack_self:
// 1. wield toggle for wielded_inhand_state guns;
// 2. break-action cylinder handling (open: dump spent casings or close it,
//    closed: break it open unless a non-semi-auto hammer is cocked).
// The rest of the old copy (mag eject / bolt / rack tail) is dropped and
// chains to base via ..(), so core fixes are no longer shadowed.
// NOTE: the wield branch must NOT fall through to ..() - base
// /obj/item/attack_self sends COMSIG_ITEM_ATTACK_SELF, which the core
// two_handed component also answers with a wield toggle, so chaining
// would toggle twice and cancel out.
/obj/item/gun/ballistic/attack_self(mob/living/user)
	if(wielded_inhand_state && user?.is_holding(src) && istype(user, /mob/living/carbon))
		var/datum/component/two_handed/two_handed_component = GetComponent(/datum/component/two_handed)
		if(two_handed_component)
			if(two_handed_component.wielded)
				two_handed_component.unwield(user)
			else
				two_handed_component.wield(user)
			return
	if(bolt_type == BOLT_TYPE_BREAK_ACTION)
		if(cylinder_open)
			var/live_rounds = get_ammo(FALSE, FALSE)
			var/all_rounds = get_ammo(FALSE, TRUE)
			if(all_rounds > live_rounds)
				eject_spent_casings(user)
				return
			toggle_cylinder_open(user)
			return
		if(semi_auto || !bolt_locked)
			toggle_cylinder_open(user)
			return
	return ..()
