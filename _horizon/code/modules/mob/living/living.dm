
/mob
	plane = MOB_PLANE
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS

/mob/living/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/directional_attack)
