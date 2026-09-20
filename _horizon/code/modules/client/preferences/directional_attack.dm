/// Boundary for how many z levels down to render properly before we start going cheapo mode
/datum/preference/choiced/directional_attack
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "directional_attack"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/directional_attack/init_possible_values()
	return list(DIRECTIONAL_ATTACK_ON, DIRECTIONAL_ATTACK_ONLY_MOBS, DIRECTIONAL_ATTACK_OFF)

/datum/preference/choiced/directional_attack/create_default_value()
	return DIRECTIONAL_ATTACK_ON
