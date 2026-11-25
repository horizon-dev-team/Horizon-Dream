/obj/item
	/// Organ storage component requires this
	var/atom/stored_in
	/// Used for unturning when picked up by a mob (do_messy/undo_messy)
	var/our_angle = 0

/obj/item/proc/get_carry_weight(list/seen)
	if(item_flags & ABSTRACT)
		return 0
	if(seen && (src in seen))
		return 0
	if(!seen)
		seen = list()
	seen += src
	var/weight = carry_weight
	if(isnull(weight))
		weight = weight_class_to_kg(w_class)
	. = weight
	if(reagents?.total_volume && reagent_weight_factor)
		. += reagents.total_volume * REAGENT_UNIT_KG * reagent_weight_factor
	if(atom_storage)
		. += atom_storage.get_carry_weight(seen)
		return .
	// Loose contents (magazine, cell, MODsuit parts and modules) get the same relief as storage contents.
	var/contained_weight = 0
	for(var/obj/item/contained in contents)
		contained_weight += contained.get_carry_weight(seen)
	. += contained_weight * storage_weight_multiplier

/datum/storage/proc/get_carry_weight(list/seen)
	. = 0
	var/atom/location = real_location
	if(!location)
		return
	for(var/obj/item/stored in location.contents)
		. += stored.get_carry_weight(seen)
	var/obj/item/container = parent
	if(istype(container))
		. *= container.storage_weight_multiplier

/// Kilograms one unit of this stack adds to a mob's encumbrance. Null (default)
/// keeps the flat w_class-derived mass regardless of the stack size.
/obj/item/stack
	var/carry_weight_per_unit = null

/obj/item/stack/get_carry_weight(list/seen)
	if(isnull(carry_weight_per_unit))
		return ..()
	if(seen && (src in seen))
		return 0
	if(!seen)
		seen = list()
	seen += src
	return carry_weight_per_unit * amount

/obj/item/ammo_box/get_carry_weight(list/seen)
	. = ..(seen)
	for(var/obj/item/ammo_casing/casing as anything in stored_ammo)
		if(!ispath(casing))
			continue
		var/w = initial(casing.carry_weight)
		if(isnull(w))
			w = weight_class_to_kg(initial(casing.w_class))
		. += w

/// Cool drop / throw effect: randomises pixel offset and rotation a bit
/// so dropped items look less stiff. Ported from legacy
/// modular_septic/code/game/objects/items.dm.
/obj/item/proc/do_messy(pixel_variation = 8, angle_variation = 360, duration = 0)
	if(item_flags & NO_ANGLE_RANDOM_DROP)
		return
	animate(src, pixel_x = (base_pixel_x + rand(-pixel_variation, pixel_variation)), duration)
	animate(src, pixel_y = (base_pixel_y + rand(-pixel_variation, pixel_variation)), duration)
	if(our_angle)
		animate(src, transform = transform.Turn(-our_angle), duration)
		our_angle = 0
	our_angle = rand(0, angle_variation)
	transform = transform.Turn(our_angle)

/// Undo the do_messy() pixel/rotation offsets.
/obj/item/proc/undo_messy(duration = 0)
	animate(src, pixel_x = base_pixel_x, duration)
	animate(src, pixel_y = base_pixel_y, duration)
	if(our_angle)
		animate(src, transform = transform.Turn(-our_angle), duration)
		our_angle = 0
