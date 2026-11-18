/obj/item/gun
	carry_weight = 2.5 KILOGRAMS
	pickup_sound = '_horizon/sound/weapons/guns/generic_draw.wav'
	dry_fire_sound = '_horizon/sound/weapons/guns/empty.wav'
	/// Message when we dry fire (applies both to dry firing and failing to fire for other reasons)
	var/dry_fire_message = span_danger("*click*")
	/// Whether to vary dry_fire_sound or not
	var/dry_fire_sound_vary = FALSE
	/// Sound for aiming at someone
	var/aim_stress_sound = '_horizon/sound/weapons/guns/aim_stress.wav'
	/// Volume for aiming sound
	var/aim_stress_sound_volume = 50
	/// Whether the aiming sound should vary on not
	var/aim_stress_sound_vary = FALSE
	/// Sound for stopping aiming at someone
	var/aim_spare_sound = '_horizon/sound/weapons/guns/aim_spare.wav'
	/// Volume for stopping aiming sound
	var/aim_spare_sound_volume = 50
	/// Whether the stopping aiming sound should vary on not
	var/aim_spare_sound_vary = FALSE
	/// Flags related to gun safety
	var/safety_flags = GUN_SAFETY_FLAGS_DEFAULT
	/// Sound when safety is toggled on
	var/safety_on_sound = '_horizon/sound/weapons/guns/safety1.ogg'
	/// Sound when safety is toggled off
	var/safety_off_sound = '_horizon/sound/weapons/guns/safety1.ogg'
	/// Volume of safety toggle sounds (both on and off)
	var/safety_sound_volume = 50
	/// Whether to vary safety toggle sounds or not
	var/safety_sound_vary = FALSE

	// ~ICON VARIABLES
	/// Mouse pointer icon when holding this gun while the safety is disabled
	var/mouse_pointer_icon = '_horizon/icons/effects/mouse_pointers/weapon_pointer.dmi'
	/// Does the gun have a unique icon_state when nothing is chambered?
	var/empty_icon_state = FALSE
	/// Does the gun have unique inhands when wielded?
	var/wielded_inhand_state = FALSE
	/// Does the inhand state get modifier when sawn?
	var/sawn_inhand_state = FALSE

	/// NO FULL AUTO IN BUILDINGS!
	var/full_auto = FALSE

	// ~SHIPTEST-STYLE UNWIELDED SPREAD
	/// Extra random spread when firing this gun without a two-handed grip
	/// (wielded_inhand_state guns). 0 = no penalty. Used with the laser sight
	/// attachment, which reduces both spread and spread_unwielded.
	var/spread_unwielded = 0

	// Folding stock variables
	/// Allows the gun's stock to be folded and unfolded.
	var/foldable = FALSE
	/// Whether the stock is folded or not.
	var/folded = TRUE
	/// The sound it makes when you fold a stock
	var/fold_open_sound = '_horizon/sound/weapons/guns/stock_open.wav'
	/// The sound it makes when you unfold a stock.
	var/fold_close_sound = '_horizon/sound/weapons/guns/stock_close.wav'
	/// Every time you fiddle with the stock
	var/fiddle = '_horizon/sound/effects/fiddle.wav'

/obj/item/gun/New()
	. = ..()
	appearance_flags |= KEEP_TOGETHER

/obj/item/gun/Initialize(mapload)
	. = ..()
	if(foldable)
		add_item_action(/datum/action/item_action/toggle_stock)
	if(full_auto)
		initialize_full_auto()
	if(wielded_inhand_state)
		AddComponent(/datum/component/two_handed, \
			wieldsound = '_horizon/sound/weapons/guns/stock_open.wav', \
			unwieldsound = '_horizon/sound/weapons/guns/stock_close.wav')
	if(safety_flags & GUN_SAFETY_HAS_SAFETY)
		add_item_action(/datum/action/item_action/toggle_safety)
	// Shiptest attachment system: every gun gets a holder component.
	// handle_attack() only reacts to TRAIT_ATTACHABLE items and crowbars,
	// so normal interactions are untouched.
	AddComponent(/datum/component/attachment_holder, slot_available, valid_attachments, slot_offsets, default_attachments)

