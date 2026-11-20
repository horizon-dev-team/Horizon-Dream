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
