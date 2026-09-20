// MARK: OBJECT
/obj/Initialize(mapload)
	. = ..()
	add_debris_element()

/obj/structure/flora/rock/icy/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5)

/obj/structure/flora/rock/pile/icy/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5)

/obj/structure/window/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_GLASS, -10, 5)

/obj/structure/flora/rock/pile/jungle/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_LEAF, -10, 5)

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

/obj/structure/ore_box/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/fermenting_barrel/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/dresser/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/frame/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -10, 5)

/obj/structure/girder/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -10, 8, 1)

/obj/machinery/power/shuttle_engine/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -10, 8, 1)

/obj/structure/grille/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -10, 5)

// Airlock and Door
/obj/machinery/door/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

/obj/machinery/door/window/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_GLASS, -10, 5)

/obj/structure/door_assembly/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

/obj/machinery/door/airlock/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/door_assembly/door_assembly_wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

// MARK: WALLS
/turf/closed/Initialize(mapload)
	. = ..()
	add_debris_element()

/turf/closed/wall/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

/turf/closed/mineral/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -10, 5, 1)

/turf/closed/mineral/snowmountain/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/mineral/iron/ice/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/mineral/gibtonite/ice/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/mineral/random/snow/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/ice/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/ice_rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

/turf/closed/mineral/random/labormineral/ice/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5)

/turf/closed/wall/mineral/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/turf/closed/wall/mineral/bamboo/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/turf/closed/wall/mineral/snow/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5)

/turf/closed/wall/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

// MARK: FALSE WALLS
/obj/structure/falsewall/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

/obj/structure/falsewall/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/falsewall/bamboo/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)
