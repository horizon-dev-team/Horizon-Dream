/datum/log_viewer
	var/mob/target_mob
	var/datum/persistent_client/target_pc
	var/target_ckey_stored
	var/filter_text = ""
	var/target_filter = ""
	var/zone_filter = ""
	var/source_type = LOGSRC_CKEY
	var/viewing_type = INDIVIDUAL_SHOW_ALL_LOG
	var/list/cached_ckeys
	var/last_ckey_cache = 0

/datum/log_viewer/New(mob/target)
	if(target)
		target_mob = target
		target_ckey_stored = target.ckey
		if(target.persistent_client)
			target_pc = target.persistent_client
		else if(target_ckey_stored)
			target_pc = GLOB.persistent_clients_by_ckey[target_ckey_stored]

/datum/log_viewer/Destroy()
	target_mob = null
	target_pc = null
	SStgui.close_uis(src)
	return ..()

/datum/log_viewer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LogViewer", "Log Viewer")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/log_viewer/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/log_viewer/ui_close(mob/user)
	qdel(src)

/datum/log_viewer/ui_static_data(mob/user)
	. = list()
	.["log_types"] = list(
		list("name" = "Attack",   "flag" = INDIVIDUAL_ATTACK_LOG, "color" = "#ff6b6b"),
		list("name" = "Say",      "flag" = INDIVIDUAL_SAY_LOG,    "color" = "#4dd0e1"),
		list("name" = "Emote",    "flag" = INDIVIDUAL_EMOTE_LOG,  "color" = "#64b5f6"),
		list("name" = "Comms",    "flag" = INDIVIDUAL_COMMS_LOG,  "color" = "#90a4ae"),
		list("name" = "OOC",      "flag" = INDIVIDUAL_OOC_LOG,    "color" = "#5b9bd5"),
		list("name" = "Game",     "flag" = INDIVIDUAL_GAME_LOG,   "color" = "#66bb6a"),
		list("name" = "Show All", "flag" = INDIVIDUAL_SHOW_ALL_LOG, "color" = "#aaaaaa"),
	)
	.["source_options"] = list(LOGSRC_CKEY, LOGSRC_MOB)

/datum/log_viewer/ui_data(mob/user)
	. = list()

	var/pname = target_mob?.real_name
	if(!pname && target_pc?.client?.mob?.real_name)
		pname = target_pc.client.mob.real_name
	if(!pname)
		pname = "None"
	.["target_name"] = pname

	var/pckey = target_mob?.ckey
	if(!pckey)
		pckey = target_ckey_stored
	.["target_ckey"] = pckey
	.["source_type"] = source_type
	.["filter_text"] = filter_text
	.["target_filter"] = target_filter
	.["zone_filter"] = zone_filter
	.["viewing_type"] = viewing_type
	.["ckeys_list"] = get_all_logged_ckeys()

	var/list/log_source
	if(target_mob)
		log_source = target_mob.logging
		if(source_type == LOGSRC_CKEY && target_mob.persistent_client)
			log_source = target_mob.persistent_client.logging
	else if(target_ckey_stored && source_type == LOGSRC_CKEY && target_pc)
		log_source = target_pc.logging

	if(!log_source)
		.["logs"] = list()
		return

	var/find_lower = filter_text ? LOWER_TEXT(filter_text) : null
	var/target_lower = target_filter ? LOWER_TEXT(target_filter) : null
	var/zone_lower = zone_filter ? LOWER_TEXT(zone_filter) : null

	var/list/log_entries = list()
	for(var/log_type_key in log_source)
		var/nlog_type = text2num(log_type_key)
		if(!(nlog_type & viewing_type))
			continue

		var/list/entries = log_source[log_type_key]
		if(!length(entries))
			continue

		for(var/list/entry_assoc in entries)
			if(!islist(entry_assoc))
				continue
			if(find_lower)
				var/what_text = strip_html(entry_assoc["what"])
				var/who_text = entry_assoc["who"] ? entry_assoc["who"] : ""
				var/where_text = entry_assoc["where"] ? entry_assoc["where"] : ""
				var/found = findtext(LOWER_TEXT(what_text), find_lower) || findtext(LOWER_TEXT(who_text), find_lower) || findtext(LOWER_TEXT(where_text), find_lower)
				if(!found)
					continue
			if(target_lower)
				var/entry_who = entry_assoc["who"] ? entry_assoc["who"] : ""
				var/entry_target_name = entry_assoc["target_name"] ? entry_assoc["target_name"] : ""
				var/entry_target_key = entry_assoc["target_key"] ? entry_assoc["target_key"] : ""
				if(!findtext(LOWER_TEXT(entry_who), target_lower) && !findtext(LOWER_TEXT(entry_target_name), target_lower) && !findtext(LOWER_TEXT(entry_target_key), target_lower))
					continue
			if(zone_lower)
				var/entry_where = entry_assoc["where"] ? entry_assoc["where"] : ""
				var/paren_pos = findtext(entry_where, " (")
				if(paren_pos)
					entry_where = copytext(entry_where, 1, paren_pos)
				if(!findtext(LOWER_TEXT(entry_where), zone_lower))
					continue
			log_entries += list(entry_assoc)

	.["logs"] = log_entries

/datum/log_viewer/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("select_ckey")
			var/selected_ckey = params["ckey"]
			var/datum/persistent_client/PC = selected_ckey ? GLOB.persistent_clients_by_ckey[selected_ckey] : null
			if(!PC)
				return FALSE
			target_ckey_stored = selected_ckey
			target_pc = PC
			target_mob = PC.mob
			return TRUE

		if("set_source")
			source_type = params["source"]
			return TRUE

		if("set_viewing_type")
			viewing_type = text2num(params["type"])
			return TRUE

		if("set_filter")
			var/raw = params["text"]
			filter_text = raw ? raw : ""
			return TRUE

		if("set_target_filter")
			var/raw = params["text"]
			target_filter = raw ? raw : ""
			return TRUE

		if("set_zone_filter")
			var/raw = params["text"]
			zone_filter = raw ? raw : ""
			return TRUE

		if("refresh")
			return TRUE

		if("open_pp")
			if(target_mob)
				SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/options_panel, target_mob)
			return TRUE

/// Build the ckey dropdown. Cached for 5 seconds (50 ticks) so opening
/// the dropdown doesn't iterate every persistent_client on every render.
/datum/log_viewer/proc/get_all_logged_ckeys()
	if(cached_ckeys && last_ckey_cache + 50 > world.time)
		return cached_ckeys
	var/list/ckeys = list()
	for(var/ckey in GLOB.persistent_clients_by_ckey)
		var/datum/persistent_client/PC = GLOB.persistent_clients_by_ckey[ckey]
		if(length(PC.logging))
			ckeys.Add(ckey)
	cached_ckeys = ckeys
	last_ckey_cache = world.time
	return ckeys

ADMIN_VERB(open_log_viewer, R_ADMIN, "A: Open Log Viewer", "Open the individual log viewer (per-player structured logs).", ADMIN_CATEGORY_GAME)
	var/datum/log_viewer/LV = new()
	LV.ui_interact(usr)
