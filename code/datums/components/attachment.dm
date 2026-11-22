/datum/component/attachment
	///Slot the attachment goes on, also used in descriptions so should be player readable
	var/slot
	///various yes no flags associated with attachments. See defines for these: [_DEFINES/guns.dm]
	var/attach_features_flags
	///Unused so far, should probally handle it in the parent unless you have a specific reason
	var/list/valid_parent_types
	var/datum/callback/on_attach
	var/datum/callback/on_detach
	var/datum/callback/on_toggle
	var/datum/callback/on_toggle_ammo
	var/datum/callback/on_attacked
	var/datum/callback/on_ctrl_click
	var/datum/callback/on_alt_click
	var/datum/callback/on_examine
	var/datum/callback/on_attack_hand
	///Called on the parent's fire_gun
	var/datum/callback/on_fire_gun
	///Called on the parents preattack
	var/datum/callback/on_preattack
	///Called on the parents wield
	var/datum/callback/on_wield
	///Called on the parents unwield
	var/datum/callback/on_unwield
	///Unused...Also a little broken..
	var/list/datum/action/actions
	///Generated if the attachment can toggle, sends COMSIG_ATTACHMENT_TOGGLE
	var/datum/action/attachment/attachment_toggle_action
	///Generated if the attachment can toggle ammo, sends COMSIG_ATTACHMENT_TOGGLE_AMMO
	var/datum/action/attachment/attachment_ammo_action

/datum/component/attachment/Initialize(
		slot = ATTACHMENT_SLOT_RAIL,
		attach_features_flags = ATTACH_REMOVABLE_HAND,
		valid_parent_types = list(/obj/item/gun),
		datum/callback/on_attach = null,
		datum/callback/on_detach = null,
		datum/callback/on_toggle = null,
		datum/callback/on_toggle_ammo = null,
		datum/callback/on_fire_gun = null,
		datum/callback/on_preattack = null,
		datum/callback/on_attacked = null,
		datum/callback/on_ctrl_click = null,
		datum/callback/on_wield = null,
		datum/callback/on_unwield = null,
		datum/callback/on_examine = null,
		datum/callback/on_alt_click = null,
		datum/callback/on_attack_hand = null,
		list/signals = null
	)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.slot = slot
	src.attach_features_flags = attach_features_flags
	src.valid_parent_types = valid_parent_types
	src.on_attach = on_attach
	src.on_detach = on_detach
	src.on_toggle = on_toggle
	src.on_toggle_ammo = on_toggle_ammo
	src.on_fire_gun = on_fire_gun
	src.on_preattack = on_preattack
	src.on_attacked = on_attacked
	src.on_ctrl_click = on_ctrl_click
	src.on_wield = on_wield
	src.on_unwield = on_unwield
	src.on_examine = on_examine
	src.on_alt_click = on_alt_click
	src.on_attack_hand = on_attack_hand

	ADD_TRAIT(parent, TRAIT_ATTACHABLE, "attachable")
	RegisterSignal(parent, COMSIG_ATTACHMENT_ATTACH, PROC_REF(try_attach))
	RegisterSignal(parent, COMSIG_ATTACHMENT_DETACH, PROC_REF(try_detach))
	RegisterSignal(parent, COMSIG_ATTACHMENT_EXAMINE, PROC_REF(handle_examine))
	if(attach_features_flags & ATTACH_TOGGLE)
		RegisterSignal(parent, COMSIG_ATTACHMENT_TOGGLE, PROC_REF(try_toggle))
		attachment_toggle_action = new /datum/action/attachment/toggle(parent)
	if(attach_features_flags & ATTACH_AMMOMODE)
		RegisterSignal(parent, COMSIG_ATTACHMENT_TOGGLE_AMMO, PROC_REF(try_ammo))
		attachment_ammo_action = new /datum/action/attachment/ammo(parent)
	RegisterSignal(parent, COMSIG_ATTACHMENT_TRY_FIRE_GUN, PROC_REF(try_fire_gun))
	RegisterSignal(parent, COMSIG_ATTACHMENT_PRE_ATTACK, PROC_REF(relay_pre_attack))
	RegisterSignal(parent, COMSIG_ATTACHMENT_UPDATE_OVERLAY, PROC_REF(update_overlays))
	RegisterSignal(parent, COMSIG_ATTACHMENT_GET_SLOT, PROC_REF(send_slot))
	RegisterSignal(parent, COMSIG_ATTACHMENT_CHANGE_SLOT, PROC_REF(change_slot))
	RegisterSignal(parent, COMSIG_ATTACHMENT_WIELD, PROC_REF(try_wield))
	RegisterSignal(parent, COMSIG_ATTACHMENT_UNWIELD, PROC_REF(try_unwield))
	RegisterSignal(parent, COMSIG_ATTACHMENT_ATTACK, PROC_REF(relay_attacked))
	RegisterSignal(parent, COMSIG_ATTACHMENT_CTRL_CLICK, PROC_REF(relay_ctrl_click))
	RegisterSignal(parent, COMSIG_ATTACHMENT_ALT_CLICK, PROC_REF(relay_alt_click))
	RegisterSignal(parent, COMSIG_ATTACHMENT_ATTACK_HAND, PROC_REF(relay_attack_hand))

	for(var/signal in signals)
		RegisterSignal(parent, signal, signals[signal])

