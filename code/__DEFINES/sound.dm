// [HORIZON-EDIT] Master_Sounds
//max channel is 1024. Only go lower from here, because byond tends to pick the first available channel to play sounds on
#define CHANNEL_MASTER_VOLUME 1024
#define CHANNEL_SOUND_EFFECTS 1023 // Everything gameplay affecting and not local (Explosion, fighting, doors/shutters, magic)

#define CHANNEL_AMBIENCE 1022
#define CHANNEL_WEATHER 1021

#define CHANNEL_MACHINERY 1020 // Purely cosmetic sounds of machinery (Buzzing, printing, typing)
#define CHANNEL_FOOTSTEPS 1019
#define CHANNEL_MOB_SOUNDS 1018 // Something that can be important, but not purely innocent (Screaming(damage react), )
#define CHANNEL_MOB_EMOTES 1017 // Anything not gameplay/combat at all from carbons and animals (screaming, moo)
#define CHANNEL_RADIO 1016
#define CHANNEL_VOICES 1015 // Sounds coming from creatures when talking (Mostly used in blubber)
#define CHANNEL_SHUTTLES 1014 // Anything shuttle related (Descending, ascending, flying)

#define CHANNEL_UI 1013 // UI sounds, Machinery interface (PDA, Consoles) and informative playsound_local()
#define CHANNEL_RINGTONES 1012 // Notifications from devices
#define CHANNEL_VOX 1011 // AI vox system (ass blast usa)
#define CHANNEL_STORYTELLER 1010
#define CHANNEL_ANNOUNCEMENTS 1009 // Cap/Corp announcemets
#define CHANNEL_HEARTBEAT 1008 // Sound channel for personal heartbeats
#define CHANNEL_BREATH 1007 // Something that can be important, but not purely innocent (Screaming(damage react), )

#define CHANNEL_LOBBYMUSIC 1006 // Only lobby music
#define CHANNEL_EVENT_MUSIC 1005 // Gameplay music played while fighting a strong enemy, heretic/bloodcult ascending
#define CHANNEL_JUKEBOX 1004 // Any portable music player like boomboxes, jukeboxes, radios
#define CHANNEL_INSTRUMENTS 1003 // MIDI shit from music instruments or In-game ambient music (elevator music)

#define CHANNEL_ADMIN 1002 // Bwoinks, pms
#define CHANNEL_ADMIN_SOUNDS 1001 // Admin music mostly

#define CHANNEL_TEST_SOUND 1000 // Channel just for testing sounds in preferences. Do not use

#define CHANNEL_TTS 999 // Text to speech (spoken words and radio TTS). Kept separate from CHANNEL_RADIO so muting TTS doesn't mute radio noise

//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED
#define CHANNEL_HIGHEST_AVAILABLE 980
// [/HORIZON-EDIT]

#define MAX_INSTRUMENT_CHANNELS (128 * 6)

/* Calculates the volume of a sound based on distance
 *
 * https://www.desmos.com/calculator/ing6lxgd0m Update this when changed please
 *
 * Arguments:
 * * volume: The initial volume of the sound being played
 * * distance: How far away the sound is in tiles from the source
 * * falloff_distance: Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 * * falloff_exponent: Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * Returns: The max distance of a sound based on audible volume range
 */
#define CALCULATE_SOUND_VOLUME_RATIO(volume, distance, max_distance, falloff_distance, falloff_exponent)\
	((max(distance - falloff_distance, 0) / (max(max_distance, distance) - falloff_distance)) ** (1 / falloff_exponent))

///Default range of a sound.
#define SOUND_RANGE 15
#define MEDIUM_RANGE_SOUND_EXTRARANGE -3
///default extra range for sounds considered to be quieter
#define SHORT_RANGE_SOUND_EXTRARANGE -7
///The range deducted from sound range for things that are considered silent / sneaky
#define SILENCED_SOUND_EXTRARANGE -10
///Percentage of sound's range where no falloff is applied
#define SOUND_DEFAULT_FALLOFF_DISTANCE 0 //Disabled because it doesn't actually have a nice effect, it just makes the jump to fall-off more shocking. maybe delete
///The default exponent of sound falloff
#define SOUND_FALLOFF_EXPONENT 2.5

#define SOUND_MINIMUM_PRESSURE 10

#define INTERACTION_SOUND_RANGE_MODIFIER -3
#define LIQUID_SLOSHING_SOUND_VOLUME 10
#define PICKUP_SOUND_VOLUME 15
#define DROP_SOUND_VOLUME 20
#define EQUIP_SOUND_VOLUME 30
#define HALFWAY_SOUND_VOLUME 50
#define BLOCK_SOUND_VOLUME 70
#define YEET_SOUND_VOLUME 90

#define AMBIENCE_GENERIC "generic"
#define AMBIENCE_HOLY "holy"
#define AMBIENCE_DANGER "danger"
#define AMBIENCE_RUINS "ruins"
#define AMBIENCE_ENGI "engi"
#define AMBIENCE_MINING "mining"
#define AMBIENCE_ICEMOON "icemoon"
#define AMBIENCE_MEDICAL "med"
#define AMBIENCE_VIROLOGY "viro"
#define AMBIENCE_SPOOKY "spooky"
#define AMBIENCE_SPACE "space"
#define AMBIENCE_MAINT "maint"
#define AMBIENCE_AWAY "away"
#define AMBIENCE_REEBE "reebe" //unused
#define AMBIENCE_CREEPY "creepy" //not to be confused with spooky

