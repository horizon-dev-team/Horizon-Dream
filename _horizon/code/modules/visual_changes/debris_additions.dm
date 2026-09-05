/obj/structure/flora/rock/icy/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5)

/obj/structure/flora/rock/pile/jungle/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_LEAF, -10, 5)

/obj/structure/flora/rock/pile/icy/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5)

/obj/structure/flora/rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -10, 5, 1)

/obj/structure/barricade/wooden/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/closet/cabinet/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/closet/crate/large/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/flora/tree/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/fermenting_barrel/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/barricade/wooden/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/chair/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/mineral_door/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/table/woodentable/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/table/fancywoodentable/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/bookcase/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/table_frame/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/table/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/window/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_GLASS, -10, 5)

/obj/structure/girder/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -10, 8, 1)

/obj/machinery/power/shuttle_engine/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -10, 8, 1)

// MARK: WALLS
/turf/closed/Initialize(mapload)
	. = ..()
	add_debris_element()

/turf/closed/mineral/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -10, 5, 1)

/turf/closed/mineral/random/snow/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/ice/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/ice_rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/mineral/random/labormineral/ice/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5)

/turf/closed/wall/resin/add_debris_element()
	AddElement(/datum/element/debris, null, -15, 8, 0.7)

/turf/closed/wall/mineral/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/turf/closed/wall/mineral/bamboo/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/turf/closed/wall/mineral/snow/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5)

/turf/closed/wall/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/turf/closed/wall/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

// MARK: FALSE WALLS
/obj/structure/falsewall/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/falsewall/bamboo/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)
