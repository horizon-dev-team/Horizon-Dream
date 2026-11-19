/mob
	plane = MOB_PLANE

/mob/living/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/directional_attack)


/mob/living/carbon
	// ~WEIGHT SYSTEM
	/// Maximum weight we can carry, this point and beyond means maximum encumbrance. Recalculated from get_basic_lift().
	var/maximum_carry_weight = ENCUMBRANCE_DEFAULT_BASIC_LIFT * ENCUMBRANCE_MAXIMUM_PER_LIFT
	/// Weight we are currently carrying
	var/carry_weight = 0
	/// State of encumbrance we are in, cheaper to store this than keeping calling update_carry_weight()
	var/encumbrance = ENCUMBRANCE_NONE

/obj/item
	/**
	 * Mass in kilograms this item contributes to a mob's encumbrance.
	 *
	 * LEAVING THIS AS NULL DERIVES A DEFAULT FROM W_CLASS EVERY TIME get_carry_weight() IS CALLED. See carry_weight.dm.
	 */
	var/carry_weight = null
