GLOBAL_LIST_EMPTY(preferences_datums)

/datum/preferences
	var/client/parent
	/// The path to the general savefile for this datum
	var/path
	/// Whether or not we allow saving/loading. Used for guests, if they're enabled
	var/load_and_save = TRUE
	/// Ensures that we always load the last used save, QOL
	var/default_slot = 1
	/// The maximum number of slots we're allowed to contain
	var/max_save_slots = 3

	/// Bitflags for communications that are muted
	var/muted = NONE
	/// Last IP that this client has connected from
	var/last_ip
	/// Last CID that this client has connected from
	var/last_id

	/// Cached changelog size, to detect new changelogs since last join
	var/lastchangelog = ""

	/// List of ROLE_X that the client wants to be eligible for
	var/list/be_special = list() //Special role selection

	/// Custom keybindings. Map of keybind names to keyboard inputs.
	/// For example, by default would have "swap_hands" -> list("X")
	var/list/key_bindings = list()

	/// Cached list of keybindings, mapping keys to actions.
	/// For example, by default would have "X" -> list("swap_hands")
	var/list/key_bindings_by_key = list()

	var/toggles = TOGGLES_DEFAULT
	var/db_flags = NONE
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"

	//character preferences
	var/slot_randomized //keeps track of round-to-round randomization of the character slot, prevents overwriting

	var/list/randomise = list()

	//Quirk list
	var/list/all_quirks = list()

	/**
	 * List of job titles to their priority level, JP_LOW, JP_MEDIUM, JP_HIGH
	 * If a job is absent from the list, it is considered to be "JP_NEVER"
	 */
	var/list/job_preferences = list()
	/**
	 * Lazylist of job titles to character slot numbers
	 * When rolling for a job, if that job is present in this list, we load that slot instead of the active slot
	 */
	var/list/job_assigned_profiles

	/// The current window, PREFERENCE_TAB_* in [`code/__DEFINES/preferences.dm`]
	var/current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES

	var/list/ignoring = list()

	var/list/exp = list()

	var/action_buttons_screen_locs = list()

	///Someone thought we were nice! We get a little heart in OOC until we join the server past the below time (we can keep it until the end of the round otherwise)
	var/hearted
	///If we have a hearted commendations, we honor it every time the player loads preferences until this time has been passed
	var/hearted_until
	///What outfit typepaths we've favorited in the SelectEquipment menu
	var/list/favorite_outfits = list()

	/// A preview of the current character
	var/atom/movable/screen/map_view/char_preview/character_preview_view

	/// A list of instantiated middleware
	var/list/datum/preference_middleware/middleware = list()

	/// The json savefile for this datum
	var/datum/json_savefile/savefile

	/// The savefile relating to character preferences, PREFERENCE_CHARACTER
	var/list/character_data

	/// A list of keys that have been updated since the last save.
	var/list/recently_updated_keys = list()

	/// A cache of preference entries to values.
	/// Used to avoid expensive READ_FILE every time a preference is retrieved.
	var/value_cache = list()

	/// If set to TRUE, will update cached_character_profiles on the next ui_data tick.
	var/tainted_character_profiles = FALSE
	/// The character profiles, saved so we can cheaply recompute them in ui_data only when necessary, without having to use expensive update_static_data calls.
	var/list/cached_character_profiles

	var/list/channel_volume = list()
	var/list/test_sound_channels = list()

/datum/preferences/Destroy(force)
	QDEL_NULL(character_preview_view)
	QDEL_LIST(middleware)
	value_cache = null
	return ..()