/obj/item/gun/update_icon(updates)
	. = ..()
	if(wielded_inhand_state)
		if(SEND_SIGNAL(src, COMSIG_TWOHANDED_WIELD_CHECK))
			inhand_icon_state = "[initial(inhand_icon_state)][(sawn_off && sawn_inhand_state) ? "_sawn" : ""]_wielded"
		else
			inhand_icon_state = "[initial(inhand_icon_state)][(sawn_off && sawn_inhand_state) ? "_sawn" : ""]"
	else if(sawn_inhand_state)
		inhand_icon_state = "[initial(inhand_icon_state)][sawn_off ? "_sawn" : ""]"

// NOTE: the gun-level "_empty" icon_state suffix lives in the ballistic
// override (see _ballistic.dm). It can't live here: this gun-level version
// runs BEFORE core ballistic's icon_state reset (via the ..() chain), so any
// suffix it appends gets wiped for every ballistic gun.

/obj/item/gun/update_overlays()
	. = ..()
	if(foldable)
		//generally, the stock should be below everything else, otherwise it will look very fucked
		var/image/folding_image = image(icon, src, "[base_icon_state]_[folded ? "folded" : "unfolded"]")
		folding_image.layer = layer - 1
		. += folding_image
	// Flashlight and bayonet overlays are now handled by upstream's
	// /datum/component/seclite_attachable and /datum/component/bayonet_attachable
	// respectively. We don't render them manually here.
	if(safety_flags & GUN_SAFETY_HAS_SAFETY)
		var/image/safety_overlay
		if((safety_flags & GUN_SAFETY_ENABLED) && (safety_flags & GUN_SAFETY_OVERLAY_ENABLED))
			safety_overlay = image(icon, src, "[base_icon_state]_safe")
		else if(!(safety_flags & GUN_SAFETY_ENABLED) && (safety_flags & GUN_SAFETY_OVERLAY_DISABLED))
			safety_overlay = image(icon, src, "[base_icon_state]_unsafe")
		if(safety_overlay)
			. += safety_overlay

/obj/item/gun/examine(mob/user)
	. = ..()
	var/safety_examine = safety_examine(user)
	if(LAZYLEN(safety_examine))
		. += safety_examine

/obj/item/gun/add_weapon_description()
	AddElement(/datum/element/weapon_description, PROC_REF(add_notes_gun))

/obj/item/gun/get_carry_weight()
	. = ..()
	if(istype(pin))
		. += pin.get_carry_weight()

/obj/item/gun/equipped(mob/living/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HANDS)
		user.update_mouse_pointer()

/obj/item/gun/dropped(mob/user)
	. = ..()
	user.update_mouse_pointer()

/obj/item/gun/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	. = ..()
	if(!foldable)
		return
	if(!isliving(usr) || !user.Adjacent(src) || HAS_TRAIT(user, TRAIT_INCAPACITATED))
		return
	if(isopenturf(over))
		toggle_stock(user)

/obj/item/gun/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(safety_flags & GUN_SAFETY_HAS_SAFETY)
		toggle_safety(user)

// Gunpoint (holding someone up at gunpoint) is now handled by upstream's
// /obj/item/gun/interact_with_atom_secondary() which checks can_hold_up
// and adds /datum/component/gunpoint. No need for a horizon override.

