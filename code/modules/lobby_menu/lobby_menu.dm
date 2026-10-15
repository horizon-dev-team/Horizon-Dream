GLOBAL_LIST_EMPTY(lobby_menus)
GLOBAL_VAR(lobby_background_transparent)
GLOBAL_VAR(lobby_video_asset_name)
GLOBAL_VAR(lobby_background_asset_name)
GLOBAL_VAR(lobby_background_asset_map)

#define LOBBY_FADE_OUT_TIME 1 SECONDS
#define LOBBY_PREVIEW_DIRS list("south" = SOUTH, "east" = EAST, "north" = NORTH, "west" = WEST)

/client/var/datum/lobby_menu/lobby_menu

/client/proc/initialize_lobby_menu()
	set waitfor = FALSE
	if(!src)
		return
	lobby_menu = new(src)

ADMIN_VERB(toggle_lobby_transparency, R_ADMIN, "Toggle Lobby Transparency", "Toggles the lobby background between opaque and transparent.", ADMIN_CATEGORY_MAIN)
	GLOB.lobby_background_transparent = !GLOB.lobby_background_transparent
	for(var/datum/lobby_menu/menu as anything in GLOB.lobby_menus)
		menu.set_transparency(GLOB.lobby_background_transparent)
	to_chat(user, span_adminnotice("Lobby background [GLOB.lobby_background_transparent ? "transparent" : "opaque"]."))
	log_admin("[key_name(user)] toggled lobby transparency [GLOB.lobby_background_transparent ? "on" : "off"].")

/// when the client enters the lobby and torn down after a fade-out when leaving.
/datum/lobby_menu
	var/client/client
	/// Only set while the lobby is shown
	var/datum/tgui_window/window
	var/shown = FALSE
	var/fade_timer
	var/assets_signals_registered = FALSE
	var/ticker_signals_registered = FALSE
	/// Bumped on every re-render to bust the client asset cache
	var/preview_sequence = 0
	var/list/preview_urls
	var/preview_dirty = TRUE
	var/issues_dirty = FALSE

/datum/lobby_menu/New(client/client)
	src.client = client
	RegisterSignal(client, COMSIG_QDELETING, PROC_REF(on_client_qdel))
	RegisterSignal(client, COMSIG_CLIENT_MOB_LOGIN, PROC_REF(on_client_mob_login))
	GLOB.lobby_menus += src
	// The browser always overlays the map pane, so the pane never has to be
	// swapped (which used to flash the title screen).
	winset(client, SKIN_MAP_LOBBY_SELECTOR, "left=[SKIN_MAP_SCREEN]")
	update_visibility()

/datum/lobby_menu/Destroy(force)
	GLOB.lobby_menus -= src
	STOP_PROCESSING(SSlobby_menu, src)
	if(client)
		UnregisterSignal(client, list(COMSIG_QDELETING, COMSIG_CLIENT_MOB_LOGIN))
	unregister_ticker_signals()
	close_window()
	client = null
	return ..()

/datum/lobby_menu/proc/on_client_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/lobby_menu/proc/on_client_mob_login()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(update_visibility))

/datum/lobby_menu/proc/update_visibility()
	var/should_show = istype(client?.mob, /mob/dead/new_player) && !client.interviewee
	if(should_show == shown)
		return
	if(should_show)
		show()
	else
		hide()

/datum/lobby_menu/proc/is_lobby_transparent()
	return GLOB.lobby_background_transparent && !client?.prefs?.read_preference(/datum/preference/toggle/disable_lobby_transparency)

/datum/lobby_menu/proc/show()
	if(shown || !client)
		return
	shown = TRUE
	if(fade_timer)
		deltimer(fade_timer)
		fade_timer = null
	if(!window)
		create_window()
	apply_element_background()
	register_ticker_signals()
	START_PROCESSING(SSlobby_menu, src)
	preview_dirty = TRUE
	issues_dirty = FALSE
	send_init()
	update_character_preview()

/**
 * always overlays the map pane; in opaque mode it is painted black to hide
 * the map, and is made see-through during the fade-out so the lobby
 * cross-fades into the game view behind it.
 */