/datum/preferences/New(client/parent)
	src.parent = parent

	for (var/middleware_type in subtypesof(/datum/preference_middleware))
		middleware += new middleware_type(src)

	if(IS_CLIENT_OR_MOCK(parent))
		if(is_guest_key(parent.key))
			if(parent.is_localhost())
				path = DEV_PREFS_PATH // guest + locallost = dev instance, load dev preferences if possible
			else
				load_and_save = FALSE // guest + not localhost = guest on live, don't save anything
		else
			load_path(parent.ckey) // not guest = load their actual savefile
		if(load_and_save && !fexists(path))
			try_savefile_type_migration()

	else
		CRASH("attempted to create a preferences datum without a client or mock!")
	load_savefile()

	// give them default keybinds and update their movement keys
	key_bindings = deep_copy_list(GLOB.default_hotkeys)
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	randomise = get_default_randomization()

	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return

	// [HORIZON-ADD] Master_Sounds
	var/needs_save = FALSE
	for(var/channel in GLOB.used_sound_channels)
		if(isnull(channel_volume["[channel]"]))
			channel_volume["[channel]"] = 100
			needs_save = TRUE

	if(needs_save)
		save_preferences()
	// [/HORIZON-ADD]

	//we couldn't load character data so just randomize the character appearance + name
	randomise_appearance_prefs() //let's create a random character then - rather than a fat, bald and naked man.
	if(parent)
		apply_all_client_preferences()
		parent.set_macros()

	if(!loaded_preferences_successfully)
		save_preferences()
	save_character() //let's save this new random character so it doesn't keep generating new ones.

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	// There used to be code here that readded the preview view if you "rejoined"
	// I'm making the assumption that ui close will be called whenever a user logs out, or loses a window
	// If this isn't the case, kill me and restore the code, thanks

	// We need IconForge and the assets to be ready before allowing the menu to open
	if(SSearly_assets.initialized != INITIALIZATION_INNEW_REGULAR)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		tainted_character_profiles = TRUE
		character_preview_view = create_character_preview_view(user)
		ui = new(user, src, "PreferencesMenu")
		ui.set_autoupdate(FALSE)
		ui.open()
		character_preview_view.display_to(user, ui.window)

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

// Without this, a hacker would be able to edit other people's preferences if
// they had the ref to Topic to.
/datum/preferences/ui_status(mob/user, datum/ui_state/state)
	return user.client == parent ? UI_INTERACTIVE : UI_CLOSE

// [HORIZON-EDIT] Master_Sounds
/datum/preferences/ui_data(mob/user)
	var/list/data = list()

	if (tainted_character_profiles || isnull(cached_character_profiles))
		cached_character_profiles = create_character_profiles()
		tainted_character_profiles = FALSE

	data["character_profiles"] = cached_character_profiles

	data["character_preferences"] = compile_character_preferences(user)

	data["active_slot"] = default_slot

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_data(user)

	// Initialize channel_volume if not already done (GLOB.used_sound_channels is only populated after Sounds.Initialize())
	if(current_window == PREFERENCE_TAB_GAME_PREFERENCES)
		var/list/channels = list()
		var/list/seen_channels = list()
		for(var/channel in GLOB.used_sound_channels)
			if(channel in seen_channels)
				continue
			LAZYADD(seen_channels, channel)
			var/volume = channel_volume["[channel]"]
			if(isnull(volume) || !isnum(volume))
				volume = 100
			var/list/channel_info = get_channel_info(channel)
			channels += list(list(
				"num" = channel,
				"name" = channel_info[1],
				"desc" = channel_info[2],
				"category" = channel_info[3],
				"volume" = volume
			))
		data["channels"] = channels

	return data
// [/HORIZON-EDIT]

/datum/preferences/ui_static_data(mob/user)
	var/list/data = list()

	data["character_preview_view"] = character_preview_view.assigned_map
	data["overflow_role"] = SSjob.get_job_type(SSjob.overflow_role).title
	data["window"] = current_window

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_static_data(user)

	return data

/datum/preferences/ui_assets(mob/user)
	var/list/assets = list(
		get_asset_datum(/datum/asset/spritesheet_batched/preferences),
		get_asset_datum(/datum/asset/json/preferences),
	)

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		assets += preference_middleware.get_ui_assets()

	return assets

// [HORIZON-ADD] Master_Sounds
/datum/preferences/proc/mixer_channel_affected(check_channel, changed_channel)
	if(changed_channel == CHANNEL_MASTER_VOLUME)
		return TRUE
	if(check_channel == changed_channel)
		return TRUE
	return FALSE

