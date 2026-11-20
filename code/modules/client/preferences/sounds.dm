// [HORIZON-EDIT] Master_Sounds
// Volumes are now configured per channel in the Volume Mixer tab.
/// Controls hearing the combat mode sound
/datum/preference/toggle/sound_combatmode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_combatmode"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_tts
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_tts/init_possible_values()
	return list(TTS_SOUND_ENABLED, TTS_SOUND_BLIPS, TTS_SOUND_OFF)

/datum/preference/choiced/sound_tts/create_default_value()
	return TTS_SOUND_ENABLED

/datum/preference/choiced/sound_tts_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_radio"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_tts_radio/init_possible_values()
	return list(TTS_SOUND_ALL_RADIO, TTS_SOUND_DEPARTMENTAL_RADIO, TTS_SOUND_NO_RADIO)

/datum/preference/choiced/sound_tts_radio/create_default_value()
	return TTS_SOUND_ALL_RADIO

/datum/preference/toggle/sound_tts_hear_self_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_hear_self_radio"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE // turn this on at your own peril

/datum/preference/choiced/sound_achievement
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_achievement"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_achievement/init_possible_values()
	return list(CHEEVO_SOUND_PING, CHEEVO_SOUND_JINGLE, CHEEVO_SOUND_TADA, CHEEVO_SOUND_OFF)

/datum/preference/choiced/sound_achievement/create_default_value()
	return CHEEVO_SOUND_PING

/datum/preference/choiced/sound_achievement/apply_to_client_updated(client/client, value)
	var/sound/sound_to_send = LAZYACCESS(GLOB.achievement_sounds, value)
	if(sound_to_send)
		SEND_SOUND(client.mob, sound_to_send)

/// Choice of which ghost poll prompt to use
/datum/preference/choiced/sound_ghost_poll_prompt
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ghost_poll_prompt"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_ghost_poll_prompt/create_default_value()
	return GHOST_POLL_PROMPT_1

/datum/preference/choiced/sound_ghost_poll_prompt/init_possible_values()
	return list(GHOST_POLL_PROMPT_DISABLED, GHOST_POLL_PROMPT_1, GHOST_POLL_PROMPT_2)

/// Volume which ghost poll prompts are played at
/datum/preference/numeric/sound_ghost_poll_prompt_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ghost_poll_prompt_volume"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/// default value is max/2 because 100 1x modifier, while 200 is 2x
/datum/preference/numeric/sound_ghost_poll_prompt_volume/create_default_value()
	return maximum/2
// [/HORIZON-EDIT]
