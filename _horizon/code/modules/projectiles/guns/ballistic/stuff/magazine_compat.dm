/obj/item/gun/ballistic/Initialize(mapload)
	if(spawn_magazine_type && accepted_magazine_type == initial(accepted_magazine_type))
		accepted_magazine_type = spawn_magazine_type
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(pre_item_interaction))
	if(!spawn_magazine_type)
		spawn_magazine_type = accepted_magazine_type
	if(!spawnwithmagazine)
		bolt_locked = TRUE
		update_appearance()
		return
	if(!magazine)
		magazine = new spawn_magazine_type(src)
		if(!istype(magazine, accepted_magazine_type))
			CRASH("[src] spawned with a magazine type that isn't allowed by its accepted_magazine_type!")
	if(bolt_type == BOLT_TYPE_STANDARD || internal_magazine)
		chamber_round()
	else
		chamber_round(replace_new_round = TRUE)
	if(spawn_sawn_off)
		do_sawoff()
	update_appearance()
	RegisterSignal(src, COMSIG_ITEM_RECHARGED, PROC_REF(instant_reload))

/obj/item/gun/ballistic/proc/pre_item_interaction(datum/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if((bolt_type == BOLT_TYPE_BREAK_ACTION) && !cylinder_open && (isammocasing(tool) || istype(tool, /obj/item/ammo_box)))
		balloon_alert(user, "[cylinder_wording] is closed!")
		return ITEM_INTERACT_BLOCKING
	if(!never_misfire && istype(tool, /obj/item/stack/sheet/cloth))
		if(guncleaning(user, tool))
			return ITEM_INTERACT_SUCCESS
	return NONE