/datum/component/attachment/Destroy(force)
	REMOVE_TRAIT(parent, TRAIT_ATTACHABLE, "attachable")
	if(actions && length(actions))
		var/obj/item/gun/G = src.parent
		if(G.actions)
			G.actions -= actions
		QDEL_LIST(actions)
	qdel(attachment_toggle_action)
	qdel(attachment_ammo_action)
	return ..()

/datum/component/attachment/proc/try_toggle(obj/item/parent, obj/item/holder, mob/user)
	SIGNAL_HANDLER
	if(attach_features_flags & ATTACH_TOGGLE)
		INVOKE_ASYNC(src, PROC_REF(do_toggle), parent, holder, user)
		holder.update_appearance()
		attachment_toggle_action.build_all_button_icons()

/datum/component/attachment/proc/do_toggle(obj/item/parent, obj/item/holder, mob/user)
	if(on_toggle)
		on_toggle.Invoke(holder, user)
		return TRUE

	parent.attack_self(user)
	return TRUE

/datum/component/attachment/proc/try_ammo(obj/item/parent, obj/item/holder, mob/user)
	SIGNAL_HANDLER
	if(attach_features_flags & ATTACH_AMMOMODE)
		INVOKE_ASYNC(src, PROC_REF(do_ammo), parent, holder, user)
		holder.update_appearance()
		attachment_ammo_action.build_all_button_icons()

/datum/component/attachment/proc/do_ammo(obj/item/parent, obj/item/holder, mob/user)
	if(on_toggle_ammo)
		on_toggle_ammo.Invoke(holder, user)
		return TRUE
	return TRUE

/datum/component/attachment/proc/update_overlays(obj/item/attachment/parent, list/overlays, list/offset)
	if(!(attach_features_flags & ATTACH_NO_SPRITE))
		var/overlay_layer = FLOAT_LAYER
		var/overlay_plane = FLOAT_PLANE
		if(parent.render_layer)
			overlay_layer = parent.render_layer
		if(parent.render_plane)
			overlay_plane = parent.render_plane
		// [HORIZON-FIX] This codebase's mutable_appearance() signature is
		// (icon, icon_state, layer, atom/offset_spokesman, plane, ...) - it
		// has an offset_spokesman argument BEFORE plane (Shiptest's does
		// not). Passing the plane positionally sent FLOAT_PLANE (-32767)
		// into offset_spokesman and spammed the
		// "Why did you pass in offset_spokesman as -32767?" runtime on
		// every update_appearance() of a gun with attachments. Pass the
		// plane explicitly, with the attachment item as the plane-offset
		// context atom when the plane is actually set.
		var/mutable_appearance/overlay
		if(overlay_plane != FLOAT_PLANE)
			overlay = mutable_appearance(parent.icon, "[parent.icon_state]-attached", overlay_layer, parent, overlay_plane)
		else
			overlay = mutable_appearance(parent.icon, "[parent.icon_state]-attached", overlay_layer)
		overlays += overlay

/datum/component/attachment/proc/try_attach(obj/item/parent, obj/item/holder, mob/user, bypass_checks)
	SIGNAL_HANDLER

	if(!bypass_checks)
		// Reject if the gun we're attaching to is not a valid parent type.
		// (is_type_in_list covers subtypes; the old `in` check was exact-match
		// only and inverted, so it silently rejected every valid gun.)
		if(!parent.Adjacent(user) || (length(valid_parent_types) && !is_type_in_list(holder, valid_parent_types)))
			return FALSE

	if(on_attach && !on_attach.Invoke(holder, user))
		return FALSE

	parent.forceMove(holder)

	// Register the toggle/ammo action buttons through upstream's item action
	// system so they are tracked, granted on equip and cleaned up properly.
	if(attach_features_flags & ATTACH_TOGGLE)
		holder.add_item_action(attachment_toggle_action)
		attachment_toggle_action.gun = holder
		attachment_toggle_action.Grant(user)
	if(attach_features_flags & ATTACH_AMMOMODE)
		holder.add_item_action(attachment_ammo_action)
		attachment_ammo_action.gun = holder
		attachment_ammo_action.Grant(user)

	return TRUE