/datum/lobby_menu/proc/create_window()
	// Remove a stale element, if any
	winset(client, "lobby_menu", list("parent" = ""))
	// Match the pane size up front, otherwise the window visibly stretches
	// from its default size once the page loads
	var/selector_size = winget(client, SKIN_MAP_LOBBY_SELECTOR, "size")
	winset(client, "lobby_menu", list(
		"parent" = SKIN_MAP_SCREEN,
		"type" = "BROWSER",
		"pos" = "0,0",
		"size" = selector_size || "640x480",
		"anchor1" = "0,0",
		"anchor2" = "100,100",
		"is-visible" = "false",
	))
	apply_element_background()
	window = new(client, "lobby_menu")
	window.is_browser = TRUE
	window.initialize(
		strict_mode = TRUE,
		inline_css = file("tgui/public/tgui-lobby.bundle.css"),
		inline_js = file("tgui/public/tgui-lobby.bundle.js"),
	)
	window.subscribe(src, PROC_REF(on_message))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/lobby_menu_font))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/lobby_menu_sounds))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/fontawesome))
	winset(client, "lobby_menu", "is-visible=true")

/// [HORIZON-ADD] Applies the opaque/see-through element background
/datum/lobby_menu/proc/apply_element_background()
	if(!client)
		return
	if(is_lobby_transparent())
		winset(client, "lobby_menu", list(
			"background-color" = "none",
			"inner-background-color" = "transparent",
		))
	else
		winset(client, "lobby_menu", list(
			"background-color" = "#000000",
			"inner-background-color" = "#000000",
		))

/**
 * [HORIZON-ADD] Fades the lobby out and tears the browser down once the
 * client has had time to play its fade-out animation.
 */
/datum/lobby_menu/proc/hide()
	if(!shown)
		return
	shown = FALSE
	STOP_PROCESSING(SSlobby_menu, src)
	unregister_ticker_signals()
	if(!window)
		return
	window.send_message("fadeOut")
	if(!is_lobby_transparent())
		winset(client, "lobby_menu", list(
			"background-color" = "none",
			"inner-background-color" = "transparent",
		))
	if(fade_timer)
		deltimer(fade_timer)
	fade_timer = addtimer(CALLBACK(src, PROC_REF(on_fade_out_finished)), LOBBY_FADE_OUT_TIME, TIMER_STOPPABLE)

/datum/lobby_menu/proc/on_fade_out_finished()
	fade_timer = null
	if(shown || !client)
		return
	close_window()

/// [HORIZON-ADD] Destroys the browser element and the tgui window, if any
/datum/lobby_menu/proc/close_window()
	if(window)
		window.unsubscribe(src)
		window.close(can_be_suspended = FALSE)
		window = null
	if(client)
		winset(client, "lobby_menu", list("parent" = ""))

/// Toggle the lobby browser between opaque (black backdrop) and transparent (overlaying map)
/datum/lobby_menu/proc/set_transparency(transparent)
	if(transparent && client?.prefs?.read_preference(/datum/preference/toggle/disable_lobby_transparency))
		return
	if(!window)
		return
	apply_element_background()
	send_init()
	if(transparent)
		to_chat(client, span_notice("An admin has made the lobby background transparent. You can now see the map behind the lobby menu. You can disable this in your game preferences."))

/datum/lobby_menu/process(seconds_per_tick)
	send_update(list(
		"countdown" = get_countdown_text(),
		"playerCount" = length(GLOB.clients),
		"readyCount" = SSticker.totalPlayersReady,
		"adminReadyCount" = SSticker.total_admins_ready,
		"adminCount" = length(GLOB.admins),
		"shiftTime" = (SSticker.round_start_time == 0) ? "Pre-Game" : round_timestamp(),
	))
	if(preview_dirty)
		update_character_preview()
	if(issues_dirty)
		issues_dirty = FALSE
		send_update(list("preferenceIssues" = get_preference_issues()))

/// [HORIZON-ADD] Marks the preview and preference issues for a refresh
/datum/lobby_menu/proc/queue_character_refresh()
	if(!shown)
		return
	preview_dirty = TRUE
	issues_dirty = TRUE

/datum/lobby_menu/proc/register_ticker_signals()
	if(ticker_signals_registered)
		return
	ticker_signals_registered = TRUE
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(on_ticker_pregame))
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(on_ticker_setting_up))
	RegisterSignal(SSticker, COMSIG_TICKER_ERROR_SETTING_UP, PROC_REF(on_ticker_error_setting_up))
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))

/datum/lobby_menu/proc/unregister_ticker_signals()
	if(!ticker_signals_registered)
		return
	ticker_signals_registered = FALSE
	UnregisterSignal(SSticker, list(
		COMSIG_TICKER_ENTER_PREGAME,
		COMSIG_TICKER_ENTER_SETTING_UP,
		COMSIG_TICKER_ERROR_SETTING_UP,
		COMSIG_TICKER_ROUND_STARTING,
	))

