/obj/item/gun/ballistic/proc/guncleaning(mob/user, obj/item/cleaning_cloth)
	var/original_misfire_value = initial(misfire_probability)
	if(misfire_probability <= original_misfire_value)
		to_chat(user, span_notice("[src] seems to be already clean of fouling."))
		return

	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_notice("[user] begins cleaning [src]."), span_notice("You begin to clean the internals of [src]."))

	if(!do_after(user, 10 SECONDS, target = src))
		return
	misfire_probability = original_misfire_value
	user.visible_message(span_notice("[user] cleans [src] of any fouling."), span_notice("You clean [src], removing any fouling, preventing misfire."))
	return TRUE
