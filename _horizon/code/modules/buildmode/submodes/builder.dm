/**
 * Builder mode - modern build mode with TGUI item browser,
 * category selection, pixel positioning, and item placement.
 *
 * This mode replaces the old basic mode as the default.
 * It provides a full item browser via TGUI, category tabs,
 * search, pixel-precise placement, and more.
 */

/datum/buildmode_mode/builder
	key = "panel"

/datum/buildmode_mode/builder/enter_mode(datum/buildmode/BM)
	BM.current_category = BM_CATEGORY_TURF
	BM.open_item_browser()

/datum/buildmode_mode/builder/exit_mode(datum/buildmode/BM)
	BM.close_item_browser()

/datum/buildmode_mode/builder/show_help(client/builder)
	to_chat(builder, span_purple(boxed_message(
		"Builder Mode - Use the item browser to select items.\n\
		[span_bold("Place objects")] -> Left Mouse Button on turf/obj\n\
		[span_bold("Copy object type")] -> Left Mouse Button + Alt on turf/obj\n\
		[span_bold("Clear selection")] -> Right Mouse Button\n\
		[span_bold("Delete objects")] -> Right Mouse Button + Alt"))
	)

/datum/buildmode_mode/builder/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)
	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/alt_click = LAZYACCESS(modifiers, ALT_CLICK)

	if(left_click && alt_click)
		if(istype(object, /turf) || isobj(object) || istype(object, /mob))
			to_chat(c, span_notice("[initial(object.name)] ([object.type]) selected."))
			BM.select_item(object.type)
		else
			to_chat(c, span_notice("Can only copy turf, object, or mob."))
		return TRUE

	if(right_click && alt_click)
		if(isobj(object))
			log_admin("Build Mode: [key_name(c)] deleted [object] at [AREACOORD(object)]")
			qdel(object)
		return TRUE

	if(BM.selected_item)
		if(left_click)
			var/turf = get_turf(object)
			log_admin("Build Mode: [key_name(c)] modified [turf] in [AREACOORD(object)] to [object.type]")
			BM.place_object(turf, c, modifiers)
			return TRUE
		if(right_click)
			BM.clear_selection()
			return TRUE
	return ..()
