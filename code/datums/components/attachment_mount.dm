/**
 * Mount side of the gun attachment system. Lives on a gun and owns the attachments
 * installed on it: slot room, mutual exclusion, installing and removing, overlays,
 * examine text and the player interactions (click to attach, alt-click or crowbar
 * to remove, ctrl-shift-click for the toggle radial).
 *
 * It talks to attachments through direct proc calls on /datum/component/gun_attachment.
 * The only signals involved are engine ones on the gun, and the optional ones
 * (firing, wielding, secondary clicks...) are registered lazily: only while an
 * installed attachment asked for the matching ATTACH_HOOK_* flag.
 *
 * The mount is created once by /obj/item/gun/Initialize and is not meant to be
 * removed from a living gun.
 */
/datum/component/attachment_mount
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Typecache of the item types this mount accepts.
	var/list/valid_types
	/// The accepted item types exactly as the gun listed them, used for examine text.
	var/list/valid_type_list
	/// Assoc list of slot -> how many attachments fit in that slot.
	var/list/slot_capacity
	/// Assoc list of slot -> list("x" = n, "y" = n) pixel offsets for that slot's overlay.
	var/list/slot_offsets
	/// Attachment components currently installed on the gun.
	var/list/datum/component/gun_attachment/installed
	/// ATTACH_HOOK_* flags whose engine signals are currently registered on the gun.
	var/registered_hooks = NONE
	/// Set once the gun is going away, so deleting attachments doesn't tidy up a dying gun.
	var/tearing_down = FALSE

	/// Every optional hook, for syncing signal registration.
	var/static/list/all_hooks = list(
		ATTACH_HOOK_FIRE,
		ATTACH_HOOK_WIELD,
		ATTACH_HOOK_UNWIELD,
		ATTACH_HOOK_PRE_ATTACK_SECONDARY,
		ATTACH_HOOK_ATTACK_HAND_SECONDARY,
		ATTACH_HOOK_ATTACKBY_SECONDARY,
		ATTACH_HOOK_CTRL_CLICK,
	)

/datum/component/attachment_mount/Initialize(list/slot_capacity = null, list/valid_types = null, list/slot_offsets = null, list/default_attachments = null)
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE

	src.slot_capacity = slot_capacity?.Copy()
	src.valid_type_list = valid_types?.Copy()
	src.valid_types = typecacheof(valid_types)
	src.slot_offsets = slot_offsets

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_attackby))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(handle_examine))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(handle_examine_more))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(handle_overlays))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(handle_alt_click))
	RegisterSignal(parent, COMSIG_CLICK_CTRL_SHIFT, PROC_REF(handle_ctrl_shift_click))

	for(var/attachment_type in default_attachments)
		var/obj/item/new_attachment = new attachment_type(parent)
		if(!try_attach(new_attachment))
			stack_trace("[parent.type] could not install its default attachment [attachment_type]")
			qdel(new_attachment)

/datum/component/attachment_mount/Destroy(force)
	tearing_down = TRUE
	var/list/leftovers = installed?.Copy()
	installed = null
	for(var/datum/component/gun_attachment/attachment as anything in leftovers)
		attachment.mount = null
		if(!QDELETED(attachment.parent))
			qdel(attachment.parent)
	slot_offsets = null
	return ..()

// =============================================================================
// QUERIES
// =============================================================================

/// Returns the gun-attachment component of an item. Attachment items that have not
/// finished initializing yet (default attachments) get theirs created on the spot.
/datum/component/attachment_mount/proc/get_attachment_component(obj/item/item)
	if(istype(item, /obj/item/attachment))
		var/obj/item/attachment/attachment_item = item
		return attachment_item.get_attachment_component()
	return item.GetComponent(/datum/component/gun_attachment)

/// All installed attachments that use the given slot.
/datum/component/attachment_mount/proc/get_attachments_in_slot(slot)
	. = list()
	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if(attachment.slot == slot)
			. += attachment

/// How many more attachments the given slot can take.
/datum/component/attachment_mount/proc/get_slot_room(slot)
	var/capacity = LAZYACCESS(slot_capacity, slot)
	return capacity - length(get_attachments_in_slot(slot))

/// The installed attachment that excludes the given slot, if any.
/datum/component/attachment_mount/proc/get_slot_blocked_by(slot)
	for(var/datum/component/gun_attachment/other as anything in installed)
		if(slot in other.excluded_slots)
			return other
	return null

/// The installed attachment that stops the given one from being fitted, if any:
/// either something excludes its slot, or it excludes a slot that is occupied.
/datum/component/attachment_mount/proc/get_exclusion_conflict(datum/component/gun_attachment/attachment)
	var/datum/component/gun_attachment/blocker = get_slot_blocked_by(attachment.slot)
	if(blocker)
		return blocker
	for(var/excluded_slot in attachment.excluded_slots)
		var/list/occupants = get_attachments_in_slot(excluded_slot)
		if(length(occupants))
			return occupants[1]
	return null