//default byond sound environments
#define SOUND_ENVIRONMENT_NONE -1
#define SOUND_ENVIRONMENT_GENERIC 0
#define SOUND_ENVIRONMENT_PADDED_CELL 1
#define SOUND_ENVIRONMENT_ROOM 2
#define SOUND_ENVIRONMENT_BATHROOM 3
#define SOUND_ENVIRONMENT_LIVINGROOM 4
#define SOUND_ENVIRONMENT_STONEROOM 5
#define SOUND_ENVIRONMENT_AUDITORIUM 6
#define SOUND_ENVIRONMENT_CONCERT_HALL 7
#define SOUND_ENVIRONMENT_CAVE 8
#define SOUND_ENVIRONMENT_ARENA 9
#define SOUND_ENVIRONMENT_HANGAR 10
#define SOUND_ENVIRONMENT_CARPETED_HALLWAY 11
#define SOUND_ENVIRONMENT_HALLWAY 12
#define SOUND_ENVIRONMENT_STONE_CORRIDOR 13
#define SOUND_ENVIRONMENT_ALLEY 14
#define SOUND_ENVIRONMENT_FOREST 15
#define SOUND_ENVIRONMENT_CITY 16
#define SOUND_ENVIRONMENT_MOUNTAINS 17
#define SOUND_ENVIRONMENT_QUARRY 18
#define SOUND_ENVIRONMENT_PLAIN 19
#define SOUND_ENVIRONMENT_PARKING_LOT 20
#define SOUND_ENVIRONMENT_SEWER_PIPE 21
#define SOUND_ENVIRONMENT_UNDERWATER 22
#define SOUND_ENVIRONMENT_DRUGGED 23
#define SOUND_ENVIRONMENT_DIZZY 24
#define SOUND_ENVIRONMENT_PSYCHOTIC 25
//If we ever make custom ones add them here
#define SOUND_ENVIROMENT_PHASED list(1.8, 0.5, -1000, -4000, 0, 5, 0.1, 1, -15500, 0.007, 2000, 0.05, 0.25, 1, 1.18, 0.348, -5, 2000, 250, 0, 3, 100, 63)

//"sound areas": easy way of keeping different types of areas consistent.
#define SOUND_AREA_STANDARD_STATION SOUND_ENVIRONMENT_PARKING_LOT
#define SOUND_AREA_LARGE_ENCLOSED SOUND_ENVIRONMENT_QUARRY
#define SOUND_AREA_SMALL_ENCLOSED SOUND_ENVIRONMENT_BATHROOM
#define SOUND_AREA_TUNNEL_ENCLOSED SOUND_ENVIRONMENT_STONEROOM
#define SOUND_AREA_LARGE_SOFTFLOOR SOUND_ENVIRONMENT_CARPETED_HALLWAY
#define SOUND_AREA_MEDIUM_SOFTFLOOR SOUND_ENVIRONMENT_LIVINGROOM
#define SOUND_AREA_SMALL_SOFTFLOOR SOUND_ENVIRONMENT_ROOM
#define SOUND_AREA_ASTEROID SOUND_ENVIRONMENT_CAVE
#define SOUND_AREA_SPACE SOUND_ENVIRONMENT_UNDERWATER
#define SOUND_AREA_LAVALAND SOUND_ENVIRONMENT_MOUNTAINS
#define SOUND_AREA_ICEMOON SOUND_ENVIRONMENT_CAVE
#define SOUND_AREA_WOODFLOOR SOUND_ENVIRONMENT_CITY


///Announcer audio keys
#define ANNOUNCER_AIMALF "announcer_aimalf"
#define ANNOUNCER_ALIENS "announcer_aliens"
#define ANNOUNCER_ANIMES "announcer_animes"
#define ANNOUNCER_GRANOMALIES "announcer_granomalies"
#define ANNOUNCER_INTERCEPT "announcer_intercept"
#define ANNOUNCER_IONSTORM "announcer_ionstorm"
#define ANNOUNCER_METEORS "announcer_meteors"
#define ANNOUNCER_OUTBREAK5 "announcer_outbreak5"
#define ANNOUNCER_OUTBREAK7 "announcer_outbreak7"
#define ANNOUNCER_POWEROFF "announcer_poweroff"
#define ANNOUNCER_POWERON "announcer_poweron"
#define ANNOUNCER_RADIATION "announcer_radiation"
#define ANNOUNCER_SHUTTLECALLED "announcer_shuttlecalled"
#define ANNOUNCER_SHUTTLEDOCK "announcer_shuttledock"
#define ANNOUNCER_SHUTTLERECALLED "announcer_shuttlerecalled"
#define ANNOUNCER_SPANOMALIES "announcer_spanomalies"

/// Global list of all of our announcer keys.
GLOBAL_LIST_INIT(announcer_keys, list(
	ANNOUNCER_AIMALF,
	ANNOUNCER_ALIENS,
	ANNOUNCER_ANIMES,
	ANNOUNCER_GRANOMALIES,
	ANNOUNCER_INTERCEPT,
	ANNOUNCER_IONSTORM,
	ANNOUNCER_METEORS,
	ANNOUNCER_OUTBREAK5,
	ANNOUNCER_OUTBREAK7,
	ANNOUNCER_POWEROFF,
	ANNOUNCER_POWERON,
	ANNOUNCER_RADIATION,
	ANNOUNCER_SHUTTLECALLED,
	ANNOUNCER_SHUTTLEDOCK,
	ANNOUNCER_SHUTTLERECALLED,
	ANNOUNCER_SPANOMALIES,
))

// Standard is 44.1khz
#define MIN_EMOTE_PITCH 40000
#define MAX_EMOTE_PITCH 48000
// ~0.6 - 1.4 at 0.12
#define EMOTE_TTS_PITCH_MULTIPLIER 0.12