/datum/component/attachment/proc/try_detach(obj/item/parent, obj/item/holder, mob/user)
	SIGNAL_HANDLER

	if(!parent.Adjacent(user) || (length(valid_parent_types) && !is_type_in_list(holder, valid_parent_types)))
		return FALSE

	// on_detach, NOT on_attach (old typo made the detach callback depend on
	// the attach callback being set).
	if(on_detach && !on_detach.Invoke(holder, user))
		return FALSE

	if(attach_features_flags & ATTACH_TOGGLE)
		// Remove from the gun's action list without qdel()ing it - the action
		// datum is reused if the attachment is re-attached later.
		// [HORIZON-FIX] also drop the COMSIG_QDELETING listener that
		// add_item_action() registered, mirroring remove_item_action()
		// without the qdel - otherwise re-attaching warned about the
		// signal being overridden.
		holder.UnregisterSignal(attachment_toggle_action, COMSIG_QDELETING)
		LAZYREMOVE(holder.actions, attachment_toggle_action)
		attachment_toggle_action.gun = null
		attachment_toggle_action.Remove(user)

	if(attach_features_flags & ATTACH_AMMOMODE)
		holder.UnregisterSignal(attachment_ammo_action, COMSIG_QDELETING)
		LAZYREMOVE(holder.actions, attachment_ammo_action)
		attachment_ammo_action.gun = null
		attachment_ammo_action.Remove(user)

	if(user && user.can_put_in_hand(parent))
		user.put_in_hand(parent)
		return TRUE
	else
		parent.forceMove(holder.drop_location())
	return TRUE

/datum/component/attachment/proc/handle_examine(obj/item/parent, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(on_examine)
		on_examine.Invoke(parent, user, examine_list)

/datum/component/attachment/proc/try_fire_gun(obj/item/parent, obj/item/gun/parent_gun, mob/user, atom/target, flag, params)
	SIGNAL_HANDLER

	if(on_fire_gun)
		return on_fire_gun.Invoke(parent_gun, user, target, flag, params)

/datum/component/attachment/proc/relay_pre_attack(obj/item/parent, obj/item/gun, atom/target_atom, mob/user, params)
	SIGNAL_HANDLER

	if(on_preattack)
		return on_preattack.Invoke(gun, target_atom, user, params)

/datum/component/attachment/proc/relay_attacked(obj/item/parent, obj/item/gun, obj/item, mob/user, params)
	SIGNAL_HANDLER

	if(on_attacked)
		return on_attacked.Invoke(gun, user, item)

/datum/component/attachment/proc/try_wield(obj/item/parent, obj/item/gun, mob/user, params)
	SIGNAL_HANDLER

	if(on_wield)
		return on_wield.Invoke(gun, user, params)

/datum/component/attachment/proc/try_unwield(obj/item/parent, obj/item/gun, mob/user, params)
	SIGNAL_HANDLER

	if(on_unwield)
		return on_unwield.Invoke(gun, user, params)

/datum/component/attachment/proc/relay_ctrl_click(obj/item/parent, obj/item/gun, mob/user, params)
	SIGNAL_HANDLER

	if(on_ctrl_click)
		return on_ctrl_click.Invoke(gun, user, params)

/datum/component/attachment/proc/relay_alt_click(obj/item/parent, obj/item/gun, mob/user, params)
	SIGNAL_HANDLER

	if(on_alt_click)
		return on_alt_click.Invoke(gun, user, params)

/datum/component/attachment/proc/relay_attack_hand(obj/item/parent, obj/item/gun, mob/user, params)
	SIGNAL_HANDLER

	if(on_attack_hand)
		return on_attack_hand.Invoke(gun, user, params)

/datum/component/attachment/proc/send_slot(obj/item/parent)
	SIGNAL_HANDLER
	return attachment_slot_to_bflag(slot)

/datum/component/attachment/proc/change_slot(obj/item/parent, new_slot)
	SIGNAL_HANDLER
	slot = new_slot
	return

/datum/action/attachment
	name = "Generic Attachment Action"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	button_icon_state = null
	///Decides where we send our toggle signal for when pressed
	var/obj/item/gun/gun = null

/datum/action/attachment/New(Target)
	..()
	name = name
	button_icon = target:icon
	button_icon_state = target:icon_state

/datum/action/attachment/Destroy()
	. = ..()
	gun = null

/datum/action/attachment/build_all_button_icons()
	button_icon = target:icon
	button_icon_state = target:icon_state
	..()

/datum/action/attachment/toggle
	name = "Toggle Attachment"

/datum/action/attachment/toggle/New(Target)
	. = ..()
	name = "Toggle [target:name]"

/datum/action/attachment/toggle/Trigger(mob/clicker, trigger_flags)
	// Signature must match upstream Trigger(mob/clicker, trigger_flags):
	// action_button.dm calls it with the trigger_flags keyword argument.
	if(!..())
		return FALSE
	SEND_SIGNAL(target, COMSIG_ATTACHMENT_TOGGLE, gun, owner)
	return TRUE

/datum/action/attachment/toggle/build_all_button_icons()
	button_icon = target:icon
	button_icon_state = target:icon_state
	..()

/datum/action/attachment/ammo
	name = "Toggle Energy Mode"

/datum/action/attachment/ammo/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return FALSE
	SEND_SIGNAL(target, COMSIG_ATTACHMENT_TOGGLE_AMMO, gun, owner)
	return TRUE
