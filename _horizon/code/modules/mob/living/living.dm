/mob
	plane = MOB_PLANE

/mob/living/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/directional_attack)


/mob/living/carbon
	// ~WEIGHT SYSTEM
	/// Maximum weight we can carry, this point and beyond means maximum encumbrance
	var/maximum_carry_weight = 72
	/// Weight we are currently carrying
	var/carry_weight = 0
	/// State of encumbrance we are in, cheaper to store this than keeping calling update_carry_weight()
	var/encumbrance = ENCUMBRANCE_NONE

/obj/item
	/**
	 * This is used to calculate encumbrance on human mobs.
	 *
	 * LEAVING THIS AS NULL WILL CALCULATE A NEW CARRY_WEIGHT BASED ON W_CLASS ON INITIALIZE()
	 */
	var/carry_weight = null