/obj/item/gun/fire_gun(atom/target, mob/living/user, flag, params)
	if(QDELETED(target))
		return
	if(firing_burst)
		return
	// Upstream signals: let mobs (implants, MODsuits, etc.) and the gun
	// itself (attachments via attachment_holder) cancel the shot.
	if(SEND_SIGNAL(user, COMSIG_MOB_TRYING_TO_FIRE_GUN, src, target, flag, params) & COMPONENT_CANCEL_GUN_FIRE)
		return
	if(SEND_SIGNAL(src, COMSIG_GUN_TRY_FIRE, user, target, flag, params) & COMPONENT_CANCEL_GUN_FIRE)
		return
	//It's adjacent, is the user, or is on the user's person
	if(flag)
		//Can't shoot stuff inside us.
		if(target in user.contents)
			return
		var/list/modifiers = params2list(params)
		//Gun does not fire when flogging
		if((safety_flags & GUN_SAFETY_NO_FLOGGING) && IS_HARM_INTENT(user, modifiers))
			return
		if(iscarbon(target) && !IS_HARM_INTENT(user, modifiers))
			var/mob/living/carbon/carbon_target = target
			for(var/datum/wound/wound as anything in carbon_target.all_wounds)
				if(wound.try_treating(src, user))
					return

	//Check if the user can use the gun, if the user isn't alive (turrets) assume it can.
	if(istype(user))
		if(!can_trigger_gun(user))
			shoot_with_empty_chamber(user)
			return

	// Upstream: aiming at our own mouth with an adjacent shot starts the suicide do_after.
	// Kept after the can_trigger_gun() check so the safety blocks it like any other shot.
	if(flag && doafter_self_shoot && user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		return handle_suicide(user, target, params)

	//Just because you can pull the trigger doesn't mean it can shoot.
	before_can_shoot_checks(user, FALSE)
	if(!can_shoot())
		shoot_with_empty_chamber(user)
		return

	if(check_botched(user, target))
		return

	//DUAL (or more!) WIELDING
	var/bonus_spread = 0
	var/loop_counter = 0
	var/list/modifiers = params2list(params)
	if(ishuman(user) && IS_HARM_INTENT(user, modifiers) && !HAS_TRAIT(user, TRAIT_NO_GUN_AKIMBO))
		var/mob/living/carbon/human/human_user = user
		for(var/obj/item/gun/other_gun in human_user.held_items)
			if((other_gun == src) || (other_gun.weapon_weight >= WEAPON_MEDIUM))
				continue
			else if(other_gun.can_trigger_gun(user))
				bonus_spread += dual_wield_spread
				loop_counter++
				addtimer(CALLBACK(other_gun, TYPE_PROC_REF(/obj/item/gun, process_fire), target, user, TRUE, params, null, bonus_spread), loop_counter)

	return process_fire(target, user, TRUE, params, null, bonus_spread)

/obj/item/gun/can_trigger_gun(mob/living/user, akimbo_usage)
	// Chain into upstream's checks (can_use_guns + firing pins), then add
	// horizon's safety check on top. Signature matches upstream so callers
	// using the akimbo_usage keyword argument don't runtime.
	. = ..()
	if(!.)
		return .
	if(!handle_pins(user))
		return FALSE
	// Safety checks: if safety is ENABLED (ON), the gun cannot fire.
	if(safety_flags & GUN_SAFETY_ENABLED)
		return FALSE
	return TRUE

// check_botched() intentionally has no horizon override: upstream's version is
// newer (tk_firing / NODROP / random valid zone handling) and is used directly.

/obj/item/gun/on_autofire_start(mob/living/shooter)
	if(fire_cd || shooter.incapacitated || shooter.stat)
		return NONE
	if(istype(src, /obj/item/gun/ballistic/automatic))
		var/obj/item/gun/ballistic/automatic/automatic_source = src
		//Not on full auto select
		if(automatic_source.select != 3)
			return NONE
	//Check if the user can use the gun, if the user isn't alive (turrets) assume it can
	if(istype(shooter))
		if(!can_trigger_gun(shooter))
			shoot_with_empty_chamber(shooter)
			return NONE
	//Just because you can pull the trigger doesn't mean it can shoot
	before_can_shoot_checks(shooter, TRUE)
	if(!can_shoot())
		shoot_with_empty_chamber(shooter)
		return NONE
	// [HORIZON-EDIT] Heavy guns can be fired one-handed now. The old hard
	// block backfired while wielding: the two-handed component parks an
	// /obj/item/offhand dummy in the inactive hand, so "use both hands!"
	// triggered exactly when the gun WAS held with both hands. Unwielded
	// firing is penalized through spread_unwielded in process_fire instead.
	return TRUE

/// Signal handler for COMSIG_AUTOFIRE_SHOT. The signature must match upstream's
/// (datum/source, atom/target, mob/living/shooter, allow_akimbo, params) or the
/// last two arguments shift and the mouse params are silently lost.
/obj/item/gun/do_autofire(datum/source, atom/target, mob/living/shooter, allow_akimbo, params)
	if(fire_cd || shooter.incapacitated || shooter.stat)
		return NONE
	if(istype(src, /obj/item/gun/ballistic/automatic))
		var/obj/item/gun/ballistic/automatic/automatic_source = src
		//Not on full auto select
		if(automatic_source.select != 3)
			return NONE
	//Check if the user can use the gun, if the user isn't alive (turrets) assume it can
	if(istype(shooter))
		if(!can_trigger_gun(shooter))
			shoot_with_empty_chamber(shooter)
			return NONE
	//Just because you can pull the trigger doesn't mean it can shoot
	before_can_shoot_checks(shooter, FALSE)
	if(!can_shoot())
		shoot_with_empty_chamber(shooter)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(do_autofire_shot), source, target, shooter, allow_akimbo, params)
	return COMPONENT_AUTOFIRE_SHOT_SUCCESS //All is well, we can continue shooting

