/**
 * Attachment side of the gun attachment system. Lives on an item that can be
 * fitted to a gun carrying /datum/component/attachment_mount.
 *
 * This is a base class: a concrete attachment is a subtype that overrides the
 * config vars below and, when it needs behaviour, the on_* procs. The item
 * itself stays thin, see /obj/item/attachment.
 *
 * HOW TO ADD AN ATTACHMENT
 * 1. Subtype this component and set slot / feature_flags / overlay_* as needed.
 * 2. Declare stat_modifiers for plain stat changes (applied while installed and,
 *    for ATTACH_TOGGLE attachments, switched on; reverted automatically).
 * 3. Override on_attached / on_detached / on_toggled / get_attach_error for
 *    anything else, and set hook_flags + the matching on_* hook proc to react to
 *    firing, wielding and clicks.
 * 4. Subtype /obj/item/attachment and point attachment_component_type at it.
 *
 * Everything is called directly by the mount, so there are no signals to
 * register or keep in sync here.
 */
/datum/component/gun_attachment
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Slot the attachment goes on. Also used in player facing text.
	var/slot = ATTACHMENT_SLOT_RAIL
	/// Slots the player may cycle this attachment between in hand. Null means a fixed slot.
	var/list/slot_choices = null
	/// ATTACH_* flags, see _DEFINES/attachments.dm.
	var/feature_flags = ATTACH_REMOVABLE_HAND
	/// ATTACH_HOOK_* flags for the optional hooks this attachment implements.
	var/hook_flags = NONE
	/// Gun types this attachment fits. Empty means any gun.
	var/list/valid_parent_types = list(/obj/item/gun)
	/// Slots that have to stay empty while this attachment is installed (mutual exclusion).
	/// Works in both directions: it can't be fitted over an occupied excluded slot, and
	/// nothing can be fitted into an excluded slot afterwards.
	var/list/excluded_slots = null
	/// Assoc list of gun var name -> additive delta, applied while the attachment is installed
	/// and enabled, and reverted exactly when it is removed or switched off.
	var/list/stat_modifiers = null

	/// Layer of the overlay drawn on the gun.
	var/overlay_layer = FLOAT_LAYER
	/// Plane of the overlay drawn on the gun.
	var/overlay_plane = FLOAT_PLANE
	/// Pixel offset of the overlay sprite, matched against the gun's slot_offsets.
	var/overlay_shift_x = 16
	var/overlay_shift_y = 16

	/// Whether a toggle attachment is currently switched on. Always FALSE for non-toggle ones.
	var/active = FALSE
	/// The mount this attachment is installed in. Null while it is loose.
	var/datum/component/attachment_mount/mount
	/// Toggle button on the gun, only exists while installed and ATTACH_TOGGLE.
	var/datum/action/item_action/attachment_toggle/toggle_action
	/// The deltas currently applied to the gun, so they are reverted exactly.
	var/list/applied_modifiers

/datum/component/gun_attachment/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/gun_attachment/Destroy(force)
	// Deleted while installed (admin delete, acid, ...): let the gun tidy up after us.
	if(mount)
		mount.attachment_deleted(src)
	mount = null
	QDEL_NULL(toggle_action)
	applied_modifiers = null
	return ..()

/// Whether this attachment's effects are currently in force.
/datum/component/gun_attachment/proc/is_enabled()
	return !(feature_flags & ATTACH_TOGGLE) || active

/// Changes the slot this attachment uses. Only possible while it is loose.
/datum/component/gun_attachment/proc/set_slot(new_slot)
	if(mount)
		return FALSE
	slot = new_slot
	return TRUE

/// Switches to the next entry of slot_choices. Only possible while it is loose.
/datum/component/gun_attachment/proc/cycle_slot(mob/user)
	if(mount || length(slot_choices) < 2)
		return FALSE
	var/index = slot_choices.Find(slot)
	slot = slot_choices[(index % length(slot_choices)) + 1]
	return TRUE

// =============================================================================
// ATTACH / DETACH
// =============================================================================

