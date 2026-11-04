/datum/player_panel/ //required for tgui component
	var/title = "Player Panel"
	/// Server-side filter text. Matched against ckey, names, job and previous names.
	var/search_text
	/// Seconds between automatic updates. 0 disables auto-update.
	var/update_interval = 5
	/// Ckey the client has selected in the UI. Only used to keep that player visible in a filtered list.
	var/pinned_ckey
	/// When TRUE, list every mob that has (or had) a ckey — including disconnected players and their ghosts
	var/show_all_mobs = FALSE
	COOLDOWN_DECLARE(update_cooldown)

ADMIN_VERB(player_panel, R_ADMIN, "Player Panel", "Updated Player Panel with TGUI. Currently in testing.", ADMIN_CATEGORY_GAME)
	var/datum/player_panel/tgui = new(user.mob)
	tgui.ui_interact(user.mob)
	message_admins("[key_name_admin(user)] has opened VUAP!")
	BLACKBOX_LOG_ADMIN_VERB("VUAP")

ADMIN_VERB_AND_CONTEXT_MENU(options_panel, R_ADMIN, "Open Options Panel", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, /mob)
	VERB_ARG_TYPED(target, VERB_ARG_TYPE_MOB, VERB_ARG_SOURCE_WORLD, /mob)
	if(!target)
		to_chat(user, span_warning("Could not find desired target mob!"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
		return
	if(!length(target.ckey) || target.ckey[1] == "@")
		var/mob/player = target
		var/datum/mind/player_mind = get_mind(player, include_last = TRUE)
		var/player_mind_ckey = ckey(player_mind?.key)
		user.selectedPlayerCkey = player_mind_ckey
		user.VUAP_selected_mob = target
		var/datum/options_panel/tgui = new(user.mob)
		tgui.ui_interact(user.mob)
		tgui_alert(user, "WARNING! This mob has no associated Mind! Most actions will not work. Last ckey to control this mob is [player_mind_ckey].", "No Mind!")
	else
		user.selectedPlayerCkey = target.ckey
		user.VUAP_selected_mob = target
		var/datum/options_panel/tgui = new(user.mob)
		tgui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("OptionsPanel")

/datum/player_panel/proc/player_matches_search(list/player_data)
	var/search_data = "[player_data["name"]] [player_data["real_name"]] [player_data["ckey"]] [player_data["job"]] [player_data["old_name"]]"
	return !!findtext(search_data, search_text)

/datum/player_panel/proc/player_ui_data(mob/player)
#ifndef TESTING
	if(QDELETED(player) || !length(player.ckey))
#else
	if(QDELETED(player) || !player.mind) // if TESTING is enabled, this lets us test with a spawned debug crew
#endif
		return
	var/client/player_client = player.client
	var/turf/player_turf = get_turf(player)
	var/list/data = list(
		"ckey" = player.ckey,
		"name" = player.name,
		"real_name" = player.real_name,
		"job" = player.job,
		"mob_type" = "[player.type]",
		"is_antagonist" = player.is_antag(),
		"has_mind" = !!player.mind,
		"is_cyborg" = iscyborg(player),
		"is_living" = isliving(player),
		"connected" = !!player_client,
		"last_ip" = player.lastKnownIP,
		"position" = player_turf ? AREACOORD(player_turf) : null,
		"ref" = REF(player),
	)
	if(player.persistent_client)
		// Played names are stored html-encoded for the legacy HTML panel, but tgui escapes text on its own.
		var/list/previous_names = list()
		for(var/previous_name in player.persistent_client.played_names)
			previous_names += "[html_decode(previous_name)] ([player.persistent_client.played_names[previous_name]])"
		data["previous_names"] = previous_names
		data["old_name"] = length(previous_names) ? previous_names.Join("; ") : null
	if(ishuman(player))
		var/mob/living/carbon/human/human_player = player
		if(human_player.dna?.species?.name)
			data["species"] = human_player.dna.species.name
		data["oxydam"] = round(human_player.get_oxy_loss(), 1)
		data["toxdam"] = round(human_player.get_tox_loss(), 1)
		data["burndam"] = round(human_player.get_fire_loss(), 1)
		data["brutedam"] = round(human_player.get_brute_loss(), 1)
	else if(isliving(player))
		var/mob/living/living_player = player
		data["health"] = living_player.health
		data["health_max"] = living_player.getMaxHealth()
	if(player_client)
		data["ip"] = player_client.address
		data["cid"] = player_client.computer_id
		data["first_seen"] = player_client.player_join_date
		data["register_date"] = player_client.account_join_date
		data["related_accounts_ip"] = player_client.related_accounts_ip
		data["related_accounts_cid"] = player_client.related_accounts_cid
		if(player_client.byond_version)
			data["byond_version"] = "[player_client.byond_version].[player_client.byond_build || "xxx"]"
		if(CONFIG_GET(flag/use_exp_tracking))
			data["living_playtime"] = round(player_client.get_exp_living(TRUE) / 60, 0.1)
	return data

/datum/player_panel/ui_data(mob/user)
	var/client/user_client = user.client
	var/list/players = list()
	var/list/mob_source = show_all_mobs ? GLOB.mob_list : GLOB.player_list
	for(var/mob/player as anything in mob_source)
		var/list/player_data = player_ui_data(player)
		if(!player_data)
			continue
		// The pinned player is always kept in the payload so the details panel does not lose its data.
		if(length(search_text) && player.ckey != pinned_ckey && !player_matches_search(player_data))
			continue
		players += list(player_data)
	return list(
		"players" = players,
		"search_text" = search_text,
		"update_interval" = update_interval,
		"show_all_mobs" = show_all_mobs,
		"rights" = list(
			"admin" = check_rights_for(user_client, R_ADMIN),
			"ban" = check_rights_for(user_client, R_BAN),
			"fun" = check_rights_for(user_client, R_FUN),
		),
		"exp_tracking" = !!CONFIG_GET(flag/use_exp_tracking),
		"centcom_enabled" = !!CONFIG_GET(string/centcom_ban_db),
	)

/// Resets the auto-update cooldown and pushes fresh data to the client.
/datum/player_panel/proc/push_update(datum/tgui/ui)
	update_cooldown = 0
	ui?.send_update()

/datum/player_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(R_ADMIN))
		return
	var/client/user_client = usr.client
	var/datum/admins/holder = user_client?.holder
	if(!holder)
		return

	// Actions that do not target a specific player.
	switch(action)
		if("refresh")
			push_update(ui)
			return
		if("set_search_text")
			search_text = params["text"]
			pinned_ckey = ckey(params["selectedPlayerCkey"])
			push_update(ui)
			return
		if("set_update_interval")
			var/new_interval = text2num("[params["value"]]")
			update_interval = isnum(new_interval) ? clamp(new_interval, 0, 120) : 5
			push_update(ui)
			return
		if("toggle_all_mobs")
			show_all_mobs = !show_all_mobs
			push_update(ui)
			return
		if("oldPP")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_player_panel) //logs/rightscheck inside the proc
			return
		if("checkPlayers")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/check_players) //logs/rightscheck inside the proc
			return
		if("checkAntags")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/check_antagonists) //logs/rightscheck inside the proc
			return
		if("faxPanel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/fax_panel) //logs/rightscheck inside the proc
			return
		if("gamePanel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/game_panel) //logs/rightscheck inside the proc
			return
		if("allVerbsPanel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/admin_verb_panel) //logs/rightscheck inside the proc
			return
		if("createCommandReport")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/create_command_report) //logs/rightscheck inside the proc
			return
		if("adminaiinteract") //loggin inside the proc
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/toggle_ai_interact)
			return

	var/target_ckey = ckey(params["selectedPlayerCkey"])
	if(!length(target_ckey))
		return
	var/mob/target_mob = get_mob_by_ckey(target_ckey)
	if(!target_mob)
		to_chat(usr, span_warning("Could not find a mob for [target_ckey]."), confidential = TRUE)
		return

	// Player-targeted actions. Most of them go through admin verbs or Topic(), which check rights and log on their own.
	switch(action)
		if("sendPrivateMessage")
			user_client.cmd_admin_pm(target_ckey, null)
			SSblackbox.record_feedback("tally", "VUAP", 1, "PM")
			return
		if("subtleMessage")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_admin_subtle_message, target_mob)
			return
		if("headsetMessage")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_admin_headset_message, target_mob)
			return
		if("narrateTo")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_admin_direct_narrate, target_mob)
			return
		if("follow")
			user_client.admin_follow(target_mob)
			to_chat(usr, "Now following [target_ckey].", confidential = TRUE)
			return
		if("openViewVariables") //logs/rightscheck inside the proc
			user_client.debug_variables(target_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "VV")
			return
		if("openLanguagePanel")
			target_mob.get_language_holder().open_language_menu(usr)
			return
		if("openTraitorPanel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/show_traitor_panel, target_mob)
			return
		if("openHours")
			if(target_mob.client)
				holder.cmd_show_exp_panel(target_mob.client)
			return
		if("openLogs")
			var/datum/log_viewer/LV = new(target_mob)
			LV.ui_interact(usr)
			return
		if("openNotes")
			browse_messages(target_ckey = target_ckey, agegate = FALSE)
			return
		if("openAdditionalPanel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/options_panel, target_mob)
			return
		if("openBorgPanel")
			if(!iscyborg(target_mob))
				to_chat(usr, span_warning("[target_ckey] is not a cyborg."), confidential = TRUE)
				return
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/borg_panel, target_mob)
			return
		if("initMind")
			if(target_mob.mind)
				to_chat(usr, span_warning("[target_ckey] already has a mind."), confidential = TRUE)
				return
			target_mob.mind_initialize()
			return
		if("revive")
			holder.Topic(null, list(
				"revive" = REF(target_mob),
				"admin_token" = holder.href_token
			))
			return
		if("sendToLobby")
			holder.Topic(null, list(
				"sendbacktolobby" = REF(target_mob),
				"admin_token" = holder.href_token
			))
			return
		if("kick")
			holder.Topic(null, list(
				"boot2" = REF(target_mob),
				"admin_token" = holder.href_token
			))
			return
		if("jail")
			holder.Topic(null, list(
				"sendtoprison" = REF(target_mob),
				"admin_token" = holder.href_token
			))
			return
		if("openBan")
			if(!check_rights(R_BAN))
				return
			holder.ban_panel(target_ckey, target_mob.client?.address, target_mob.client?.computer_id)
			return
		if("smite")
			if(!check_rights(R_ADMIN|R_FUN))
				return
			if(!isliving(target_mob))
				to_chat(usr, span_warning("This can only be used on living mobs."), confidential = TRUE)
				return
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/admin_smite, target_mob)
			return
		if("centcomBans")
			if(!CONFIG_GET(string/centcom_ban_db))
				return
			holder.Topic(null, list(
				"centcomlookup" = target_ckey,
				"admin_token" = holder.href_token
			))
			return

