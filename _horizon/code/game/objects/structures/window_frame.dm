/obj/structure/window/framed
	name = "framed window"
	desc = "A glass window with a rod matrix inside a wall frame. It looks rather strong. Might take a few good hits to shatter it."
	icon = '_horizon/icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "wall"
	plane = ABOVE_WALL_PLANE
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	reinf = TRUE
	heat_resistance = 1600
	max_integrity = 150
	damage_deflection = 11
	explosion_block = 1
	state = RWINDOW_SECURE
	armor_type = /datum/armor/window_reinforced
	glass_type = /obj/item/stack/sheet/rglass
	glass_amount = 2
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/iron = SHEET_MATERIAL_AMOUNT)
	/// The frame left in the opening whenever the glass goes.
	var/window_frame = /obj/structure/window_frame

/// The glass is bolted into the frame for good - it only ever comes out the hard way.
/obj/structure/window/framed/screwdriver_act(mob/living/user, obj/item/tool)
	to_chat(user, span_warning("[src] is bolted into its frame. It cannot be moved."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/framed/wrench_act(mob/living/user, obj/item/tool)
	to_chat(user, span_warning("[src] is bolted into its frame. It cannot be moved."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/framed/crowbar_act(mob/living/user, obj/item/tool)
	to_chat(user, span_warning("[src] is bolted into its frame. It cannot be moved."))
	return ITEM_INTERACT_SUCCESS

/// Any way the glass goes, the frame stays behind.
/obj/structure/window/framed/atom_deconstruct(disassembled = TRUE)
	if(window_frame)
		new window_frame(loc)
		window_frame = null
	return ..()

/*
 * The frame: a hole in the wall that used to sport a large window.
 */
/obj/structure/window_frame
	name = "window frame"
	desc = "A big hole in the wall that used to sport a large window. Can be vaulted through."
	icon = '_horizon/icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "wall"
	plane = ABOVE_WALL_PLANE
	layer = ABOVE_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW
	can_atmos_pass = ATMOS_PASS_YES
	max_integrity = 600
	armor_type = /datum/armor/structure_window
	smoothing_flags = SMOOTH_CONNECTOR
	smoothing_groups = null
	canSmoothWith = null
	var/special_icon = TRUE
	var/list/wall_connections = list("0", "0", "0", "0")
	var/list/blend_turfs = list(/turf/closed)
	var/list/noblend_turfs = list(/turf/closed/mineral)
	var/list/blend_objects = list(/obj/structure/window/reinforced/fulltile, /obj/structure/window/framed, /obj/structure/window_frame, /obj/machinery/door)
	var/list/noblend_objects = list()
	/// The window built back into the frame once it is fed glass.
	var/window_type = /obj/structure/window/framed
	/// The sheets the window is rebuilt from, and how many it takes.
	var/glass_type = /obj/item/stack/sheet/rglass
	var/glass_amount = 2

/obj/structure/window_frame/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)

/obj/structure/window_frame/Destroy()
	set_density(FALSE)
	air_update_turf(TRUE, FALSE)
	return ..()

/// Two fresh sheets build the window back in; the frame hands its tile over.
/obj/structure/window_frame/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, glass_type))
		return NONE
	var/obj/item/stack/sheets = tool
	if(sheets.get_amount() < glass_amount)
		balloon_alert(user, "need [glass_amount] sheets!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "installing window...")
	add_fingerprint(user)
	if(!tool.use_tool(src, user, 2 SECONDS, glass_amount))
		return ITEM_INTERACT_BLOCKING
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	balloon_alert(user, "window installed")
	new window_type(loc)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// The frame itself comes apart into metal.
/obj/structure/window_frame/wrench_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "deconstructing frame...")
	if(!tool.use_tool(src, user, 3 SECONDS, volume = 75))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "frame deconstructed")
	deconstruct()
	return ITEM_INTERACT_SUCCESS

/obj/structure/window_frame/atom_deconstruct(disassembled = TRUE)
	if(disassembled)
		new /obj/item/stack/sheet/iron(drop_location(), 2)
	else
		var/remains = pick(/obj/item/stack/rods, /obj/item/stack/sheet/iron)
		new remains(drop_location())
