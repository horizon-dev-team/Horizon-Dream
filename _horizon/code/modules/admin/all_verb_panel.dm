ADMIN_VERB(show_all_verbs, R_NONE, "All Verb Panel 📋", "Show all verbs.", ADMIN_CATEGORY_MAIN)
	user.show_all_verbs()

/client
	/// Last Admin Verbs used
	var/list/last_verbs_used = list()

	/// Literally Admin Verbs Menu
	var/datum/admin_menu/admin_menu

/client/proc/show_all_verbs()
	if(!holder)
		return

	admin_menu = new(usr)
	admin_menu.ui_interact(usr)

/datum/admin_menu
	var/client/holder
	var/compact_mode = FALSE

/datum/admin_menu/New(user)
	if (istype(user, /client))
		var/client/user_client = user
		holder = user_client
	else
		var/mob/user_mob = user
		holder = user_mob.client

/datum/admin_menu/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/admin_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AllVerbPanel")
		ui.open()

/datum/admin_menu/ui_data(mob/user)
	var/list/data = list()
	data["compactMode"] = compact_mode
	return data

/datum/admin_menu/ui_static_data(mob/user)
	var/list/temp_data = list()
	for(var/procpath/cur_verb as anything in holder.verbs)
		if(!cur_verb.category)
			continue
		if(!temp_data[cur_verb.category])
			temp_data[cur_verb.category] = list()
		temp_data[cur_verb.category] += list(list("verb" = "[cur_verb]", "name" = cur_verb.name, "desc" = cur_verb.desc))

	var/list/tgui_data = list()
	for(var/category in temp_data)
		var/list/cat = list(
			"name" = category,
			"items" = temp_data[category])
		tgui_data["categories"] += list(cat)

	LAZYADDASSOCLIST(tgui_data, "categories", list("name" = "История", "items" = reverseList(holder.last_verbs_used)))
	return tgui_data

/datum/admin_menu/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("compact_toggle")
			compact_mode = !compact_mode
			return TRUE

	if(!check_rights(R_ADMIN) || action != "run")
		return

	INVOKE_ASYNC(holder, text2path(params["verb"]))
	LAZYADD(holder.last_verbs_used, list(list("verb" = params["verb"], "name" = params["name"], "desc" = params["desc"])))
	SStgui.close_uis(usr)
