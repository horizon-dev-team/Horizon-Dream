/turf/closed/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	abstract_type = /turf/closed/wall/mineral
	blend_turfs = list(/turf/closed/wall/mineral)
	noblend_turfs = list()
	rcd_memory = null
	material_flags = MATERIAL_EFFECTS
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	sheet_type = /obj/item/stack/sheet/mineral/gold
	hardness = 65 //gold is soft
	explosive_resistance = 0 //gold is a soft metal you dingus.
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	sheet_type = /obj/item/stack/sheet/mineral/silver
	hardness = 65 //silver is also soft according to moh's scale
	custom_materials = list(/datum/material/silver = SHEET_MATERIAL_AMOUNT*2)

/turf/closed/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = "diamond_wall-0"
	base_icon_state = "diamond_wall"
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	hardness = 5 //diamond is very hard
	slicing_duration = 200   //diamond wall takes twice as much time to slice
	explosive_resistance = 3
	custom_materials = list(/datum/material/diamond = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/closed/wall/mineral/diamond/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 41)
	return ..()

/turf/closed/wall/mineral/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	hardness = 70 //it's banana
	custom_materials = list(/datum/material/bananium = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Rough."
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	hardness = 50 //moh says this is apparently 6-7 on it's scale
	explosive_resistance = 0
	custom_materials = list(/datum/material/sandstone = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/uranium
	article = "a"
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	hardness = 40 //uranium is a 6 on moh's scale
	custom_materials = list(/datum/material/uranium = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_REINFORCED

	/// Mutex to prevent infinite recursion when propagating radiation pulses
	var/active = null

	/// The last time a radiation pulse was performed
	var/last_event = 0

/turf/closed/wall/mineral/uranium/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_PROPAGATE_RAD_PULSE, PROC_REF(radiate))

/turf/closed/wall/mineral/uranium/proc/radiate()
	SIGNAL_HANDLER
	if(active)
		return
	if(world.time <= last_event + 1.5 SECONDS)
		return
	active = TRUE
	radiation_pulse(
		src,
		max_range = 3,
		threshold = RAD_LIGHT_INSULATION,
		chance = URANIUM_IRRADIATION_CHANCE,
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)
	propagate_radiation_pulse()
	last_event = world.time
	active = FALSE

/turf/closed/wall/mineral/uranium/attack_hand(mob/user, list/modifiers)
	radiate()
	return ..()

/turf/closed/wall/mineral/uranium/attackby(obj/item/W, mob/user, list/modifiers)
	radiate()
	return ..()

/turf/closed/wall/mineral/uranium/Bumped(atom/movable/AM)
	radiate()
	return ..()

/turf/closed/wall/mineral/uranium/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 41)
	return ..()

/turf/closed/wall/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	hardness = 70 // I'll tentatively compare it to Bismuth
	thermal_conductivity = 0.04
	custom_materials = list(/datum/material/plasma = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	sheet_type = /obj/item/stack/sheet/mineral/wood
	hardness = 80
	turf_flags = IS_SOLID
	explosive_resistance = 0
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/wood/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!tool.get_sharpness() || !tool.force)
		return ..()

	var/duration = (4.8 SECONDS / tool.force) * 2 //In seconds, for now.
	if(istype(tool, /obj/item/hatchet) || istype(tool, /obj/item/fireaxe))
		duration /= 4 //Much better with hatchets and axes.
	if(!do_after(user, duration * 1 SECONDS, target = src)) //Into deciseconds.
		return ITEM_INTERACT_BLOCKING

	dismantle_wall(FALSE,FALSE)
	return ITEM_INTERACT_SUCCESS

/turf/closed/wall/mineral/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 0)
	return ..() //No recoil damage, wood is weak

/turf/closed/wall/mineral/wood/nonmetal
	desc = "A solidly wooden wall. It's a bit weaker than a wall made with metal."
	girder_type = /obj/structure/barricade/wooden
	hardness = 67 //a bit weaker than iron (60)
	sheet_amount = 5
	make_delay = 5 SECONDS

/turf/closed/wall/mineral/bamboo
	name = "bamboo wall"
	desc = "A wall with a bamboo finish."
	icon = 'icons/turf/walls/bamboo_wall.dmi'
	icon_state = "bamboo_wall-0"
	base_icon_state = "bamboo_wall"
	sheet_type = /obj/item/stack/sheet/mineral/bamboo
	hardness = 80 //it's not a mineral...
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/iron
	name = "rough iron wall"
	desc = "A wall with rough iron plating."
	icon_state = "iron_wall-0"
	base_icon_state = "iron_wall"
	sheet_type = /obj/item/stack/rods
	hardness = 60
	sheet_amount = 5
	custom_materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT * 2.5)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/snow
	name = "packed snow wall"
	desc = "A wall made of densely packed snow blocks."
	icon = 'icons/turf/walls/snow_wall.dmi'
	icon_state = "snow_wall-0"
	base_icon_state = "snow_wall"
	hardness = 80
	explosive_resistance = 0
	slicing_duration = 30
	sheet_type = /obj/item/stack/sheet/mineral/snow
	girder_type = null
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	custom_materials = list(/datum/material/snow = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/mineral/snow/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 0)
	return ..() //No recoil damage, snow is weak

