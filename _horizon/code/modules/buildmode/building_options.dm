/**
 * Change the current category
 *
 * @param {int} new_category - The new category to select
 */
/datum/buildmode/proc/change_category(new_category)
	current_category = new_category
	SStgui.update_uis(src)

/**
 * Place an object at the specified location
 *
 * @param {turf} location - Where to place the object
 * @param {mob} user - Who is placing the object
 * @param {string} params - Click parameters
 */
/datum/buildmode/proc/place_object(turf/location, mob/user, list/modifiers)
	if(!selected_item || !location)
		return

	var/path = selected_item

	if(ispath(path, /turf))
		var/turf/T = location
		T.ChangeTurf(path)
		log_admin("[key_name(user)] placed [path] at [AREACOORD(location)]")
	else
		var/atom/A = new path(location)
		if(build_dir)
			A.setDir(build_dir)
		A.pixel_x = A.base_pixel_x + pixel_x_offset
		A.pixel_y = A.base_pixel_y + pixel_y_offset
		log_admin("[key_name(user)] placed [path] at [AREACOORD(location)]")

/**
 * Simplified item selection proc
 */
/datum/buildmode/proc/select_item(atom/item_path)
	if(!ispath(item_path))
		return
	selected_item = item_path
	create_preview_appearance(item_path)
	to_chat(holder.mob, span_notice("Selected [initial(item_path.name)] for building."))

/**
 * Clear the current item selection
 */
/datum/buildmode/proc/clear_selection()
	selected_item = null
	clear_preview()
	to_chat(holder.mob, "<span class='notice'>Selection cleared.</span>")
