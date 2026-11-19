// horizon-dev-sync[bot] port
// Item side of the weight / encumbrance system. See _horizon/code/modules/mob/living/carry_weight.dm.

/// Returns the weight (in kilograms) this item contributes to a mob's encumbrance.
/// Derives a default from w_class when carry_weight is null. The result is NOT cached
/// into carry_weight, so a w_class change (update_weight_class) is picked up right away.
/// Reagents and storage contents are counted too.
/obj/item/proc/get_carry_weight()
	var/weight = carry_weight
	if(isnull(weight))
		weight = weight_class_to_kg(w_class)
	. = weight
	if(reagents?.total_volume)
		. += reagents.total_volume * REAGENT_UNIT_KG
	if(atom_storage)
		. += atom_storage.get_carry_weight()

/// Total carry weight of items inside this storage datum.
/datum/storage/proc/get_carry_weight()
	. = 0
	var/atom/location = real_location
	if(!location)
		return
	for(var/obj/item/stored in location.contents)
		. += stored.get_carry_weight()