/// Notifies datum-managed sounds (jukebox, TTS) and the ambience subsystem that a mixer
/datum/preferences/proc/on_mixer_volume_changed(changed_channel = null)
	var/mob/listener = parent?.mob
	if(isnull(listener))
		return

	if(mixer_channel_affected(CHANNEL_JUKEBOX, changed_channel))
		SEND_SIGNAL(listener, COMSIG_MOB_JUKEBOX_PREFERENCE_APPLIED)
	if(mixer_channel_affected(CHANNEL_TTS, changed_channel))
		SEND_SIGNAL(listener, COMSIG_MOB_TTS_VOLUME_PREFERENCE_APPLIED)
	if(mixer_channel_affected(CHANNEL_AMBIENCE, changed_channel))
		parent.update_ambience_pref()

/datum/preferences/proc/update_channel_volume(channel)
	//we gotta take into account existing sounds repeating/waiting, otherwise we completely wipe looping sounds (such as whitenoise).
	for(var/sound/S in parent.SoundQuery())
		var/sound_channel = S.channel
		var/mixer_channel = sound_channel
		var/base_volume = S.volume

		var/list/test_info = test_sound_channels["[sound_channel]"]
		if(test_info)
			mixer_channel = test_info["mixer_channel"]
			base_volume = test_info["base_volume"]

		var/should_update = FALSE
		if(channel == CHANNEL_MASTER_VOLUME)
			should_update = TRUE
		else if(mixer_channel == channel)
			should_update = TRUE

		if(!should_update)
			continue

		var/sound/new_sound = sound(
			null,
			repeat = S.repeat,
			wait = S.wait,
			channel = S.channel,
			volume = calculate_mixed_volume(parent, base_volume, mixer_channel),
		)
		new_sound.status = SOUND_UPDATE
		SEND_SOUND(parent.mob, new_sound)