/**
 * Returns a player readable reason why the attachment can't be installed,
 * or null when it can.
 */
/datum/component/attachment_mount/proc/get_attach_error(datum/component/gun_attachment/attachment, mob/user)
	var/obj/item/gun/gun = parent
	var/obj/item/attachment_item = attachment.parent
	if(!is_type_in_typecache(attachment_item, valid_types))
		return "[attachment_item] is not a valid attachment for [gun]!"
	var/slot = attachment.slot
	if(LAZYACCESS(slot_capacity, slot) <= 0)
		return "[gun] has no [slot] slot for [attachment_item]!"
	if(get_slot_room(slot) <= 0)
		var/list/occupants = get_attachments_in_slot(slot)
		var/datum/component/gun_attachment/occupant = occupants[1]
		return "The [slot] slot of [gun] is already occupied by [occupant.parent]!"
	var/datum/component/gun_attachment/conflict = get_exclusion_conflict(attachment)
	if(conflict)
		return "[attachment_item] can't be fitted to [gun] while [conflict.parent] is installed!"
	return attachment.get_attach_error(gun, user)

// =============================================================================
// INSTALLING AND REMOVING
// =============================================================================

/// Installs an attachment item into the gun. Returns TRUE on success, and tells the user why on failure.
/datum/component/attachment_mount/proc/try_attach(obj/item/attachment_item, mob/user)
	var/datum/component/gun_attachment/attachment = get_attachment_component(attachment_item)
	if(!attachment || attachment.mount || QDELETED(attachment_item))
		return FALSE
	var/obj/item/gun/gun = parent
	var/error = get_attach_error(attachment, user)
	if(error)
		if(user)
			to_chat(user, span_warning(error))
		return FALSE
	if(attachment_item.loc != gun)
		if(user?.is_holding(attachment_item))
			if(!user.transferItemToLoc(attachment_item, gun))
				to_chat(user, span_warning("You can't let go of [attachment_item]!"))
				return FALSE
		else
			attachment_item.forceMove(gun)
	LAZYADD(installed, attachment)
	attachment.mount = src
	attachment.on_attached(gun, user)
	sync_hooks()
	gun.update_appearance()
	if(user)
		to_chat(user, span_notice("You attach [attachment_item] to [gun]."))
	return TRUE

/// Takes an installed attachment off the gun and hands it to the user, or drops it.
/datum/component/attachment_mount/proc/try_detach(datum/component/gun_attachment/attachment, mob/user)
	if(!(attachment in installed))
		return FALSE
	var/obj/item/gun/gun = parent
	var/obj/item/attachment_item = attachment.parent
	release(attachment, user)
	if(user)
		to_chat(user, span_notice("You remove [attachment_item] from [gun]."))
		// Falls back to dropping the item on the floor when the user's hands are full.
		user.put_in_hands(attachment_item)
	else
		attachment_item.forceMove(gun.drop_location())
	return TRUE

/// Unlinks an installed attachment from this mount without moving the item.
/datum/component/attachment_mount/proc/release(datum/component/gun_attachment/attachment, mob/user)
	var/obj/item/gun/gun = parent
	attachment.on_detached(gun, user)
	LAZYREMOVE(installed, attachment)
	attachment.mount = null
	sync_hooks()
	gun.update_appearance()

/// Called by an installed attachment's component while it is being deleted.
/datum/component/attachment_mount/proc/attachment_deleted(datum/component/gun_attachment/attachment)
	if(tearing_down || !(attachment in installed))
		attachment.mount = null
		return
	release(attachment, null)

// =============================================================================
// LAZY HOOK SIGNALS
// =============================================================================

/// Registers or unregisters the engine signals so that exactly the hooks wanted by installed attachments are listened to.
/datum/component/attachment_mount/proc/sync_hooks()
	var/wanted = NONE
	for(var/datum/component/gun_attachment/attachment as anything in installed)
		wanted |= attachment.hook_flags
	var/changed = wanted ^ registered_hooks
	if(!changed)
		return
	for(var/hook_flag in all_hooks)
		if(changed & hook_flag)
			set_hook_registered(hook_flag, !!(wanted & hook_flag))
	registered_hooks = wanted