/datum/player_panel/ui_interact(mob/user, datum/tgui/ui)
	if(ui)
		// Keep the UI state in sync even when the autoupdate tick is throttled away.
		ui.process_status()
		if(ui.status <= UI_CLOSE)
			ui.close()
			return
		// Throttle the autoupdate ticks. Explicit refreshes call push_update() instead of relying on this proc.
		if(!update_interval || !COOLDOWN_FINISHED(src, update_cooldown))
			return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerPanel")
		ui.set_autoupdate(TRUE)
		ui.open()
	COOLDOWN_START(src, update_cooldown, max(update_interval, 1) SECONDS)

/datum/player_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/client //this is needed to hold the selected player ckey for moving to and from pp/vuap
	///This is used to hold the ckey of the selected player for moving to and from the player panel and vuap
	var/selectedPlayerCkey = ""
	///this is used to hold the mob of the selected player in case the ckey can't be found (this enables pp'ing soulless mobs)
	var/VUAP_selected_mob = null
	///Reusable  player panel datum, so reopening the verb updates the existing window instead of spawning a new one
	var/datum/player_panel/player_panel

/datum/options_panel

/datum/options_panel/ui_data(mob/user)
	var/ckey = user.client?.selectedPlayerCkey
	var/list/admin_rights_tokens = list()
	if(check_rights(R_ADMIN))
		admin_rights_tokens += "admin"
	if(check_rights(R_BAN))
		admin_rights_tokens += "ban"
	if(check_rights(R_FUN))
		admin_rights_tokens += "fun"
	if(check_rights(R_SOUND))
		admin_rights_tokens += "sound"
	if(check_rights(R_SPAWN))
		admin_rights_tokens += "spawn"
	if(check_rights(R_DEBUG))
		admin_rights_tokens += "debug"
	if(check_rights(R_SERVER))
		admin_rights_tokens += "server"
	var/list/player_data = list(
		"characterName" = "No Character",
		"ckey" = ckey || "Unknown",
		"ipAddress" = "0.0.0.0",
		"CID" = "NO_CID",
		"gameState" = "Unknown",
		"byondVersion" = "0.0.0",
		"mobType" = "null",
		"firstSeen" = "Never",
		"accountRegistered" = "Unknown",
		"adminRights" = admin_rights_tokens.Join(" "),
		"muteStates" = list(
			"ic" = FALSE,
			"ooc" = FALSE,
			"pray" = FALSE,
			"adminhelp" = FALSE,
			"deadchat" = FALSE,
			"webreq" = FALSE
		)
	)
	if(!length(ckey) || ckey[1] == "@")
		var/mob/player = usr.client.VUAP_selected_mob
		player_data["characterName"] = player.name || "No Character"
		player_data["gameState"] = get_player_state(player)
		player_data["mobType"] = "[initial(player.type)]" || "null"
		return list("Data" = player_data)
	else
		var/mob/player = get_mob_by_ckey(ckey)
		var/client/client_info = player?.client
		player_data["gameState"] = get_player_state(player)
		if(player && client_info)
			player_data["characterName"] = player.real_name || "No Character"
			player_data["ipAddress"] = client_info.address || "0.0.0.0"
			player_data["CID"] = client_info.computer_id || "NO_CID"
			player_data["byondVersion"] = "[client_info.byond_version || 0].[client_info.byond_build || 0]"
			player_data["mobType"] = "[initial(player.type)]" || "null"
			player_data["firstSeen"] = client_info.player_join_date || "Never"
			player_data["accountRegistered"] = client_info.account_join_date || "Unknown"
			// Safely check mute states
			if(client_info.prefs)
				player_data["muteStates"] = list(
					"ic" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_IC),
					"ooc" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_OOC),
					"pray" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_PRAY),
					"adminhelp" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_ADMINHELP),
					"deadchat" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_DEADCHAT),
					"webreq" = !isnull(client_info.prefs.muted) && (client_info.prefs.muted & MUTE_INTERNET_REQUEST),
				)
		return list("Data" = player_data)