// [/HORIZON-ADD]

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch (action)
		if ("change_slot")
			// Save existing character
			save_character()
			// SAFETY: `switch_to_slot` performs sanitization on the slot number
			switch_to_slot(params["slot"])
			return TRUE
		if ("remove_current_slot")
			remove_current_slot()
			return TRUE
		if ("rotate")
			character_preview_view.setDir(turn(character_preview_view.dir, -90))
			return TRUE
		if ("set_preference")
			var/requested_preference_key = params["preference"]
			var/value = params["value"]

			for (var/datum/preference_middleware/preference_middleware as anything in middleware)
				if (preference_middleware.pre_set_preference(usr, requested_preference_key, value))
					return TRUE

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			// SAFETY: `update_preference` performs validation checks
			if (!update_preference(requested_preference, value))
				return FALSE

			if (istype(requested_preference, /datum/preference/name))
				tainted_character_profiles = TRUE

			for(var/datum/preference_middleware/preference_middleware as anything in middleware)
				preference_middleware.post_set_preference(ui.user, requested_preference_key, value)
			return TRUE
		if ("set_color_preference")
			var/requested_preference_key = params["preference"]

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			if (!istype(requested_preference, /datum/preference/color))
				return FALSE

			var/default_value = read_preference(requested_preference.type)

			// Yielding
			var/new_color = tgui_color_picker(
				usr,
				"Select new color",
				null,
				default_value || COLOR_WHITE,
			)

			if (!new_color)
				return FALSE

			if (!update_preference(requested_preference, new_color))
				return FALSE

			return TRUE

		// [HORIZON-ADD]
		if("change_preferences_window")
			if(current_window == PREFERENCE_TAB_CHARACTER_PREFERENCES)
				current_window = PREFERENCE_TAB_GAME_PREFERENCES
			else
				current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
			update_static_data(ui.user)
			ui_interact(ui.user)
			return TRUE

		if("volume")
			var/channel = text2num(params["channel"])
			var/volume = text2num(params["volume"])
			if(isnull(channel))
				return FALSE
			channel_volume["[channel]"] = volume
			save_preferences()
			var/static/list/instrument_channels = list(
				CHANNEL_INSTRUMENTS,
			)
			if(!(channel in GLOB.proxy_sound_channels))
				update_channel_volume(channel)
			else if((channel in instrument_channels))
				var/datum/song/holder_song = new
				for(var/used_channel in holder_song.channels_playing)
					update_channel_volume(used_channel)

			if(channel == CHANNEL_MASTER_VOLUME)
				update_test_sound(master_changed = TRUE)
			else
				update_test_sound(mixer_channel_changed = channel)

			on_mixer_volume_changed(changed_channel = channel)

			return TRUE

		if("reset_all_volumes")
			for(var/channel in GLOB.used_sound_channels)
				channel_volume["[channel]"] = 100

			save_preferences()
			update_channel_volume(CHANNEL_MASTER_VOLUME)
			update_test_sound(master_changed = TRUE)
			on_mixer_volume_changed(changed_channel = CHANNEL_MASTER_VOLUME)
			return TRUE

		if("test_sound")
			var/channel_num = text2num(params["channel"])

			parent.mob.stop_sound_channel(CHANNEL_TEST_SOUND)
			test_sound_channels.Cut()

			if(!isnull(channel_num) && (channel_num in GLOB.used_sound_channels))
				var/sound_file
				var/vol = 100 // У некоторых звуков отличается параметр грокмости при воспроизведении, вытаскивать из каждого вызова перебор - это упрощение
				switch(channel_num)
					if(CHANNEL_MASTER_VOLUME)
						sound_file = 'sound/music/elevator/robocop-short.ogg'
					if(CHANNEL_SOUND_EFFECTS)
						sound_file = "sound/items/weapons/punch[rand(1,4)].ogg"
					if(CHANNEL_AMBIENCE)
						sound_file = "sound/ambience/general/ambigen[rand(1,14)].ogg"
					if(CHANNEL_WEATHER)
						sound_file = pick(
							"sound/ambience/weather/rain/[pick(flist("sound/ambience/weather/rain/"))]",
							"sound/ambience/weather/snowstorm/[pick(flist("sound/ambience/weather/snowstorm/"))]",
							"sound/ambience/weather/ashstorm/outside/[pick(flist("sound/ambience/weather/ashstorm/outside/"))]",
						)
					if(CHANNEL_MACHINERY)
						sound_file = 'sound/machines/mining/refinery.ogg'
					if(CHANNEL_FOOTSTEPS)
						sound_file = "sound/effects/footstep/[pick(flist("sound/effects/footstep/"))]"
					if(CHANNEL_MOB_SOUNDS)
						sound_file = "sound/mobs/non-humanoids/tourist/[pick(flist("sound/mobs/non-humanoids/tourist/"))]"
						vol = 50
					if(CHANNEL_MOB_EMOTES)
						sound_file = "sound/mobs/humanoids/human/laugh/[pick(flist("sound/mobs/humanoids/human/laugh/"))]"
						vol = 50
					if(CHANNEL_VOICES)
						sound_file = 'sound/runtime/chatter/griffin_10.ogg'
						vol = 40
					if(CHANNEL_TTS)
						sound_file = 'sound/runtime/chatter/griffin_10.ogg'
						vol = 40
					if(CHANNEL_SHUTTLES)
						sound_file = "sound/runtime/hyperspace/[pick(flist("sound/runtime/hyperspace/"))]"
						//vol = 100
					if(CHANNEL_RADIO)
						sound_file = "sound/items/radio/[pick(flist("sound/items/radio/"))]"
					if(CHANNEL_UI)
						sound_file = "sound/machines/arcade/[pick(flist("sound/machines/arcade/"))]"
					if(CHANNEL_RINGTONES)
						sound_file = 'sound/machines/beep/twobeep.ogg'
					if(CHANNEL_VOX)
						sound_file = "sound/announcer/vox_fem/[pick(flist("sound/announcer/vox_fem/"))]"
					if(CHANNEL_ANNOUNCEMENTS)
						sound_file = 'sound/announcer/announcement/announce.ogg'
					if(CHANNEL_STORYTELLER)
						sound_file = 'sound/announcer/announcement/announce.ogg'
					if(CHANNEL_HEARTBEAT)
						sound_file = 'sound/effects/health/fastbeat.ogg'
					if(CHANNEL_BREATH)
						sound_file = "sound/mobs/humanoids/breathing/[pick(flist("sound/mobs/humanoids/breathing/"))]"
						vol = 7
					if(CHANNEL_LOBBYMUSIC)
						sound_file = 'sound/music/antag/spy.ogg'
					if(CHANNEL_EVENT_MUSIC)
						sound_file = 'sound/music/antag/bloodcult/bloodcult_halos.ogg'
					// if(CHANNEL_JUKEBOX)
					if(CHANNEL_INSTRUMENTS)
						sound_file = 'sound/music/sisyphus/sisyphus.ogg'
					if(CHANNEL_ADMIN)
						sound_file = 'sound/effects/adminhelp.ogg'
						//vol = 100
					if(CHANNEL_ADMIN_SOUNDS)
						sound_file = 'sound/music/lobby_music/title0.ogg'
					else
						sound_file = 'sound/machines/ping.ogg'

				test_sound_channels["[CHANNEL_TEST_SOUND]"] = list("mixer_channel" = channel_num, "base_volume" = vol)
				parent.mob.playsound_local(get_turf(parent.mob), sound_file, vol, channel = CHANNEL_TEST_SOUND, mixer_channel = channel_num)

			return TRUE

		if("stop_all_sounds")
			parent.mob.stop_sound_channel(CHANNEL_TEST_SOUND)
			test_sound_channels.Cut()
			return TRUE
		// [/HORIZON-ADD]

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/delegation = preference_middleware.action_delegations[action]
		if (!isnull(delegation))
			return call(preference_middleware, delegation)(params, usr)

	return FALSE

