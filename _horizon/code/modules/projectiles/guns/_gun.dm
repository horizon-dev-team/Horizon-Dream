/obj/item/gun
	carry_weight = 2.5 KILOGRAMS
	pickup_sound = '_horizon/sound/weapons/guns/generic_draw.wav'
	dry_fire_sound = '_horizon/sound/weapons/guns/empty.wav'
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

/obj/item/gun/Initialize(mapload)
	. = ..()
	appearance_flags |= KEEP_TOGETHER
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

/obj/item/gun/update_overlays()
	. = ..()
	if(foldable)
		//generally, the stock should be below everything else, otherwise it will look very fucked
		var/image/folding_image = image(icon, src, "[base_icon_state]_[folded ? "folded" : "unfolded"]")
		folding_image.layer = layer - 1
		. += folding_image
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

// Upstream fire_gun already does signals, pins, suicide, botch and akimbo.
// Horizon only gates flogging, field-dressing and the pre-fire hook.
/obj/item/gun/fire_gun(atom/target, mob/living/user, flag, params)
	if(QDELETED(target))
		return NONE
	if(flag)
		if((safety_flags & GUN_SAFETY_NO_FLOGGING) && user?.combat_mode)
			return NONE
		if(iscarbon(target) && user && !user.combat_mode)
			var/mob/living/carbon/carbon_target = target
			for(var/datum/wound/wound as anything in carbon_target.all_wounds)
				if(wound.try_treating(src, user))
					return NONE
	// Safety-on is a dry click. Pin failures already message inside handle_pins.
	if(istype(user) && (safety_flags & GUN_SAFETY_ENABLED))
		shoot_with_empty_chamber(user)
		return NONE
	before_can_shoot_checks(user)
	return ..()

/obj/item/gun/can_trigger_gun(mob/living/user, akimbo_usage)
	// Parent already checks can_use_guns and the firing pin.
	. = ..()
	if(!.)
		return .
	if(safety_flags & GUN_SAFETY_ENABLED)
		return FALSE
	return TRUE

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

/obj/item/gun/proc/before_can_shoot_checks(mob/living/user)
	return TRUE

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
			playsound(src, safety_off_sound, safety_sound_volume, safety_sound_vary)
	else
		safety_flags |= GUN_SAFETY_ENABLED
		if(safety_on_sound)
			playsound(src, safety_on_sound, safety_sound_volume, safety_sound_vary)
	if(user)
		to_chat(user, span_notice("I [safety_flags & GUN_SAFETY_ENABLED ? "enable" : "disable"] [src]'s safety."))
		user.update_mouse_pointer()
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
