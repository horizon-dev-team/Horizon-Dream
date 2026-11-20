/**
 * TGUI item browser datum for buildmode.
 * Acts as the TUI host for the BuildMode interface.
 */
/datum/tgui_item_browser
	var/datum/buildmode/owner
	var/ui_open = FALSE

/datum/tgui_item_browser/New(datum/buildmode/bm)
	. = ..()
	owner = bm

/datum/tgui_item_browser/Destroy()
	owner = null
	return ..()

/datum/tgui_item_browser/proc/open(mob/user)
	if(!owner || !owner.holder)
		return
	owner.ui_interact(user)
	ui_open = TRUE

/datum/tgui_item_browser/proc/close()
	ui_open = FALSE
	SStgui.close_uis(owner)

/**
 * TGUI procs delegated to /datum/buildmode
 */
/datum/buildmode/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BuildMode")
		ui.open()

/datum/buildmode/ui_close(mob/user)
	. = ..()
	if(item_browser)
		item_browser.ui_open = FALSE

/datum/buildmode/ui_state(mob/user)
	return ADMIN_STATE(R_BUILD)

/datum/buildmode/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/buildmode),
	)

/**
 * Static data sent once when the UI opens.
 * Contains all categories with their items (path, name, icon sprite name).
 */
/datum/buildmode/ui_static_data(mob/user)
	var/list/data = ..()

	var/list/categories = list()
	for(var/list/category in GLOB.buildmode_items)
		var/list/category_items = list()
		for(var/list/item in category["items"])
			category_items += list(list(
				"path" = "[item["path"]]",
				"name" = item["name"],
				"icon" = item["icon"],
			))
		categories += list(list(
			"id" = category["id"],
			"name" = category["name"],
			"items" = category_items,
		))
	data["categories"] = categories

	return data

/**
 * Build the data payload for TGUI.
 * Returns the current category, selected item, pixel mode, and build dir.
 */
/datum/buildmode/ui_data(mob/user)
	var/data = list()
	data["current_category"] = current_category || BM_CATEGORY_TURF
	data["selected_item"] = selected_item ? "[selected_item]" : null
	data["pixel_positioning"] = pixel_positioning_mode
	data["build_dir"] = build_dir

	return data

/**
 * Handle TGUI actions
 */
/datum/buildmode/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("select_category")
			var/new_category = params["category"]
			if(new_category)
				change_category(new_category)
				return TRUE

		if("select_item")
			var/path = text2path(params["path"])
			if(ispath(path))
				select_item(path)
				return TRUE

		if("toggle_pixel")
			toggle_pixel_positioning_mode(!pixel_positioning_mode)
			return TRUE

		if("clear_selection")
			clear_selection()
			return TRUE

	return FALSE