/turf/closed/wall/mineral/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"
	sheet_type = /obj/item/stack/sheet/mineral/abductor
	hardness = 10
	slicing_duration = 200   //alien wall takes twice as much time to slice
	explosive_resistance = 3
	custom_materials = list(/datum/material/alloy/alien = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_ORGANIC

/////////////////////Titanium walls/////////////////////

/turf/closed/wall/mineral/titanium //has to use this path due to how building walls works
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon_state = "wall"
	explosive_resistance = 3
	flags_1 = CAN_BE_DIRTY_1
	flags_ricochet = RICOCHET_SHINY | RICOCHET_HARD
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	hardness = 40 //6 on moh's scale
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/mineral/titanium/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/closed/wall/rust)
		return TRUE
	return ..()

/turf/closed/wall/mineral/titanium/nodiagonal

/turf/closed/wall/mineral/titanium/overspace
	//icon = MAP_SWITCH('icons/turf/walls/shuttle_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
	//icon_state = MAP_SWITCH("shuttle_wall-0", "shuttle_nd")
	//smoothing_flags = SMOOTH_BITMASK

/turf/closed/wall/mineral/titanium/overspace
	//icon = MAP_SWITCH('icons/turf/walls/shuttle_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
	//icon_state = MAP_SWITCH("shuttle_wall-0", "shuttle_overspace")
	//fixed_underlay = list("space" = TRUE)

/turf/closed/wall/mineral/titanium/interior/copyTurf(turf/copy_to_turf, copy_air = FALSE, flags = null)
	. = ..()
	copy_to_turf.transform = transform

/turf/closed/wall/mineral/titanium/copyTurf(turf/copy_to_turf, copy_air = FALSE, flags = null)
	. = ..()
	copy_to_turf.transform = transform

/turf/closed/wall/mineral/titanium/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/closed/wall/rust)
		return TRUE
	return ..()

/////////////////////Plastitanium walls/////////////////////

/turf/closed/wall/mineral/plastitanium
	name = "wall"
	desc = "A durable wall made of an alloy of plasma and titanium."
	explosive_resistance = 4
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	hardness = 25 //upgrade on titanium
	custom_materials = list(/datum/material/alloy/plastitanium = SHEET_MATERIAL_AMOUNT*2)
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/mineral/plastitanium/wall_fill
	sheet_type = /obj/item/stack/wall_filling/plastitanium/basic
	sheet_amount = 1

/turf/closed/wall/mineral/plastitanium/darkpod
	name = "dark pod wall"
	desc = "An easily-compressible wall used for temporary shelter."
	sheet_type = /obj/item/stack/wall_filling/plastitanium/pod
	sheet_amount = 1
	icon = 'icons/turf/walls/dark_pod.dmi'
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/mineral/plastitanium/redpod
	name = "red pod wall"
	desc = "An easily-compressible wall used for temporary shelter."
	sheet_type = /obj/item/stack/wall_filling/plastitanium/redpod
	sheet_amount = 1
	icon = 'icons/turf/walls/red_pod.dmi'
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/mineral/plastitanium/survival
	name = "pod wall"
	desc = "An easily-compressible wall used for temporary shelter."
	sheet_type = /obj/item/stack/wall_filling/plastitanium/survivalpod
	sheet_amount = 1
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/mineral/plastitanium/survival/nodiagonal //Понабирают всяких долбаёбав
/turf/closed/wall/mineral/plastitanium/survival/pod

/turf/closed/wall/mineral/plastitanium/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/closed/wall/rust)
		return TRUE
	return ..()

/turf/closed/wall/mineral/plastitanium/nodiagonal
	icon = MAP_SWITCH('icons/turf/walls/plastitanium_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
	icon_state = MAP_SWITCH("plastitanium_wall-0", "plastitanium_nd")
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/wall/mineral/plastitanium/overspace
	icon = MAP_SWITCH('icons/turf/walls/plastitanium_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
	icon_state = MAP_SWITCH("plastitanium_wall-0", "plastitanium_overspace")
	fixed_underlay = list("space" = TRUE)

/turf/closed/wall/mineral/plastitanium/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/closed/wall/rust)
		return TRUE
	return ..()


/turf/closed/wall/mineral/plastitanium/explosive/ex_act(severity)
	var/obj/item/bombcore/large/bombcore = new(get_turf(src))
	bombcore.detonate()
	return ..()

/turf/closed/wall/mineral/plastitanium/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 41)
	return ..()

/turf/closed/wall/mineral/plastitanium/copyTurf(turf/copy_to_turf, copy_air = FALSE, flags = null)
	. = ..()
	copy_to_turf.transform = transform