/datum/component/attachment_mount/proc/set_hook_registered(hook_flag, registered)
	switch(hook_flag)
		if(ATTACH_HOOK_FIRE)
			if(registered)
				RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, PROC_REF(handle_try_fire))
			else
				UnregisterSignal(parent, COMSIG_GUN_TRY_FIRE)
		if(ATTACH_HOOK_WIELD)
			if(registered)
				RegisterSignal(parent, COMSIG_TWOHANDED_WIELD, PROC_REF(handle_wield))
			else
				UnregisterSignal(parent, COMSIG_TWOHANDED_WIELD)
		if(ATTACH_HOOK_UNWIELD)
			if(registered)
				RegisterSignal(parent, COMSIG_TWOHANDED_UNWIELD, PROC_REF(handle_unwield))
			else
				UnregisterSignal(parent, COMSIG_TWOHANDED_UNWIELD)
		if(ATTACH_HOOK_PRE_ATTACK_SECONDARY)
			if(registered)
				RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(handle_pre_attack_secondary))
			else
				UnregisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY)
		if(ATTACH_HOOK_ATTACK_HAND_SECONDARY)
			if(registered)
				RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(handle_attack_hand_secondary))
			else
				UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY)
		if(ATTACH_HOOK_ATTACKBY_SECONDARY)
			if(registered)
				RegisterSignal(parent, COMSIG_ATOM_ATTACKBY_SECONDARY, PROC_REF(handle_attackby_secondary))
			else
				UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY_SECONDARY)
		if(ATTACH_HOOK_CTRL_CLICK)
			if(registered)
				RegisterSignal(parent, COMSIG_CLICK_CTRL, PROC_REF(handle_ctrl_click))
			else
				UnregisterSignal(parent, COMSIG_CLICK_CTRL)

/datum/component/attachment_mount/proc/handle_try_fire(obj/item/gun/source, mob/user, atom/target, flag, params)
	SIGNAL_HANDLER

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if((attachment.hook_flags & ATTACH_HOOK_FIRE) && attachment.on_try_fire(source, user, target, flag, params))
			return COMPONENT_CANCEL_GUN_FIRE

/datum/component/attachment_mount/proc/handle_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if((attachment.hook_flags & ATTACH_HOOK_WIELD) && attachment.on_wield(source, user))
			return COMPONENT_TWOHANDED_BLOCK_WIELD

/datum/component/attachment_mount/proc/handle_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if(attachment.hook_flags & ATTACH_HOOK_UNWIELD)
			attachment.on_unwield(source, user)

