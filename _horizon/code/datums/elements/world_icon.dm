/datum/element/world_icon
	argument_hash_start_idx = 2
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	/// Proc used to update the appearance of the object when in the world
	var/attached_proc
	/// Only used if attached_proc doesn't exist, simply changes the icon of target to this when it's in the inventory
	var/inventory_icon
	/// Only used if attached_proc doesn't exist, simply changes the icon of target to this when it's NOT in the inventory
	var/world_icon

/datum/element/world_icon/Attach(atom/target, attached_proc, inventory_icon, world_icon)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.attached_proc = attached_proc
	src.inventory_icon = inventory_icon
	src.world_icon = world_icon
	RegisterSignal(target, COMSIG_ATOM_UPDATE_ICON, PROC_REF(update_icon))
	// Moved covers entering/leaving a storage item (forceMove), which has no dedicated storage signal.
	RegisterSignals(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_MOVABLE_MOVED, COMSIG_ITEM_DROPPED), PROC_REF(inventory_updated))
	target.update_appearance(UPDATE_ICON)

/datum/element/world_icon/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_ICON)
	UnregisterSignal(source, list(COMSIG_ITEM_EQUIPPED, COMSIG_MOVABLE_MOVED, COMSIG_ITEM_DROPPED))
	source.update_appearance(UPDATE_ICON)

/datum/element/world_icon/proc/update_icon(obj/item/source, updates)
	SIGNAL_HANDLER

	if(world_icon_in_inventory(source))
		if(attached_proc)
			return
		return default_inventory_icon(source)

	if(attached_proc)
		return call(source, attached_proc)(updates)
	else
		return default_world_icon(source)

/// True when the item is held or equipped by a mob, or sits inside a storage item (backpack, box).
/// Items on a turf (dropped out of a backpack, thrown, or spilled) are in the world.
/proc/world_icon_in_inventory(obj/item/source)
	if(source.item_flags & IN_INVENTORY)
		return TRUE
	var/atom/holder = source.loc
	return !isnull(holder) && !isturf(holder) && !isnull(holder.atom_storage)

/datum/element/world_icon/proc/inventory_updated(obj/item/source)
	SIGNAL_HANDLER
	source.update_appearance(UPDATE_ICON)

/datum/element/world_icon/proc/default_inventory_icon(obj/item/source)
	SIGNAL_HANDLER
	source.icon = inventory_icon

/datum/element/world_icon/proc/default_world_icon(obj/item/source)
	SIGNAL_HANDLER
	source.icon = world_icon