/**
 * Returns a player readable reason why this attachment can't be fitted to the gun,
 * or null when it can. Slot room, type whitelist and exclusion are checked by the
 * mount; override this for conditions that are specific to the attachment.
 */
/datum/component/gun_attachment/proc/get_attach_error(obj/item/gun/gun, mob/user)
	if(length(valid_parent_types) && !is_type_in_list(gun, valid_parent_types))
		return "[parent] doesn't fit [gun]!"
	return null

/**
 * Called by the mount right after the attachment was installed in the gun.
 * Overrides must call the parent.
 */
/datum/component/gun_attachment/proc/on_attached(obj/item/gun/gun, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_attachment_moved))
	if(feature_flags & ATTACH_TOGGLE)
		toggle_action = new /datum/action/item_action/attachment_toggle(parent)
		toggle_action.attachment = src
		toggle_action.name = "Toggle [parent]"
		gun.add_item_action(toggle_action)
		if(!toggle_action.owner && user?.is_holding(gun))
			toggle_action.Grant(user)
	if(is_enabled())
		apply_modifiers(gun)
	refresh_item_appearance()

/**
 * Called by the mount right before the attachment leaves the gun (or while it is
 * being deleted). The gun is still reachable through mount at this point.
 * Overrides must call the parent.
 */
