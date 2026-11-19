// horizon-dev-sync[bot] port
// Item side of the weight / encumbrance system. See _horizon/code/modules/mob/living/carry_weight.dm.

/// Returns the weight (in kilograms) this item contributes to a mob's encumbrance.
/// Derives a default from w_class when carry_weight is null. The result is NOT cached
/// into carry_weight, so a w_class change (update_weight_class) is picked up right away.
/// Liquid reagents use REAGENT_UNIT_KG (100u = 1 kg). Storage contents are scaled by
/// storage_weight_multiplier. Loose contents (magazines, cells, rounds) are counted too.
/obj/item/proc/get_carry_weight(list/seen)
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
	for(var/obj/item/contained in contents)
		if(contained.item_flags & ABSTRACT)
			continue
		. += contained.get_carry_weight(seen)

/// Total carry weight of items inside this storage datum, after the container's relief.
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
