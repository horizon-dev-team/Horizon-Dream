/obj/item/gun/ballistic/proc/pre_item_interaction(datum/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if((bolt_type == BOLT_TYPE_BREAK_ACTION) && !cylinder_open && (isammocasing(tool) || istype(tool, /obj/item/ammo_box)))
		balloon_alert(user, "[cylinder_wording] is closed!")
		return ITEM_INTERACT_BLOCKING
	if(!never_misfire && istype(tool, /obj/item/stack/sheet/cloth))
		if(guncleaning(user, tool))
			return ITEM_INTERACT_SUCCESS
	return NONE