/datum/lobby_menu/proc/on_ticker_pregame()
	SIGNAL_HANDLER
	send_update(list(
		"gamePhase" = "pregame",
		"canObserve" = TRUE,
	))

/datum/lobby_menu/proc/on_ticker_setting_up()
	SIGNAL_HANDLER
	send_update(list(
		"gamePhase" = "setting_up",
		"canReady" = FALSE,
		"canJoin" = TRUE,
	))

/datum/lobby_menu/proc/on_ticker_error_setting_up()
	SIGNAL_HANDLER
	send_update(list(
		"gamePhase" = "pregame",
		"canReady" = TRUE,
		"canJoin" = FALSE,
	))

/datum/lobby_menu/proc/on_round_start()
	SIGNAL_HANDLER
	send_update(list(
		"gamePhase" = "playing",
		"canReady" = FALSE,
		"canJoin" = TRUE,
	))

/datum/lobby_menu/proc/get_game_phase()
	switch(SSticker.current_state)
		if(GAME_STATE_STARTUP)
			return "startup"
		if(GAME_STATE_PREGAME)
			return "pregame"
		if(GAME_STATE_SETTING_UP)
			return "setting_up"
		if(GAME_STATE_PLAYING)
			return "playing"
	return "postgame"

/datum/lobby_menu/proc/get_countdown_text()
	var/time_remaining = SSticker.GetTimeLeft()
	if(time_remaining > 0)
		return "[round(time_remaining / 10)]s"
	if(time_remaining == -10)
		return "DELAYED"
	return "SOON"

/datum/lobby_menu/proc/send_init()
	if(!window)
		return
	var/mob/dead/new_player/player = client?.mob
	var/game_phase = get_game_phase()

	window.send_message("init", list(
		"gamePhase" = game_phase,
		"isReady" = istype(player) && player.ready == PLAYER_READY_TO_PLAY,
		"canReady" = game_phase == "pregame" || game_phase == "startup",
		"canJoin" = game_phase == "setting_up" || game_phase == "playing",
		"canObserve" = SSticker.current_state > GAME_STATE_STARTUP,
		"assetsReady" = (SSearly_assets.initialized == INITIALIZATION_INNEW_REGULAR) || (SSatoms.initialized == INITIALIZATION_INNEW_REGULAR),
		"countdown" = get_countdown_text(),
		"playerCount" = length(GLOB.clients),
		"readyCount" = SSticker.totalPlayersReady,
		"adminReadyCount" = SSticker.total_admins_ready,
		"adminCount" = length(GLOB.admins),
		"mapName" = SSmapping.current_map?.map_name || "Loading...",
		"shiftTime" = (SSticker.round_start_time == 0) ? "Pre-Game" : round_timestamp(),
		"isAdmin" = !isnull(client?.holder),
		"isLocalhost" = client?.is_localhost(),
		"hasNewPoll" = FALSE,
		"canPoll" = !is_guest_key(client?.key) && SSdbcore.Connect(),
		"transparent" = is_lobby_transparent(),
		// [HORIZON-ADD] html lobby extras
		"characterName" = get_character_name(),
		"preferenceIssues" = get_preference_issues(),
		"backgroundUrl" = get_lobby_background_url(),
		"videoUrl" = get_lobby_video_url(),
		"previewUrls" = preview_urls,
		// [/HORIZON-ADD]
	))

	check_new_polls()
	register_asset_signals()

/datum/lobby_menu/proc/register_asset_signals()
	if(assets_signals_registered)
		return
	if(SSearly_assets.initialized != INITIALIZATION_INNEW_REGULAR)
		RegisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_assets_ready))
		assets_signals_registered = TRUE
	if(SSatoms.initialized != INITIALIZATION_INNEW_REGULAR)
		RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_assets_ready))
		assets_signals_registered = TRUE

/datum/lobby_menu/proc/on_assets_ready(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_SUBSYSTEM_POST_INITIALIZE)

	if(SSearly_assets.initialized == INITIALIZATION_INNEW_REGULAR || SSatoms.initialized == INITIALIZATION_INNEW_REGULAR)
		send_update(list("assetsReady" = TRUE))

/datum/lobby_menu/proc/check_new_polls()
	set waitfor = FALSE
	if(!client)
		return
	var/mob/dead/new_player/player = client.mob
	if(!istype(player) || is_guest_key(player.key))
		return
	if(!SSdbcore.Connect())
		return
	var/isadmin = !isnull(client.holder)
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = player.ckey))
	if(!query.Execute())
		qdel(query)
		return
	var/has_new = query.NextRow() ? TRUE : FALSE
	qdel(query)
	if(!client)
		return
	send_update(list("hasNewPoll" = has_new))