/datum/component/gun_attachment/proc/on_detached(obj/item/gun/gun, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	if(active)
		set_active(FALSE, user, TRUE)
	revert_modifiers(gun)
	if(toggle_action)
		// Also unregisters the gun's listener and qdel()s the action, which removes it from its owner.
		gun.remove_item_action(toggle_action)
		toggle_action = null
	refresh_item_appearance()

/// Moving an installed item out by another mechanism must also undo its effects.
/datum/component/gun_attachment/proc/on_attachment_moved(obj/item/source)
	SIGNAL_HANDLER
	if(mount && source.loc != mount.parent)
		mount.attachment_deleted(src)

/// Redraws the attachment item itself, its icon state follows the active state. Safe while it is being deleted.
/datum/component/gun_attachment/proc/refresh_item_appearance()
	var/obj/item/attachment_item = parent
	if(!QDELETED(attachment_item))
		attachment_item.update_appearance()

// =============================================================================
// TOGGLING
// =============================================================================

/**
 * Returns a player readable reason why this attachment can't be toggled right now,
 * or null when it can. Override for attachment specific conditions.
 */
/datum/component/gun_attachment/proc/get_toggle_error(obj/item/gun/gun, mob/user)
	return null

/// Player facing toggle, used by the action button and the radial menu.
/datum/component/gun_attachment/proc/toggle(mob/user)
	if(!mount || !(feature_flags & ATTACH_TOGGLE))
		return FALSE
	if(!mount.can_interact(user))
		return FALSE
	var/obj/item/gun/gun = mount.parent
	var/error = get_toggle_error(gun, user)
	if(error)
		if(user)
			to_chat(user, span_warning(error))
		return FALSE
	return set_active(!active, user)

/// Switches the attachment on or off, keeping stat modifiers and visuals in step.
/datum/component/gun_attachment/proc/set_active(new_state, mob/user, silent = FALSE)
	if(!mount)
		return FALSE
	new_state = !!new_state
	if(new_state == active)
		return TRUE
	var/obj/item/gun/gun = mount.parent
	active = new_state
	if(active)
		apply_modifiers(gun)
	else
		revert_modifiers(gun)
	on_toggled(gun, user, silent)
	refresh_item_appearance()
	if(!QDELETED(gun))
		gun.update_appearance()
	toggle_action?.build_all_button_icons()
	return TRUE

/// Called after active changed. Use it for sounds, messages and effects the stat modifiers can't express.
/datum/component/gun_attachment/proc/on_toggled(obj/item/gun/gun, mob/user, silent)
	return

// =============================================================================
// STAT MODIFIERS
// =============================================================================

/// Applies stat_modifiers to the gun. Does nothing if they are already applied.
/datum/component/gun_attachment/proc/apply_modifiers(obj/item/gun/gun)
	if(applied_modifiers || !length(stat_modifiers))
		return
	applied_modifiers = list()
	for(var/stat_name in stat_modifiers)
		if(!(stat_name in gun.vars))
			stack_trace("[type] tried to modify unknown gun var [stat_name]")
			continue
		gun.vars[stat_name] += stat_modifiers[stat_name]
		applied_modifiers[stat_name] = stat_modifiers[stat_name]

/// Reverts exactly what apply_modifiers() applied.
/datum/component/gun_attachment/proc/revert_modifiers(obj/item/gun/gun)
	if(!applied_modifiers)
		return
	for(var/stat_name in applied_modifiers)
		gun.vars[stat_name] -= applied_modifiers[stat_name]
	applied_modifiers = null

// =============================================================================
// APPEARANCE
// =============================================================================

/// Returns the overlay to draw on the gun, or null for none. The mount positions it.
/datum/component/gun_attachment/proc/get_overlay()
	if(feature_flags & ATTACH_NO_SPRITE)
		return null
	var/obj/item/attachment_item = parent
	var/overlay_state = "[attachment_item.icon_state]-attached"
	// [HORIZON-FIX] This codebase's mutable_appearance() takes an offset_spokesman
	// argument BEFORE plane (Shiptest's does not). Passing the plane positionally
	// sent FLOAT_PLANE (-32767) into offset_spokesman and spammed a runtime on every
	// update_appearance() of a gun with attachments. Only pass a plane when it is
	// really set, with the attachment item as the plane-offset context atom.
	if(overlay_plane != FLOAT_PLANE)
		return mutable_appearance(attachment_item.icon, overlay_state, overlay_layer, attachment_item, overlay_plane)
	return mutable_appearance(attachment_item.icon, overlay_state, overlay_layer)

// =============================================================================
// OPTIONAL HOOKS
// Only called while the matching ATTACH_HOOK_* flag is set in hook_flags.
// =============================================================================

/// Examining the gun. Always called, add your own lines to examine_list.
/datum/component/gun_attachment/proc/on_examine(mob/user, list/examine_list)
	return

/// The gun is about to fire. Return TRUE to cancel the shot.
/datum/component/gun_attachment/proc/on_try_fire(obj/item/gun/gun, mob/user, atom/target, flag, params)
	return FALSE

/// The gun is about to be wielded. Return TRUE to block it.
/datum/component/gun_attachment/proc/on_wield(obj/item/gun/gun, mob/user)
	return FALSE

/// The gun was unwielded.
/datum/component/gun_attachment/proc/on_unwield(obj/item/gun/gun, mob/user)
	return

/// The gun was right-click used on something. Return TRUE to cancel the attack chain.
/datum/component/gun_attachment/proc/on_pre_attack_secondary(obj/item/gun/gun, atom/target, mob/user, list/modifiers)
	return FALSE

/// The gun was right-clicked with an empty hand. Return TRUE to cancel the attack chain.
/datum/component/gun_attachment/proc/on_attack_hand_secondary(obj/item/gun/gun, mob/user, list/modifiers)
	return FALSE

/// The gun was right-clicked with an item. Return TRUE to cancel the attack chain.
/datum/component/gun_attachment/proc/on_attackby_secondary(obj/item/gun/gun, obj/item/weapon, mob/user, list/modifiers)
	return FALSE

/// The gun was ctrl-clicked. Return TRUE if the click was handled.
/datum/component/gun_attachment/proc/on_ctrl_click(obj/item/gun/gun, mob/user)
	return FALSE

// =============================================================================
// TOGGLE BUTTON
// =============================================================================

/// Action button for toggling an installed attachment. Its target is the attachment item,
/// so the button takes the attachment's icon, but it is granted to whoever holds the gun.
/datum/action/item_action/attachment_toggle
	name = "Toggle Attachment"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	/// The attachment this button controls.
	var/datum/component/gun_attachment/attachment

/datum/action/item_action/attachment_toggle/Destroy()
	attachment = null
	return ..()

/datum/action/item_action/attachment_toggle/do_effect(trigger_flags)
	if(!attachment)
		return FALSE
	attachment.toggle(owner)
	return TRUE