/obj/item/gun/shoot_with_empty_chamber(mob/living/user as mob|obj)
	if(ismob(user) && dry_fire_message)
		to_chat(user, dry_fire_message)
	if(dry_fire_sound)
		playsound(src, dry_fire_sound, dry_fire_sound_volume, dry_fire_sound_vary)
	sound_hint()

/obj/item/gun/proc/initialize_full_auto()
	if(!full_auto)
		return FALSE
	AddComponent(/datum/component/automatic_fire)

/obj/item/gun/proc/add_notes_gun(mob/user)
	. = list()
	switch(weapon_weight)
		if(WEAPON_HEAVY)
			. += span_notice("<b>Weapon Weight:</b> Heavy")
		if(WEAPON_MEDIUM)
			. += span_notice("<b>Weapon Weight:</b> Medium")
		if(WEAPON_LIGHT)
			. += span_notice("<b>Weapon Weight:</b> Light")
		else
			. += span_notice("<b>Weapon Weight:</b> Invalid")

/obj/item/gun/proc/before_can_shoot_checks(mob/living/user, autofire_start = FALSE)
	return TRUE

/obj/item/gun/proc/safety_examine(mob/user)
	. = list()
	if(safety_flags & GUN_SAFETY_HAS_SAFETY)
		var/safety_text = span_red("OFF")
		if(safety_flags & GUN_SAFETY_ENABLED)
			safety_text = span_green("ON")
		. += "[p_their(TRUE)] safety is [safety_text]."

/obj/item/gun/proc/toggle_safety(mob/user)
	if(!(safety_flags & GUN_SAFETY_HAS_SAFETY))
		return
	if(safety_flags & GUN_SAFETY_ENABLED)
		safety_flags &= ~GUN_SAFETY_ENABLED
		if(safety_off_sound)
			playsound(src, safety_off_sound, safety_sound_volume, safety_sound_vary)
	else
		safety_flags |= GUN_SAFETY_ENABLED
		if(safety_on_sound)
			playsound(src, safety_on_sound, safety_sound_volume, safety_sound_vary)
	if(user)
		to_chat(user, span_notice("I [safety_flags & GUN_SAFETY_ENABLED ? "enable" : "disable"] [src]'s safety."))
		user.update_mouse_pointer()
	sound_hint()
	update_appearance()
	// Update safety HUD button icon
	for(var/datum/action/item_action/toggle_safety/safety_action in actions)
		safety_action.update_icon()

/obj/item/gun/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_stock))
		toggle_stock(user)
	else if(istype(actiontype, /datum/action/item_action/toggle_safety))
		toggle_safety(user)
	else
		return ..()

/obj/item/gun/proc/toggle_stock(mob/user)
	if(!foldable)
		return
	playsound(src, fiddle, 68, FALSE)
	if(!do_after(user, 0.5 SECONDS, src))
		return
	if(!folded)
		w_class--
		folded = TRUE
		playsound(src, fold_close_sound, 80, FALSE)
		to_chat(user, span_notice("I fold [src]'s stock."))
	else
		w_class++
		folded = FALSE
		playsound(src, fold_open_sound, 80, FALSE)
		to_chat(user, span_notice("I unfold [src]'s stock."))
	update_appearance()

/datum/action/item_action/toggle_stock
	name = "Toggle Stock"
	button_icon = '_horizon/icons/hud/actions.dmi'
	button_icon_state = "stock"

// =============================================================================
// SHIPTEST-STYLE UNWIELDED SPREAD
// Two-handed guns (wielded_inhand_state) can always be fired one-handed, but
// get extra random spread unless they are wielded (TRAIT_WIELDED is granted by
// /datum/component/two_handed while wielded). The laser sight attachment
// reduces both spread and spread_unwielded to offset this.
// =============================================================================

/obj/item/gun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(spread_unwielded && !HAS_TRAIT(src, TRAIT_WIELDED))
		bonus_spread += rand(0, spread_unwielded)
	return ..()

/obj/item/gun/process_burst(mob/living/user, atom/target, message = TRUE, params = null, zone_override = "", random_spread = 0, burst_spread_mult = 0, iteration = 0)
	if(spread_unwielded && !HAS_TRAIT(src, TRAIT_WIELDED))
		random_spread += rand(0, spread_unwielded)
	return ..()