/datum/lobby_menu/proc/send_update(list/data)
	if(!window)
		return
	window.send_message("state", data)

/datum/lobby_menu/proc/on_message(type, payload, href_list)
	if(type == "ready")
		// The page loaded and subscribed to our messages - (re)send the full state
		send_init()
		return TRUE

	if(type != "action")
		return FALSE

	var/action = payload["action"]
	var/mob/dead/new_player/player = client?.mob
	if(!istype(player) || client.interviewee)
		return TRUE

	switch(action)
		if("ready_toggle")
			if(player.ready == PLAYER_NOT_READY)
				player.auto_deadmin_on_ready_or_latejoin()
				player.ready = PLAYER_READY_TO_PLAY
			else
				player.ready = PLAYER_NOT_READY
			send_update(list("isReady" = player.ready == PLAYER_READY_TO_PLAY))
		if("join")
			if(!SSticker?.IsRoundInProgress())
				to_chat(player, span_boldwarning("The round is either not ready, or has already finished..."))
				return TRUE

			var/relevant_cap
			var/hard_popcap = CONFIG_GET(number/hard_popcap)
			var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
			if(hard_popcap && extreme_popcap)
				relevant_cap = min(hard_popcap, extreme_popcap)
			else
				relevant_cap = max(hard_popcap, extreme_popcap)

			if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(player.key) in GLOB.admin_datums)))
				to_chat(player, span_danger("[CONFIG_GET(string/hard_popcap_message)]"))
				var/queue_position = SSticker.queued_players.Find(player)
				if(queue_position == 1)
					to_chat(player, span_notice("You are next in line to join the game. You will be notified when a slot opens up."))
				else if(queue_position)
					to_chat(player, span_notice("There are [queue_position-1] players in front of you in the queue to join the game."))
				else
					SSticker.queued_players += player
					to_chat(player, span_notice("You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len]."))
				return TRUE

			player.auto_deadmin_on_ready_or_latejoin()

			if(payload["ctrlClick"])
				to_chat(player, span_warning("Opening emergency fallback late join menu! If THIS doesn't show, ahelp immediately!"))
				GLOB.latejoin_menu.fallback_ui(player)
			else
				GLOB.latejoin_menu.ui_interact(player)
		if("observe")
			player.make_me_an_observer()
		if("character_setup")
			var/datum/preferences/prefs = client.prefs
			prefs.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
			prefs.update_static_data(player)
			prefs.ui_interact(player)
		if("settings")
			var/datum/preferences/prefs = client.prefs
			prefs.current_window = PREFERENCE_TAB_GAME_PREFERENCES
			prefs.update_static_data(player)
			prefs.ui_interact(player)
		if("changelog")
			client.changelog()
		if("crew_manifest")
			player.ViewManifest()
		if("poll")
			player.handle_player_polling()
		if("start_now")
			if(!client.is_localhost() || !check_rights_for(client, R_SERVER))
				return TRUE
			SSticker.start_immediately = TRUE
			if(SSticker.current_state == GAME_STATE_STARTUP)
				to_chat(player, span_admin("The server is still setting up, but the round will be started as soon as possible."))
		// [HORIZON-ADD] html lobby extras
		if("refresh_preview")
			preview_dirty = TRUE
			update_character_preview()

	return TRUE

// [HORIZON-ADD] Renders the current character into four directional preview
/datum/lobby_menu/proc/get_character_name()
	return client?.prefs?.read_preference(/datum/preference/name/real_name)

/datum/lobby_menu/proc/get_preference_issues()
	var/list/issues = list()
	var/datum/preferences/prefs = client?.prefs
	if(!prefs)
		return issues

	if(!length(prefs.job_preferences))
		issues += "You have no job preferences set - you will be assigned to [SSjob.get_job_type(SSjob.overflow_role).title]."
		return issues

	var/list/banned = list()
	var/list/gated = list()
	for(var/job_title in prefs.job_preferences)
		var/datum/job/job = SSjob.get_job(job_title)
		if(isnull(job))
			continue
		if(is_banned_from(client.ckey, job.title))
			banned += job.title
		else if(job.required_playtime_remaining(client) || !job.player_old_enough(client))
			gated += job.title

	if(length(banned))
		issues += "You are banned from some of your preferred roles: [english_list(banned)]."
	if(length(gated))
		issues += "You do not yet meet the requirements for some of your preferred roles: [english_list(gated)]."

	return issues

