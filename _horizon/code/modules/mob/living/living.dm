/mob
	plane = MOB_PLANE

/mob/living/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/directional_attack)
