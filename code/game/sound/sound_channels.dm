GLOBAL_LIST_INIT(used_sound_channels, list(
	CHANNEL_MASTER_VOLUME,
	CHANNEL_SOUND_EFFECTS,
	CHANNEL_AMBIENCE,
	CHANNEL_WEATHER,
	CHANNEL_MACHINERY,
	CHANNEL_FOOTSTEPS,
	CHANNEL_MOB_SOUNDS,
	CHANNEL_MOB_EMOTES,
	CHANNEL_VOICES,
	CHANNEL_SHUTTLES,
	CHANNEL_UI,
	CHANNEL_RINGTONES,
	CHANNEL_VOX,
	CHANNEL_ANNOUNCEMENTS,
	CHANNEL_STORYTELLER,
	CHANNEL_HEARTBEAT,
	CHANNEL_BREATH,
	CHANNEL_LOBBYMUSIC,
	CHANNEL_EVENT_MUSIC,
	CHANNEL_JUKEBOX,
	CHANNEL_INSTRUMENTS,
	CHANNEL_ADMIN,
	CHANNEL_ADMIN_SOUNDS,
	CHANNEL_RADIO,
	CHANNEL_TTS,
))

GLOBAL_LIST_INIT(proxy_sound_channels, list(
	CHANNEL_SOUND_EFFECTS,
	CHANNEL_FOOTSTEPS,
	CHANNEL_WEATHER,
	CHANNEL_MACHINERY,
	CHANNEL_INSTRUMENTS,
	CHANNEL_MOB_SOUNDS,
	CHANNEL_MOB_EMOTES,
	CHANNEL_VOICES,
	CHANNEL_ADMIN_SOUNDS,
	CHANNEL_SHUTTLES,
))

GLOBAL_DATUM_INIT(cached_mixer_channels, /alist, alist())

/proc/guess_mixer_channel(soundin)
	var/sound_text_string
	if(istype(soundin, /sound))
		var/sound/bleh = soundin
		sound_text_string = "[bleh.file]"
	else
		sound_text_string = "[soundin]"
	if(GLOB.cached_mixer_channels[sound_text_string])
		return GLOB.cached_mixer_channels[sound_text_string]
	else if(findtext(sound_text_string, "effects/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else if(findtext(sound_text_string, "machines/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_MACHINERY
	else if(findtext(sound_text_string, "creatures/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_MOB_SOUNDS
	else if(findtext(sound_text_string, "announcer/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_VOX
	else if(findtext(sound_text_string, "ai/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_STORYTELLER
	else if(findtext(sound_text_string, "chatter/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_VOICES
	else if(findtext(sound_text_string, "items/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else if(findtext(sound_text_string, "weapons/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else if(findtext(sound_text_string, "hyperspace/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SHUTTLES
	else if(findtext(sound_text_string, "radio/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_RADIO
	else
		return FALSE

/// Calculates the "adjusted" volume for a user's volume mixer
/proc/calculate_mixed_volume(client/client, volume, mixer_channel)
	. = volume
	var/list/channels = client?.prefs?.channel_volume
	if(isnull(channels))
		return .
	. *= channels["[CHANNEL_MASTER_VOLUME]"] * 0.01
	if(isnull(mixer_channel) || !("[mixer_channel]" in channels))
		return .
	. *= channels["[mixer_channel]"] * 0.01