/datum/preferences/ui_close(mob/user)
	save_character()
	save_preferences()
	QDEL_NULL(character_preview_view)
	cached_character_profiles = null

	// [HORIZON-ADD] Master_Sounds
	if(test_sound_channels)
		user.stop_sound_channel(CHANNEL_TEST_SOUND)
		test_sound_channels.Cut()
	// [/HORIZON-ADD]

/datum/preferences/Topic(href, list/href_list)
	. = ..()
	if (.)
		return

	if (href_list["open_keybindings"])
		current_window = PREFERENCE_TAB_KEYBINDINGS
		update_static_data(usr)
		ui_interact(usr)
		return TRUE

/datum/preferences/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, null, src)
	character_preview_view.generate_view("character_preview_[REF(character_preview_view)]")
	character_preview_view.update_body()

	return character_preview_view

/datum/preferences/proc/compile_character_preferences(mob/user)
	var/list/preferences = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.is_accessible(src))
			continue

		var/value = read_preference(preference.type)
		var/data = preference.compile_ui_data(user, value)

		LAZYINITLIST(preferences[preference.category])
		preferences[preference.category][preference.savefile_key] = data


	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/list/append_character_preferences = preference_middleware.get_character_preferences(user)
		if (isnull(append_character_preferences))
			continue

		for (var/category in append_character_preferences)
			if (category in preferences)
				preferences[category] += append_character_preferences[category]
			else
				preferences[category] = append_character_preferences[category]

	return preferences

/// Applies all PREFERENCE_PLAYER preferences
/datum/preferences/proc/apply_all_client_preferences()
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_PLAYER)
			continue

		value_cache -= preference.type
		preference.apply_to_client(parent, read_preference(preference.type))

/// A preview of a character for use in the preferences menu
/atom/movable/screen/map_view/char_preview
	name = "character_preview"

	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body
	/// The preferences this refers to
	var/datum/preferences/preferences
	/// Whether we show current job clothes or nude/loadout only
	var/show_job_clothes = TRUE