/datum/component/attachment_mount/proc/handle_pre_attack_secondary(obj/item/source, atom/target, mob/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if((attachment.hook_flags & ATTACH_HOOK_PRE_ATTACK_SECONDARY) && attachment.on_pre_attack_secondary(source, target, user, modifiers))
			return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/attachment_mount/proc/handle_attack_hand_secondary(atom/source, mob/user, list/modifiers)
	SIGNAL_HANDLER

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if((attachment.hook_flags & ATTACH_HOOK_ATTACK_HAND_SECONDARY) && attachment.on_attack_hand_secondary(source, user, modifiers))
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/attachment_mount/proc/handle_attackby_secondary(obj/item/source, obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if((attachment.hook_flags & ATTACH_HOOK_ATTACKBY_SECONDARY) && attachment.on_attackby_secondary(source, weapon, user, modifiers))
			source.update_appearance()
			return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/attachment_mount/proc/handle_ctrl_click(atom/source, mob/user)
	SIGNAL_HANDLER

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if((attachment.hook_flags & ATTACH_HOOK_CTRL_CLICK) && attachment.on_ctrl_click(source, user))
			return CLICK_ACTION_SUCCESS

// =============================================================================
// PLAYER INTERACTIONS
// =============================================================================

/datum/component/attachment_mount/proc/handle_attackby(obj/item/source, obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if(!user.Adjacent(source))
		return NONE

	if(attacking_item.tool_behaviour == TOOL_CROWBAR && length(installed))
		INVOKE_ASYNC(src, PROC_REF(start_detach), user, attacking_item)
		return COMPONENT_NO_AFTERATTACK

	if(attacking_item.GetComponent(/datum/component/gun_attachment))
		INVOKE_ASYNC(src, PROC_REF(try_attach), attacking_item, user)
		return COMPONENT_NO_AFTERATTACK

	return NONE

/datum/component/attachment_mount/proc/handle_alt_click(atom/source, mob/user)
	SIGNAL_HANDLER

	if(!length(installed))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(start_detach), user, null)
	return CLICK_ACTION_SUCCESS

/datum/component/attachment_mount/proc/handle_ctrl_shift_click(atom/source, mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(start_toggle_radial), user)

/// Asks the user which attachment to remove, then removes it after a delay.
/// With a tool only tool-removable attachments are offered, without one only hand-removable ones.
/datum/component/attachment_mount/proc/start_detach(mob/user, obj/item/tool)
	var/obj/item/gun/gun = parent
	var/required_flag = tool ? ATTACH_REMOVABLE_TOOL : ATTACH_REMOVABLE_HAND
	var/list/choices = list()
	var/list/lookup = list()
	var/list/used_keys = list()
	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if(!(attachment.feature_flags & required_flag))
			continue
		var/key = avoid_assoc_duplicate_keys("[attachment.parent]", used_keys)
		choices += key
		lookup[key] = attachment
	if(!length(lookup))
		to_chat(user, span_warning(tool ? "None of the attachments on [gun] can be pried off with [tool]." : "None of the attachments on [gun] can be removed by hand."))
		return

	var/selected = tgui_input_list(user, "Select an attachment to remove.", "Detach", choices)
	if(!selected)
		return
	var/datum/component/gun_attachment/attachment = lookup[selected]
	if(!attachment || attachment.mount != src || !user.Adjacent(gun))
		return
	if(tool)
		if(!tool.use_tool(gun, user, ATTACHMENT_DETACH_TIME * tool.toolspeed))
			return
	else if(!do_after(user, ATTACHMENT_DETACH_TIME, gun))
		return
	// The attachment may have been removed or deleted while we waited.
	if(attachment.mount != src)
		return
	try_detach(attachment, user)

/// Radial menu of the toggleable attachments.
/datum/component/attachment_mount/proc/start_toggle_radial(mob/user)
	var/obj/item/gun/gun = parent
	var/list/choices = list()
	var/list/lookup = list()
	var/list/used_keys = list()
	for(var/datum/component/gun_attachment/attachment as anything in installed)
		if(!(attachment.feature_flags & ATTACH_TOGGLE))
			continue
		var/key = avoid_assoc_duplicate_keys("[attachment.parent]", used_keys)
		choices[key] = attachment.parent
		lookup[key] = attachment
	if(!length(choices))
		return

	var/selection = show_radial_menu(user, gun, choices)
	if(!selection)
		return
	var/datum/component/gun_attachment/selected = lookup[selection]
	if(!selected || selected.mount != src)
		return
	selected.toggle(user)

// =============================================================================
// EXAMINE AND APPEARANCE
// =============================================================================

/datum/component/attachment_mount/proc/handle_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(length(installed))
		var/list/names = list()
		var/has_toggle = FALSE
		for(var/datum/component/gun_attachment/attachment as anything in installed)
			names += "[attachment.parent]"
			if(attachment.feature_flags & ATTACH_TOGGLE)
				has_toggle = TRUE
		examine_list += span_notice("It has [english_list(names)] attached.")
		examine_list += span_notice("You can remove attachments by <b>alt-clicking</b> [source], or by prying them off with a crowbar.")
		if(has_toggle)
			examine_list += span_notice("You can toggle attachments by <b>ctrl-shift-clicking</b> [source].")
	else
		examine_list += span_notice("It has no attachments. You can attach items by clicking [source] with them.")

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		attachment.on_examine(user, examine_list)

/datum/component/attachment_mount/proc/handle_examine_more(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("<b>Attachment slots:</b>")
	for(var/slot in slot_capacity)
		var/datum/component/gun_attachment/blocker = get_slot_blocked_by(slot)
		if(blocker)
			examine_list += span_notice("\t[slot]: blocked by [blocker.parent]")
			continue
		var/list/names = list()
		for(var/datum/component/gun_attachment/attachment as anything in get_attachments_in_slot(slot))
			names += "[attachment.parent]"
		var/free_room = get_slot_room(slot)
		if(!length(names))
			examine_list += span_notice("\t[slot]: empty ([free_room] slot\s free)")
		else if(free_room > 0)
			examine_list += span_notice("\t[slot]: [english_list(names)] ([free_room] slot\s free)")
		else
			examine_list += span_notice("\t[slot]: [english_list(names)] (full)")

	if(length(valid_type_list))
		if(valid_type_list.Find(/obj/item/attachment))
			examine_list += span_notice("It accepts any attachment.")
		else
			examine_list += span_notice("It can accept:")
			for(var/obj/attach_type as anything in valid_type_list)
				examine_list += span_notice("\t- [initial(attach_type.name)]")

/datum/component/attachment_mount/proc/handle_overlays(atom/source, list/new_overlays)
	SIGNAL_HANDLER

	for(var/datum/component/gun_attachment/attachment as anything in installed)
		var/mutable_appearance/overlay = attachment.get_overlay()
		if(!overlay)
			continue
		var/list/offset = LAZYACCESS(slot_offsets, attachment.slot)
		if(offset)
			var/matrix/overlay_matrix = new
			overlay_matrix.Translate(offset["x"] - attachment.overlay_shift_x, offset["y"] - attachment.overlay_shift_y)
			overlay.transform = overlay_matrix
		new_overlays += overlay
