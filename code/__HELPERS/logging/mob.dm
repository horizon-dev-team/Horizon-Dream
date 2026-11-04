/**
 * Logs a message to the mob_tags log, including the mobs tag
 * Arguments:
 * * text - text to log.
 */
/mob/proc/log_mob_tag(text, list/data)
	logger.Log(LOG_CATEGORY_DEBUG_MOBTAG, text, data)

/proc/log_silicon(text, list/data)
	logger.Log(LOG_CATEGORY_SILICON, text, data)


/// Logs a message in a mob's individual log, and in the global logs as well if log_globally is true. target — optional atom stored for LogViewer filtering.
/mob/log_message(message, message_type, color = null, log_globally = TRUE, list/data, atom/target = null) // [HORIZON-EDIT] ADMIN-TICKETS
	if(!LAZYLEN(message))
		stack_trace("Empty message")
		return

	// Cannot use the list as a map if the key is a number, so we stringify it (thank you BYOND)
	var/smessage_type = num2text(message_type, MAX_BITFLAG_DIGITS)

	if(HAS_CONNECTED_PLAYER(src))
		if(!islist(persistent_client.logging[smessage_type]))
			persistent_client.logging[smessage_type] = list()

	if(!islist(logging[smessage_type]))
		logging[smessage_type] = list()

	// [HORIZON-ADD] ADMIN-TICKETS
	var/log_time = server_timestamp("hh:mm:ss")
	var/log_who = key_name_and_tag(src)
	var/log_where = loc_name(src)
	var/log_type_name = log_type_to_name(message_type)
	var/mob/living/L = src
	var/log_health = null
	if(istype(L) && (message_type == LOG_ATTACK || message_type == LOG_VICTIM))
		log_health = "[L.health]"

	var/log_state = "alive"
	switch(src.stat)
		if(SOFT_CRIT, HARD_CRIT)
			log_state = "critical"
		if(DEAD)
			log_state = "dead"
	// [/HORIZON-ADD]

	var/colored_message = message
	if(color)
		if(color[1] == "#")
			colored_message = "<font color=[color]>[message]</font>"
		else
			colored_message = "<font color='[color]'>[message]</font>"

	//This makes readability a bit better for admins.
	switch(message_type)
		if(LOG_WHISPER)
			colored_message = "(WHISPER) [colored_message]"
		if(LOG_OOC)
			colored_message = "(OOC) [colored_message]"
		if(LOG_ASAY)
			colored_message = "(ASAY) [colored_message]"
		if(LOG_EMOTE)
			colored_message = "(EMOTE) [colored_message]"
		if(LOG_RADIO_EMOTE)
			colored_message = "(RADIOEMOTE) [colored_message]"

// [HORIZON-EDIT] ADMIN-TICKETS
	var/list/entry = list(
		"time" = log_time,
		"timestamp" = world.time,
		"who" = log_who,
		"what" = colored_message,
		"where" = log_where,
		"type" = log_type_name,
		"type_flag" = message_type,
		"state" = log_state,
		"ckey" = ckey,
		"color" = color,
		"health" = log_health,
		"target_name" = target?.name,
		"target_key" = ismob(target) ? target:ckey : null,
		"target_ref" = target ? REF(target) : null,
	)

	logging[smessage_type] += list(entry)
	trim_individual_log(logging[smessage_type])

	if(HAS_CONNECTED_PLAYER(src))
		persistent_client.logging[smessage_type] += list(entry)
		trim_individual_log(persistent_client.logging[smessage_type])

	..(message, message_type, color, log_globally, data)

/mob/proc/trim_individual_log(list/entries)
	if(length(entries) <= MOB_INDIVIDUAL_LOG_MAX)
		return
	entries.Cut(1, round(MOB_INDIVIDUAL_LOG_MAX / 4) + 1)
// [HORIZON-EDIT] ADMIN-TICKETS