/**
 * images and registers them as client assets. Failures leave preview_dirty
 * set so process() retries them.
 */
/datum/lobby_menu/proc/update_character_preview()
	set waitfor = FALSE
	if(!client?.prefs || !window)
		// Preferences are not settled yet (very early login) - process() retries
		return
	preview_dirty = FALSE

	var/datum/preferences/prefs = client.prefs
	var/mob/living/carbon/human/dummy/mannequin = new()
	// Dress the mannequin once; silicon jobs return an /image instead
	var/rendered = prefs.render_new_preview_appearance(mannequin, TRUE)
	var/icon_source = istype(rendered, /image) ? rendered : mannequin

	var/list/new_urls = list()
	preview_sequence += 1
	for(var/dir_name in LOBBY_PREVIEW_DIRS)
		var/icon/flat = getFlatIcon(icon_source, LOBBY_PREVIEW_DIRS[dir_name])
		if(!flat)
			continue
		var/asset_name = "lobby_preview_[client.ckey]_[preview_sequence]_[dir_name].png"
		SSassets.transport.register_asset(asset_name, flat)
		SSassets.transport.send_assets(client, asset_name)
		new_urls[dir_name] = SSassets.transport.get_asset_url(asset_name)

	qdel(mannequin)

	if(!length(new_urls))
		// Nothing rendered - try again later rather than leaving the panel empty
		preview_dirty = TRUE
		return
	preview_urls = new_urls
	send_update(list("previewUrls" = preview_urls))

/// config/lobby_art/ (.webm or .mp4) and cached per server boot
/datum/lobby_menu/proc/get_lobby_video_url()
	if(is_lobby_transparent())
		return null
	if(isnull(GLOB.lobby_video_asset_name))
		var/list/candidates = list()
		for(var/filename in flist("[global.config.directory]/lobby_art/"))
			var/extension = copytext(filename, findlasttext(filename, "."))
			if(extension in list(".webm", ".mp4"))
				candidates += filename
		if(!length(candidates))
			// Negative cache so we don't rescan on every init
			GLOB.lobby_video_asset_name = ""
			return null
		var/chosen = pick(candidates)
		GLOB.lobby_video_asset_name = "lobby_video_[ckey(chosen)]"
		SSassets.transport.register_asset(GLOB.lobby_video_asset_name, fcopy_rsc("[global.config.directory]/lobby_art/[chosen]"))
	if(!GLOB.lobby_video_asset_name)
		return null
	SSassets.transport.send_assets(client, GLOB.lobby_video_asset_name)
	return SSassets.transport.get_asset_url(GLOB.lobby_video_asset_name)

/// "<map name>.png" from config/lobby_art/ wins, then "default.<ext>". Cached per map.
/datum/lobby_menu/proc/get_lobby_background_url()
	if(is_lobby_transparent())
		return null
	var/map_name = SSmapping.current_map?.map_name
	if(GLOB.lobby_background_asset_map != map_name)
		GLOB.lobby_background_asset_map = map_name
		GLOB.lobby_background_asset_name = null
	if(isnull(GLOB.lobby_background_asset_name))
		var/art_dir = "[global.config.directory]/lobby_art/"
		var/chosen
		if(map_name && fexists("[art_dir][map_name].png"))
			chosen = "[map_name].png"
		else if(map_name && fexists("[art_dir][map_name].jpg"))
			chosen = "[map_name].jpg"
		else
			for(var/filename in flist(art_dir))
				var/lower_name = LOWER_TEXT(filename)
				if(lower_name == "default.png" || lower_name == "default.jpg" || lower_name == "default.jpeg")
					chosen = filename
					break
		if(!chosen)
			// Negative cache so we don't rescan on every init
			GLOB.lobby_background_asset_name = ""
			return null
		GLOB.lobby_background_asset_name = "lobby_background_[ckey(chosen)]"
		SSassets.transport.register_asset(GLOB.lobby_background_asset_name, fcopy_rsc("[art_dir][chosen]"))
	if(!GLOB.lobby_background_asset_name)
		return null
	SSassets.transport.send_assets(client, GLOB.lobby_background_asset_name)
	return SSassets.transport.get_asset_url(GLOB.lobby_background_asset_name)
// [/HORIZON-ADD]

#undef LOBBY_FADE_OUT_TIME
#undef LOBBY_PREVIEW_DIRS