/atom/movable/screen/map_view/char_preview/Initialize(mapload, datum/hud/hud_owner, datum/preferences/preferences)
	. = ..()
	src.preferences = preferences

/atom/movable/screen/map_view/char_preview/Destroy()
	QDEL_NULL(body)
	preferences?.character_preview_view = null
	preferences = null
	return ..()

/// Updates the currently displayed body
/atom/movable/screen/map_view/char_preview/proc/update_body()
	if (isnull(body))
		create_body()
	else
		body.wipe_state()

	appearance = preferences.render_new_preview_appearance(body, show_job_clothes)

/atom/movable/screen/map_view/char_preview/proc/create_body()
	QDEL_NULL(body)

	body = new

/datum/preferences/proc/create_character_profiles()
	var/list/profiles = list()

	for (var/index in 1 to max_save_slots)
		// It won't be updated in the savefile yet, so just read the name directly
		if (index == default_slot)
			profiles += read_preference(/datum/preference/name/real_name)
			continue

		var/tree_key = "character[index]"
		var/save_data = savefile.get_entry(tree_key)
		var/name = save_data?["real_name"]

		if (isnull(name))
			profiles += null
			continue

		profiles += name

	return profiles

/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH)
		var/datum/job/overflow_role = SSjob.overflow_role
		var/overflow_role_title = initial(overflow_role.title)

		for(var/other_job, other_level in job_preferences)
			if(other_level == JP_HIGH)
				// Overflow role needs to go to NEVER, not medium!
				if(other_job == overflow_role_title)
					job_preferences -= other_job
				else
					job_preferences[other_job] = JP_MEDIUM

	if(isnull(level))
		job_preferences -= job.title
	else
		job_preferences[job.title] = level

	return TRUE

/datum/preferences/proc/GetQuirkBalance()
	var/bal = SSquirks.default_quirk_points
	for(var/V in all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		bal -= initial(T.value)
	return bal

/datum/preferences/proc/GetPositiveQuirkCount()
	. = 0
	for(var/q in all_quirks)
		if(SSquirks.quirk_points[q] > 0)
			.++

/datum/preferences/proc/validate_quirks()
	var/datum/species/species_type = read_preference(/datum/preference/choiced/species)
	var/list/quirks_removed
	for(var/quirk_name in all_quirks)
		var/quirk_path = SSquirks.quirks[quirk_name]
		var/datum/quirk/quirk_prototype = SSquirks.quirk_prototypes[quirk_path]
		if(!quirk_prototype.is_species_appropriate(species_type))
			all_quirks -= quirk_name
			LAZYADD(quirks_removed, quirk_name)
	var/list/feedback
	if(LAZYLEN(quirks_removed))
		LAZYADD(feedback, "The following quirks are incompatible with your species:")
		LAZYADD(feedback, quirks_removed)
	if(SSquirks.points_enabled && GetQuirkBalance() < 0)
		LAZYADD(feedback, "Your quirks have been reset.")
		all_quirks = list()
	if(LAZYLEN(feedback))
		to_chat(parent, boxed_message(span_greentext(feedback.Join("\n"))))


/**
 * Safely read a given preference datum from a given client.
 *
 * Reads the given preference datum from the given client, and guards against null client and null prefs.
 * The client object is fickle and can go null at times, so use this instead of read_preference() if you
 * want to ensure no runtimes.
 *
 * returns client.prefs.read_preference(prefs_to_read) or FALSE if something went wrong.
 *
 * Arguments:
 * * client/prefs_holder - the client to read the pref from
 * * datum/preference/pref_to_read - the type of preference datum to read.
 */
/proc/safe_read_pref(client/prefs_holder, datum/preference/pref_to_read)
	if(!prefs_holder)
		return FALSE
	if(prefs_holder && !prefs_holder?.prefs)
		stack_trace("[prefs_holder?.mob] ([prefs_holder?.ckey]) had null prefs, which shouldn't be possible!")
		return FALSE

	return prefs_holder?.prefs.read_preference(pref_to_read)

/**
 * Get the given client's chat toggle prefs.
 *
 * Getter function for prefs.chat_toggles which guards against null client and null prefs.
 * The client object is fickle and can go null at times, so use this instead of directly accessing the var
 * if you want to ensure no runtimes.
 *
 * returns client.prefs.chat_toggles or FALSE if something went wrong.
 *
 * Arguments:
 * * client/prefs_holder - the client to get the chat_toggles pref from.
 */
/proc/get_chat_toggles(client/target)
	if(ismob(target))
		var/mob/target_mob = target
		target = target_mob.client

	if(isnull(target))
		return NONE

	var/datum/preferences/preferences = target.prefs
	if(isnull(preferences))
		stack_trace("[key_name(target)] preference datum was null")
		return NONE

	return preferences.chat_toggles

/// Sanitizes the preferences, applies the randomization prefs, and then applies the preference to the human mob.
/datum/preferences/proc/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	apply_character_randomization_prefs(is_antag)
	apply_prefs_to(character, icon_updates)

/**
 * Applies the given preferences to a human mob.
 *
 * Arguments:
 * * character - The human mob to apply the preferences to
 * * icon_updates - Whether to update the mob's icons after applying preferences.
 * Is often skipped to save processing when an update will happen later anyway.
 * * do_not_apply - A list of preference types to skip when applying preferences.
 */
/datum/preferences/proc/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, list/do_not_apply)
	character.dna.features = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue
		if (preference.type in do_not_apply)
			continue

		preference.apply_to_human(character, read_preference(preference.type), src)

	character.dna.real_name = character.real_name

	if(icon_updates)
		character.icon_render_keys = list()
		character.update_body(is_creating = TRUE)

	SEND_SIGNAL(character, COMSIG_HUMAN_PREFS_APPLIED)