/datum/options_panel/proc/get_player_state(mob/player)
	if(!istype(player))
		return "Unknown"
	if(isnewplayer(player))
		return "Lobby"
	if(isobserver(player))
		return "Ghost"
	if(!player.client)
		return "No Client"
	return (player.stat == DEAD) ? "Dead" : "Alive"

/datum/options_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OptionsPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/options_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(R_ADMIN))
		return
	var/mob/selected_mob = get_mob_by_ckey(ui.user.client.selectedPlayerCkey)
	if(!selected_mob)
		tgui_alert(usr, "Selected player not found!")
		return
	//pretty much all of these actions use the Topic() admin call. This admin call is secure, checks rights, and does stuff the way the old player panel did.
	//see code/modules/admin/topic.dm for more info on how it works.
	//essentially you have to pass a list of parameters to Topic(). It needs to be provided with an admin token to do any of its functions.
	switch(action)
		if("refresh")
			ui.send_update()
			return
		if("relatedbycid")
			usr.client.holder.Topic(null, list(
			"showrelatedacc" = "cid",
			"admin_token" = usr.client.holder.href_token,
			"client" = REF(selected_mob.client),
			))
			return
		if("relatedbyip")
			usr.client.holder.Topic(null, list(
			"showrelatedacc" = "ip",
			"admin_token" = usr.client.holder.href_token,
			"client" = REF(selected_mob.client),
			))
			return
		// Punish Section
		if("kick")
			usr.client.holder.Topic(null, list(
				"boot2" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("ban")
			if(!check_rights(R_BAN))
				return
			usr.client.holder.Topic(null, list(
				"newbankey" = selected_mob.ckey,
				"newbanip" = selected_mob.lastKnownIP,
				"newbancid" = selected_mob.client.computer_id,
				"admin_token" = usr.client.holder.href_token,))
			return
		if("prison")
			usr.client.holder.Topic(null, list(
				"sendtoprison" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("unprison")
			if (is_centcom_level(selected_mob.z))
				SSjob.send_to_late_join(selected_mob)
				to_chat(usr, "Unprisoned [selected_mob.ckey].", confidential = TRUE)
				message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(selected_mob)]")
				log_admin("[key_name(usr)] has unprisoned [key_name(selected_mob)]")
			else
				tgui_alert(usr,"[selected_mob.name] is not prisoned.")
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Unprison")
			return
		if("smite")
			usr.client.holder.Topic(null, list(
				"adminsmite" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		// Message Section
		if("pm")
			usr.client.cmd_admin_pm(selected_mob.ckey)
			SSblackbox.record_feedback("tally", "VUAP", 1, "PM")
			return
		if("sm")
			usr.client.holder.Topic(null, list(
				"subtlemessage" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("headsetmsg")
			var/choice = tgui_input_list(usr, "Message As Whom?", "Headset Message", list("Centcom", "Syndicate"))
			if(choice == "Centcom")
				usr.client.holder.Topic(null, list(
					"CentComReply" = REF(selected_mob),
					"admin_token" = usr.client.holder.href_token,
				))
				return
			if(choice == "Syndicate")
				usr.client.holder.Topic(null, list(
					"SyndicateReply" = REF(selected_mob),
					"admin_token" = usr.client.holder.href_token,
				))
				return
		if("centcom_reply")
			usr.client.holder.Topic(null, list(
				"CentComReply" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("syndicate_reply")
			usr.client.holder.Topic(null, list(
				"SyndicateReply" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("narrate")
			usr.client.holder.Topic(null, list(
				"narrateto" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("playsoundto")
			usr.client.holder.Topic(null, list(
				"playsoundto" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return

		// Movement Section
		if("jumpto")
			usr.client.holder.Topic(null, list(
				"jumpto" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("get")
			usr.client.holder.Topic(null, list(
				"getmob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("send")
			usr.client.holder.Topic(null, list(
				"sendmob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("lobby")
			usr.client.holder.Topic(null, list(
				"sendbacktolobby" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("flw")
			usr.client.holder.Topic(null, list(
				"adminplayerobservefollow" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token,
			))
			return
//              if("cryo")
//                      selected_mob.vv_send_cryo()
//                      return
		// Info Section
		if("vv") //checks rights inside the proc
			usr.client.debug_variables(selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "VV")
			return
		if("tp")
			usr.client.holder.Topic(null, list(
				"traitor" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("skills")
			usr.client.holder.Topic(null, list(
				"skill" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("logs")
			usr.client.holder.Topic(null, list(
				"individuallog" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("notes")
			browse_messages(target_ckey = selected_mob.ckey)
			return
		// Transformation Section
		if("makeghost")
			usr.client.holder.Topic(null, list(
				"simplemake" = "observer",
				"mob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		if("makehuman")
			usr.client.holder.Topic(null, list(
				"simplemake" = "human",
				"mob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		if("makemonkey")
			usr.client.holder.Topic(null, list(
				"simplemake" = "monkey",
				"mob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		if("makeborg")
			usr.client.holder.Topic(null, list(
				"simplemake" = "robot",
				"mob" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		if("makeai")
			usr.client.holder.Topic(null, list(
				"makeai" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			ui.send_update()
			return
		//health section
		if("healthscan")
			healthscan(usr, selected_mob, scanpower = SCANPOWER_ADVANCED, tochat = TRUE)
			SSblackbox.record_feedback("tally", "VUAP", 1, "HealthScan")
		if("chemscan")
			chemscan(usr, selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "ChemScan")
		if("aheal")
			usr.client.holder.Topic(null, list(
				"revive" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			to_chat(usr, "Adminhealed  [selected_mob.ckey].", confidential = TRUE)
			return
		if("giveDisease")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/give_disease, selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "GiveDisease")
			return
		if("cureAllDiseases")
			if(istype(selected_mob, /mob/living))
				var/mob/living/L = selected_mob
				L.fully_heal(HEAL_NEGATIVE_DISEASES)
			to_chat(usr, "Cured all negative diseases on [selected_mob.ckey].", confidential = TRUE)
			SSblackbox.record_feedback("tally", "VUAP", 1, "CureAllDiseases")
			return
		if("modifytraits")
			usr.client.holder.modify_traits(selected_mob)
			SSblackbox.record_feedback("tally", "VUAP", 1, "ModifyTraits")
			return
		// Misc Section
		if("language")
			usr.client.holder.Topic(null, list(
				"languagemenu" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("forcesay")
			usr.client.holder.Topic(null, list(
				"forcespeech" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
		if("applyquirks")
			usr.client.holder.Topic(null, list(
				"applyquirks" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
		if("thunderdome1")
			usr.client.holder.Topic(null, list(
				"tdome1" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdome2")
			usr.client.holder.Topic(null, list(
				"tdome2" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("commend")
			usr.client.holder.Topic(null, list(
				"admincommend" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("playtime")
			usr.client.holder.Topic(null, list(
				"getplaytimewindow" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdomeadmin")
			usr.client.holder.Topic(null, list(
				"tdomeadmin" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdomeobserve")
			usr.client.holder.Topic(null, list(
				"tdomeobserver" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("dblink")
			usr.client.holder.Topic(null, list(
				"centcomlookup" = selected_mob.ckey,
				"admin_token" = usr.client.holder.href_token
			))
		if("spawncookie")
			usr.client.holder.Topic(null, list(
				"adminspawncookie" = REF(selected_mob),
				"admin_token" = usr.client.holder.href_token
			))
			return
		// Mute Controls
		if("toggleMute")
			var/muteType = params["type"]
			switch(muteType)
				if("ic")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_IC)
					ui.send_update()
					return
				if("ooc")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_OOC)
					ui.send_update()
					return
				if("pray")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_PRAY)
					ui.send_update()
					return
				if("adminhelp")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_ADMINHELP)
					ui.send_update()
					return
				if("deadchat")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_DEADCHAT)
					ui.send_update()
					return
				if("webreq")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_INTERNET_REQUEST)
					ui.send_update()
					return
			return

		if("toggleAllMutes")
			cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_ALL)
			ui.send_update()
			return

/datum/options_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)