/// Returns whether the parent mob should have the random hardcore settings enabled. Assumes it has a mind.
/datum/preferences/proc/should_be_random_hardcore(datum/job/job, datum/mind/mind)
	if(!read_preference(/datum/preference/toggle/random_hardcore))
		return FALSE
	if(job.job_flags & JOB_HEAD_OF_STAFF) //No heads of staff
		return FALSE
	for(var/datum/antagonist/antag as anything in mind.antag_datums)
		if(antag.get_team()) //No team antags
			return FALSE
	return TRUE

/// Inverts the key_bindings list such that it can be used for key_bindings_by_key
/datum/preferences/proc/get_key_bindings_by_key(list/key_bindings)
	var/list/output = list()

	for (var/action in key_bindings)
		for (var/key in key_bindings[action])
			LAZYADD(output[key], action)

	return output

/// Returns the default `randomise` variable ouptut
/datum/preferences/proc/get_default_randomization()
	var/list/default_randomization = list()

	for (var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/preference = GLOB.preference_entries_by_key[preference_key]
		if (preference.is_randomizable() && preference.randomize_by_default)
			default_randomization[preference_key] = RANDOM_ENABLED

	return default_randomization

// [HORIZON-ADD] Master_Sounds
/datum/preferences/proc/update_test_sound(mixer_channel_changed = null, master_changed = FALSE)
	var/list/test_info = test_sound_channels["[CHANNEL_TEST_SOUND]"]
	if(!test_info)
		return

	var/test_mixer_channel = test_info["mixer_channel"]
	var/should_update = FALSE

	if(master_changed)
		should_update = TRUE
	else if(mixer_channel_changed && test_mixer_channel == mixer_channel_changed)
		should_update = TRUE

	if(!should_update)
		return

	var/base_volume = test_info["base_volume"]
	var/new_vol = calculate_mixed_volume(parent, base_volume, test_mixer_channel)
	var/sound/new_sound = sound(null, channel = CHANNEL_TEST_SOUND, volume = new_vol)
	new_sound.status = SOUND_UPDATE
	SEND_SOUND(parent.mob, new_sound)
// [/HORIZON-ADD]
