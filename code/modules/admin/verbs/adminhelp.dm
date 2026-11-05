/// Client var used for returning the ahelp verb
/client/var/adminhelptimerid = 0
/// Client var used for tracking the ticket the (usually) not-admin client is dealing with
/client/var/datum/admin_help/current_ticket

GLOBAL_DATUM_INIT(ahelp_tickets, /datum/admin_help_tickets, new)

/**
 * # Adminhelp Ticket Manager
 */
/datum/admin_help_tickets
	/// The set of all active tickets
	var/list/active_tickets = list()
	/// The set of all closed tickets
	var/list/closed_tickets = list()
	/// The set of all resolved tickets
	var/list/resolved_tickets = list()

	var/obj/effect/statclick/ticket_list/astatclick = new(null, null, AHELP_ACTIVE)
	var/obj/effect/statclick/ticket_list/cstatclick = new(null, null, AHELP_CLOSED)
	var/obj/effect/statclick/ticket_list/rstatclick = new(null, null, AHELP_RESOLVED)

/datum/admin_help_tickets/Destroy()
	QDEL_LIST(active_tickets)
	QDEL_LIST(closed_tickets)
	QDEL_LIST(resolved_tickets)
	QDEL_NULL(astatclick)
	QDEL_NULL(cstatclick)
	QDEL_NULL(rstatclick)
	return ..()

/datum/admin_help_tickets/proc/TicketByID(id)
	var/list/lists = list(active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/J in I)
			var/datum/admin_help/AH = J
			if(AH.id == id)
				return J

/datum/admin_help_tickets/proc/TicketsByCKey(ckey)
	. = list()
	var/list/lists = list(active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/J in I)
			var/datum/admin_help/AH = J
			if(AH.initiator_ckey == ckey)
				. += AH

//private
/datum/admin_help_tickets/proc/ListInsert(datum/admin_help/new_ticket)
	var/list/ticket_list
	switch(new_ticket.state)
		if(AHELP_ACTIVE)
			ticket_list = active_tickets
		if(AHELP_CLOSED)
			ticket_list = closed_tickets
		if(AHELP_RESOLVED)
			ticket_list = resolved_tickets
		else
			CRASH("Invalid ticket state: [new_ticket.state]")
	var/num_closed = ticket_list.len
	if(num_closed)
		for(var/I in 1 to num_closed)
			var/datum/admin_help/AH = ticket_list[I]
			if(AH.id > new_ticket.id)
				ticket_list.Insert(I, new_ticket)
				return
	ticket_list += new_ticket

//opens the ticket listings for one of the 3 states
/datum/admin_help_tickets/proc/BrowseTickets(state)
	var/list/l2b
	var/title
	switch(state)
		if(AHELP_ACTIVE)
			l2b = active_tickets
			title = "Active Tickets"
		if(AHELP_CLOSED)
			l2b = closed_tickets
			title = "Closed Tickets"
		if(AHELP_RESOLVED)
			l2b = resolved_tickets
			title = "Resolved Tickets"
	if(!l2b)
		return
	var/list/dat = list("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>[title]</title></head>")
	dat += "<A href='byond://?_src_=holder;[HrefToken()];ahelp_tickets=[state]'>Refresh</A><br><br>"
	for(var/I in l2b)
		var/datum/admin_help/AH = I
		dat += "[span_adminnotice("[span_adminhelp("Ticket #[AH.id]")]: <A href='byond://?_src_=holder;[HrefToken()];ahelp=[REF(AH)];ahelp_action=ticket'>[AH.initiator_key_name]: [AH.name]</A>")]<br>"

	usr << browse(dat.Join(), "window=ahelp_list[state];size=600x480")

//Tickets statpanel
/datum/admin_help_tickets/proc/stat_entry()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	var/list/L = list()
	var/num_disconnected = 0
	L[++L.len] = list("Active Tickets:", "[astatclick.update("[active_tickets.len]")]", null, REF(astatclick))
	astatclick.update("[active_tickets.len]")
	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		if(AH.initiator)
			var/obj/effect/statclick/updated = AH.statclick.update()
			L[++L.len] = list("#[AH.id]. [AH.initiator_key_name]:", "[updated.name]", REF(AH))
		else
			++num_disconnected
	if(num_disconnected)
		L[++L.len] = list("Disconnected:", "[astatclick.update("[num_disconnected]")]", null, REF(astatclick))
	L[++L.len] = list("Closed Tickets:", "[cstatclick.update("[closed_tickets.len]")]", null, REF(cstatclick))
	L[++L.len] = list("Resolved Tickets:", "[rstatclick.update("[resolved_tickets.len]")]", null, REF(rstatclick))
	return L

//Reassociate still open ticket if one exists
/datum/admin_help_tickets/proc/ClientLogin(client/C)
	C.current_ticket = CKey2ActiveTicket(C.ckey)
	if(C.current_ticket)
		C.current_ticket.initiator = C
		C.current_ticket.AddInteraction("Client reconnected.", message_type = "system") // [HORIZON-EDIT] ADMIN-TICKETS
		SSblackbox.LogAhelp(C.current_ticket.id, "Reconnected", "Client reconnected", C.ckey)

//Dissasociate ticket
/datum/admin_help_tickets/proc/ClientLogout(client/C)
	if(C.current_ticket)
		var/datum/admin_help/T = C.current_ticket
		T.AddInteraction("Client disconnected.", message_type = "system") // [HORIZON-EDIT] ADMIN-TICKETS
		//Gotta async this cause clients only logout on destroy, and sleeping in destroy is disgusting
		INVOKE_ASYNC(SSblackbox, TYPE_PROC_REF(/datum/controller/subsystem/blackbox, LogAhelp), T.id, "Disconnected", "Client disconnected", C.ckey)
		T.initiator = null

//Get a ticket given a ckey
/datum/admin_help_tickets/proc/CKey2ActiveTicket(ckey)
	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		if(AH.initiator_ckey == ckey)
			return AH

//
//TICKET LIST STATCLICK
//

/obj/effect/statclick/ticket_list
	var/current_state

/obj/effect/statclick/ticket_list/Initialize(mapload, name, state)
	. = ..()
	current_state = state

// [HORIZON-EDIT] ADMIN-TICKETS
/obj/effect/statclick/ticket_list/Click()
	if (!check_rights_for(usr.client, R_ADMIN))
		message_admins("[key_name_admin(usr)] non-holder clicked on a ticket list statclick! ([src])")
		log_game("[key_name(usr)] non-holder clicked on a ticket list statclick! ([src])")
		return

	// GLOB.ahelp_tickets.BrowseTickets(current_state)
	if(usr.client.holder)
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/ticket_panel)
		to_chat(usr, span_notice("Accessing Ticket Panel... (Click <A href='byond://?_src_=admin_holder;[HrefToken()];ahelp_tickets=[current_state]'>here</A> for legacy view)"))
// [/HORIZON-EDIT]

//called by admin topic
/obj/effect/statclick/ticket_list/proc/Action()
	Click()

#define WEBHOOK_NONE 0
#define WEBHOOK_URGENT 1
#define WEBHOOK_NON_URGENT 2

/**
 * # Adminhelp Ticket
 */
/datum/admin_help
	/// Unique ID of the ticket
	var/id
	/// The current name of the ticket
	var/name
	/// The current state of the ticket
	var/state = AHELP_ACTIVE
	/// The time at which the ticket was opened
	var/opened_at
	/// The time at which the ticket was closed
	var/closed_at
	/// Semi-misnomer, it's the person who ahelped/was bwoinked
	var/client/initiator
	/// The ckey of the initiator
	var/initiator_ckey
	/// The key name of the initiator
	var/initiator_key_name
	/// If any admins were online when the ticket was initialized
	var/heard_by_no_admins = FALSE
	/// The collection of interactions with this ticket. Use AddInteraction() or, preferably, admin_ticket_log()
	var/list/ticket_interactions
	/// Statclick holder for the ticket
	var/obj/effect/statclick/ahelp/statclick
	/// Static counter used for generating each ticket ID
	var/static/ticket_counter = 0
	/// The list of clients currently responding to the opening ticket before it gets a response
	var/list/opening_responders
	/// Whether this ahelp has sent a webhook or not, and what type
	var/webhook_sent = WEBHOOK_NONE
	/// List of player interactions
	var/list/player_interactions
	/// List of admin ckeys that are involved, like through responding
	var/list/admins_involved = list()
	/// Has the player replied to this ticket yet?
	var/player_replied = FALSE
	// [HORIZON-ADD] ADMIN-TICKETS
	/// The current subject of the ticket
	var/subject = ""
	/// Which admin has marked this ahelp?
	var/marked_admin
	/// What was the first message sent by the player?
	var/initial_message = ""
	/// What was the latest message sent by the player?
	var/latest_message = ""
	/// Time activity tracking for the ticket panel
	var/list/time_activity = list("opened_at" = null, "closed_at" = null)
	// [/HORIZON-ADD]

/**
 * Call this on its own to create a ticket, don't manually assign current_ticket
 *
 * Arguments:
 * * msg_raw - The first message of this admin_help: used for the initial title of the ticket
 * * is_bwoink - Boolean operator, TRUE if this ticket was started by an admin PM
 */
/datum/admin_help/New(msg_raw, client/C, is_bwoink, urgent = FALSE)
	//clean the input msg
	var/msg = sanitize(copytext_char(msg_raw, 1, MAX_MESSAGE_LEN))
	if(!msg || !C || !C.mob)
		qdel(src)
		return

	id = ++ticket_counter
	opened_at = world.time
	time_activity["opened_at"] = round_timestamp(wtime = opened_at) // [HORIZON-EDIT] ADMIN-TICKETS

	name = copytext_char(msg, 1, 100)
	initial_message = msg // [HORIZON-EDIT] ADMIN-TICKETS

	initiator = C
	initiator_ckey = initiator.ckey
	initiator_key_name = key_name(initiator, FALSE, TRUE)
	if(initiator.current_ticket) //This is a bug
		stack_trace("Multiple ahelp current_tickets")
		initiator.current_ticket.AddInteraction("Ticket erroneously left open by code", message_type = "system") // [HORIZON-EDIT] ADMIN-TICKETS
		initiator.current_ticket.Close()
	initiator.current_ticket = src

	TimeoutVerb()

	statclick = new(null, src)
	ticket_interactions = list()
	player_interactions = list()

	if(is_bwoink) // [HORIZON-EDIT] ADMIN-TICKETS
		AddInteraction(span_blue("[key_name_admin(usr)] PM'd [LinkedReplyName()]"),
		plain_message = "[initiator.ckey] PM'd [initiator_key_name]")
		message_admins(span_blue("Ticket [TicketHref("#[id]")] created"))
	else // [/HORIZON-EDIT]
		MessageNoRecipient(msg_raw, urgent)
		send_message_to_tgs(msg, urgent)
	GLOB.ahelp_tickets.active_tickets += src
	defer_ticket_panel_update() // [HORIZON-ADD] ADMIN-TICKETS

/datum/admin_help/proc/format_embed_discord(message)
	var/datum/discord_embed/embed = new()
	embed.title = "Ticket #[id]"
	embed.description = "<byond://[world.internet_address]:[world.port]>"
	embed.author = key_name(initiator_ckey)
	var/round_state
	switch(SSticker.current_state)
		if(GAME_STATE_STARTUP, GAME_STATE_PREGAME, GAME_STATE_SETTING_UP)
			round_state = "Round has not started"
		if(GAME_STATE_PLAYING)
			round_state = "Round is ongoing."
			if(SSshuttle.emergency.getModeStr())
				round_state += "\n[SSshuttle.emergency.getModeStr()]: [SSshuttle.emergency.getTimerStr()]"
				if(SSticker.emergency_reason)
					round_state += ", Shuttle call reason: [SSticker.emergency_reason]"
		if(GAME_STATE_FINISHED)
			round_state = "Round has ended"
	var/list/admin_counts = get_admin_counts(R_BAN)
	var/stealth_admins = jointext(admin_counts["stealth"], ", ")
	var/afk_admins = jointext(admin_counts["afk"], ", ")
	var/other_admins = jointext(admin_counts["noflags"], ", ")
	var/admin_text = ""
	var/player_count = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]"
	if(stealth_admins)
		admin_text += "**Stealthed**: [stealth_admins]\n"
	if(afk_admins)
		admin_text += "**AFK**: [afk_admins]\n"
	if(other_admins)
		admin_text += "**Lacks +BAN**: [other_admins]\n"
	embed.fields = list(
		"CKEY" = initiator_ckey,
		"PLAYERS" = player_count,
		"ROUND STATE" = round_state,
		"ROUND ID" = GLOB.round_id,
		"ROUND TIME" = round_timestamp(),
		"MESSAGE" = message,
		"ADMINS" = admin_text,
	)
	if(CONFIG_GET(string/adminhelp_ahelp_link))
		var/ahelp_link = replacetext(CONFIG_GET(string/adminhelp_ahelp_link), "$RID", GLOB.round_id)
		ahelp_link = replacetext(ahelp_link, "$TID", id)
		embed.url = ahelp_link
	return embed

/datum/admin_help/proc/send_message_to_tgs(message, urgent = FALSE)
	var/message_to_send = message

	if(urgent)
		var/extra_message = CONFIG_GET(string/urgent_ahelp_message)
		to_chat(initiator, span_boldwarning("Notified admins to prioritize your ticket"))
		var/datum/discord_embed/embed = format_embed_discord(message)
		embed.content = extra_message
		embed.footer = "This player requested an admin"
		send2adminchat_webhook(embed, urgent = TRUE)
		webhook_sent = WEBHOOK_URGENT
	//send it to TGS if nobody is on and tell us how many were on
	var/admin_number_present = send2tgs_adminless_only(initiator_ckey, "Ticket #[id]: [message_to_send]")
	log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK admins who have +BAN.")
	if(admin_number_present <= 0)
		to_chat(initiator, span_notice("No active admins are online, your adminhelp was sent to admins who are available through IRC or Discord."), confidential = TRUE)
		heard_by_no_admins = TRUE
		var/regular_webhook_url = CONFIG_GET(string/regular_adminhelp_webhook_url)
		if(regular_webhook_url && (!urgent || regular_webhook_url != CONFIG_GET(string/urgent_adminhelp_webhook_url)))
			var/extra_message = CONFIG_GET(string/ahelp_message)
			var/datum/discord_embed/embed = format_embed_discord(message)
			embed.content = extra_message
			embed.footer = "This player sent an ahelp when no admins are available [urgent? "and also requested an admin": ""]"
			send2adminchat_webhook(embed, urgent = FALSE)
			webhook_sent = WEBHOOK_NON_URGENT

/proc/send2adminchat_webhook(message_or_embed, urgent)
	var/webhook = CONFIG_GET(string/urgent_adminhelp_webhook_url)
	if(!urgent)
		webhook = CONFIG_GET(string/regular_adminhelp_webhook_url)

	if(!webhook)
		return
	var/list/webhook_info = list()
	if(istext(message_or_embed))
		var/message_content = replacetext(replacetext(message_or_embed, "\proper", ""), "\improper", "")
		message_content = GLOB.has_discord_embeddable_links.Replace(replacetext(message_content, "`", ""), " ```$1``` ")
		webhook_info["content"] = message_content
	else
		var/datum/discord_embed/embed = message_or_embed
		webhook_info["embeds"] = list(embed.convert_to_list())
		if(embed.content)
			webhook_info["content"] = embed.content
	if(CONFIG_GET(string/adminhelp_webhook_name))
		webhook_info["username"] = CONFIG_GET(string/adminhelp_webhook_name)
	if(CONFIG_GET(string/adminhelp_webhook_pfp))
		webhook_info["avatar_url"] = CONFIG_GET(string/adminhelp_webhook_pfp)
	// Uncomment when servers are moved to TGS4
	// send2chat(new /datum/tgs_message_conent("[initiator_ckey] | [message_content]"), "ahelp", TRUE)
	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new
	request.prepare(RUSTG_HTTP_METHOD_POST, webhook, json_encode(webhook_info), headers, "tmp/response.json")
	request.fire_and_forget()

/datum/admin_help/Destroy()
	RemoveActive()
	GLOB.ahelp_tickets.closed_tickets -= src
	GLOB.ahelp_tickets.resolved_tickets -= src
	return ..()

// [HORIZON-EDIT] ADMIN-TICKETS
/datum/admin_help/proc/AddInteraction(formatted_message, plain_message = null, message_type = "admin", link_data = null)
	var/ckey_to_use = null

	// Safely get the user's ckey
	if(usr && !isnull(usr.ckey))
		ckey_to_use = usr.ckey
		if(ckey_to_use != initiator_ckey)
			admins_involved |= ckey_to_use
			if(heard_by_no_admins)
				heard_by_no_admins = FALSE
				send2adminchat(initiator_ckey, "Ticket #[id]: Answered by [key_name(usr)]")

	if(!formatted_message)
		formatted_message = "[plain_message || "No message"]"

	if(!plain_message && link_data && length(link_data))
		plain_message = link_data[1]

	var/timestamp = world.time
	var/plain_text = plain_message || strip_html(formatted_message)
	var/html_message = "[server_timestamp()]: [formatted_message]"

	var/author = ckey_to_use || "System"

	if(message_type == "system")
		author = "System"

	var/list/structured_data = list(
		"timestamp" = round_timestamp(wtime = timestamp),
		"author" = author,
		"message" = html_encode(plain_text),
		"html_message" = formatted_message,
		"type" = message_type,
		"islink" = link_data
	)

	ticket_interactions[html_message] = structured_data

	if (formatted_message)
		player_interactions += "[server_timestamp()]: [formatted_message]"
	if(plain_text)
		latest_message = plain_text
	defer_ticket_panel_update() // [HORIZON-ADD] ADMIN-TICKETS

//Removes the ahelp verb and returns it after 2 minutes
/datum/admin_help/proc/TimeoutVerb()
	remove_verb(initiator, /client/verb/adminhelp)
	initiator.adminhelptimerid = addtimer(CALLBACK(initiator, TYPE_PROC_REF(/client, giveadminhelpverb)), 1200, TIMER_STOPPABLE) //2 minute cooldown of admin helps

//private
/datum/admin_help/proc/FullMonty(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = "<br><b>Ticket Actions: </b>"
	if(state == AHELP_ACTIVE)
		if(initial_message)
			. += " (<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=defer'>DEFER</A>)"
		if (CONFIG_GET(flag/popup_admin_pm))
			. += " (<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminpopup=[REF(initiator)]'>POPUP</A>)"
		. += ClosureLinks(ref_src)
	. += "<br><b>Player Actions: </b>"
	. += ADMIN_FULLMONTY_NONAME(initiator.mob)
	. += " (<A href='byond://?_src_=holder;[HrefToken()];showmessageckey=[initiator.ckey]'>NOTES</A>)"
	. += "</b>"

//private
/datum/admin_help/proc/ClosureLinks(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = " (<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=mark'>[marked_admin ? "UNMARK" : "MARK"]</A>)"
	. += " (<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=reject'>REJT</A>)"
	. += " (<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=autoreply'>AUTO</A>)"
	. += " (<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=close'>CLOSE</A>)"
	. += " (<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=resolve'>RSLVE</A>)"
// [/HORIZON-EDIT]

//private
/datum/admin_help/proc/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=reply'>[initiator_key_name]</A>"

//private
/datum/admin_help/proc/TicketHref(msg, ref_src, action = "ticket")
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[ref_src];ahelp_action=[action]'>[msg]</A>"

// [HORIZON-EDIT] ADMIN-TICKETS
//message from the initiator without a target, all admins will see this
//won't bug irc/discord
/datum/admin_help/proc/MessageNoRecipient(msg, urgent = FALSE)
	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	var/ref_src = "[REF(src)]"
	//Message to be sent to all admins
	var/admin_msg = fieldset_block(
		span_adminhelp("Ticket [TicketHref("#[id]", ref_src)]"),
		"<b>[LinkedReplyName(ref_src)] [FullMonty(ref_src)]</b>\n\n\
		[span_linkify(keywords_lookup(msg))]",
		"boxed_message red_box")

	AddInteraction(span_red("[LinkedReplyName(ref_src)]: [msg]"),
		plain_message = "[msg]", message_type = "legacy")
	log_admin_private("Ticket #[id]: [key_name(initiator)]: [msg]")

	//send this msg to all admins
	for(var/client/X in GLOB.admins)
		if(!is_staff(X))
			continue
		if(X.prefs.toggles & SOUND_ADMINHELP)
			X.mob.playsound_local(null, '_horizon/sound/adminhelp_new.ogg', 100, vary = FALSE, channel = CHANNEL_ADMIN, pressure_affected = FALSE, use_reverb = FALSE) // [HORIZON-EDIT] ADMIN-TICKETS
		window_flash(X, ignorepref = TRUE)
		to_chat(X,
			type = MESSAGE_TYPE_ADMINPM,
			html = admin_msg,
			confidential = TRUE)

	//show it to the person adminhelping too
	reply_to_admins_notification(msg)
	SSblackbox.LogAhelp(id, "Ticket Opened", msg, null, initiator.ckey, urgent = urgent)
// [/HORIZON-EDIT]

/// Sends a message to the player that they are replying to admins.
/datum/admin_help/proc/reply_to_admins_notification(message)
	to_chat(
		initiator,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_notice("PM to-<b>Admins</b>: [span_linkify(message)]"),
		confidential = TRUE,
	)

	player_replied = TRUE

//Reopen a closed ticket
/datum/admin_help/proc/Reopen()
	if(state == AHELP_ACTIVE)
		to_chat(usr, span_warning("This ticket is already open."), confidential = TRUE)
		return

	// [HORIZON-EDIT] ADMIN-TICKETS
	var/datum/admin_help/existing_ticket = GLOB.ahelp_tickets.CKey2ActiveTicket(initiator_ckey)
	if(existing_ticket && existing_ticket != src)
		if(tgui_alert(usr, "[initiator_ckey] already has an active adminhelp ticket. Would you like to close it and reopen this one?", "Existing Adminhelp Found", list("Yes", "No")) == "Yes")
			existing_ticket.Close(usr.ckey, TRUE)
		else
			to_chat(usr, span_notice("Using the existing adminhelp thread for [initiator_ckey]."), confidential = TRUE)
			return FALSE
	// [HORIZON-EDIT]

	statclick = new(null, src)
	GLOB.ahelp_tickets.active_tickets += src
	GLOB.ahelp_tickets.closed_tickets -= src
	GLOB.ahelp_tickets.resolved_tickets -= src
	state = AHELP_ACTIVE
	closed_at = null
	time_activity["closed_at"] = null // [HORIZON-EDIT] ADMIN-TICKETS
	if(initiator)
		initiator.current_ticket = src

	AddInteraction(span_purple("Reopened by [key_name_admin(usr)]"), plain_message = "Reopened by [usr.key]", message_type = "system") // [HORIZON-EDIT] ADMIN-TICKETS
	var/msg = span_adminhelp("Ticket [TicketHref("#[id]")] reopened by [key_name_admin(usr)].")
	message_admins(msg)
	log_admin_private(msg)
	SSblackbox.LogAhelp(id, "Reopened", "Reopened by [usr.key]", usr.ckey)
	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "reopened")
	OpenInTicketPanel() //can only be done from here, so refresh it

//private
/datum/admin_help/proc/RemoveActive()
	if(state != AHELP_ACTIVE)
		return
	closed_at = world.time
	time_activity["closed_at"] = round_timestamp(wtime = closed_at) // [HORIZON-EDIT] ADMIN-TICKETS
	QDEL_NULL(statclick)
	GLOB.ahelp_tickets.active_tickets -= src
	if(initiator && initiator.current_ticket == src)
		initiator.current_ticket = null

	SEND_SIGNAL(src, COMSIG_ADMIN_HELP_MADE_INACTIVE)

//Mark open ticket as closed/meme
/datum/admin_help/proc/Close(key_name = key_name_admin(usr), silent = FALSE)
	if(state != AHELP_ACTIVE)
		return

	if(marked_admin && marked_admin != usr.ckey)
		SEND_SOUND(usr, sound('_horizon/sound/adminhelp-error.ogg', volume = 30)) // [HORIZON-EDIT] ADMIN-TICKETS
		to_chat(usr, span_warning("This ticket is currently marked by [marked_admin]. Please override their mark to interact with this ticket!"), confidential = TRUE)
		return

	marked_admin = null
	RemoveActive()
	state = AHELP_CLOSED
	GLOB.ahelp_tickets.ListInsert(src)
	AddInteraction(span_red("Closed by [key_name]."), plain_message = "Closed by [usr.key]", message_type = "system")
	if(!silent)
		SSblackbox.record_feedback("tally", "ahelp_stats", 1, "closed")
		var/msg = "Ticket [TicketHref("#[id]")] closed by [key_name]."
		message_admins(msg)
		SSblackbox.LogAhelp(id, "Closed", "Closed by [usr.key]", null, usr.ckey)
		log_admin_private(msg)

// [HORIZON-ADD] ADMIN-TICKETS
/datum/admin_help/proc/player_close(client/C)
	if(state != AHELP_ACTIVE)
		return
	if(!C || ckey(C.key) != initiator_ckey)
		return
	if(initiator != C)
		// The initiator reconnected; reattach so state cleanup works
		initiator = C

	marked_admin = null
	RemoveActive()
	state = AHELP_CLOSED
	GLOB.ahelp_tickets.ListInsert(src)

	AddInteraction(span_red("Closed by [key_name_admin(C)]."), plain_message = "Closed by [C.key]", message_type = "system")

	to_chat(C, span_notice("You have closed your admin ticket."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "closed")
	var/msg = "Ticket [TicketHref("#[id]")] closed by [key_name(C)]."
	message_admins(msg)
	SSblackbox.LogAhelp(id, "Closed", "Closed by [C.key]", null, C.ckey)
	log_admin_private(msg)
// [/HORIZON-ADD]

//Mark open ticket as resolved/legitimate, returns ahelp verb
/datum/admin_help/proc/Resolve(key_name = key_name_admin(usr), silent = FALSE)
	if(state != AHELP_ACTIVE)
		return

	if(marked_admin && marked_admin != usr.ckey)
		SEND_SOUND(usr, sound('_horizon/sound/adminhelp-error.ogg', volume = 30)) // [HORIZON-EDIT] ADMIN-TICKETS
		to_chat(usr, span_warning("This ticket is currently marked by [marked_admin]. Please override their mark to interact with this ticket!"), confidential = TRUE)
		return

	marked_admin = null
	RemoveActive()
	state = AHELP_RESOLVED
	GLOB.ahelp_tickets.ListInsert(src)

	addtimer(CALLBACK(initiator, TYPE_PROC_REF(/client, giveadminhelpverb)), 5 SECONDS)

	AddInteraction(span_green("Resolved by [key_name]."),
	plain_message = "Resolved by [usr.key]", message_type = "system")
	to_chat(initiator, span_adminhelp("Your ticket has been resolved by an admin. The Adminhelp verb will be returned to you shortly."), confidential = TRUE)
	if(!silent)
		SSblackbox.record_feedback("tally", "ahelp_stats", 1, "resolved")
		var/msg = "Ticket [TicketHref("#[id]")] resolved by [key_name]"
		message_admins(msg)
		SSblackbox.LogAhelp(id, "Resolved", "Resolved by [usr.key]", null, usr.ckey)
		log_admin_private(msg)

//Close and return ahelp verb, use if ticket is incoherent
/datum/admin_help/proc/Reject(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	if(marked_admin && ckey(marked_admin) != usr.ckey)
		SEND_SOUND(usr, sound('_horizon/sound/adminhelp-error.ogg', volume = 30)) // [HORIZON-EDIT] ADMIN-TICKETS
		to_chat(usr, span_warning("This ticket is currently marked by [marked_admin]. Please override their mark to interact with this ticket!"), confidential = TRUE)
		return

	if(initiator)
		initiator.giveadminhelpverb()

		SEND_SOUND(initiator, sound('_horizon/sound/adminhelp-error.ogg')) // [HORIZON-EDIT] ADMIN-TICKETS

		to_chat(initiator, span_boldwarning("- AdminHelp Rejected! -"), confidential = TRUE)
		to_chat(initiator, span_warning("<b>Your admin help was rejected.</b> The adminhelp verb has been returned to you so that you may try again."), confidential = TRUE)
		to_chat(initiator, "Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting.", confidential = TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "rejected")
	var/msg = "Ticket [TicketHref("#[id]")] rejected by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Rejected by [key_name].", plain_message = "Rejected by [usr.key]", message_type = "system") // [HORIZON-EDIT] ADMIN-TICKETS
	SSblackbox.LogAhelp(id, "Rejected", "Rejected by [usr.key]", null, usr.ckey)
	Close(silent = TRUE)

//Resolve ticket with IC Issue message
/datum/admin_help/proc/ICIssue(key_name = key_name_admin(usr))
	if(state != AHELP_ACTIVE)
		return

	var/msg = "<font color='red' size='4'><b>- AdminHelp marked as IC issue! -</b></font><br>"
	msg += "<font color='red'>Your issue has been determined by an administrator to be an in character issue and does NOT require administrator intervention at this time. For further resolution you should pursue options that are in character.</font>"

	if(initiator)
		to_chat(initiator, msg, confidential = TRUE)

	SSblackbox.record_feedback("tally", "ahelp_stats", 1, "IC")
	msg = "Ticket [TicketHref("#[id]")] marked as IC by [key_name]"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("Marked as IC issue by [key_name]", plain_message = "Marked as IC issue!", message_type = "system") // [HORIZON-EDIT] ADMIN-TICKETS
	SSblackbox.LogAhelp(id, "IC Issue", "Marked as IC issue by [usr.key]", null,  usr.ckey)
	Resolve(silent = TRUE)

// [HORIZON-EDIT] ADMIN-TICKETS
//Show the ticket panel
/datum/admin_help/proc/defer_to_mentors()
	if(state != AHELP_ACTIVE || !initial_message)
		return

	if(marked_admin && marked_admin != usr.ckey)
		SEND_SOUND(usr, sound('_horizon/sound/adminhelp-error.ogg', volume = 30)) // [HORIZON-EDIT] ADMIN-TICKETS
		to_chat(usr, span_warning("This ticket is currently marked by [marked_admin]. Please override their mark to interact with this ticket!"), confidential = TRUE)
		return

	if(GLOB.mentorhelp_manager.get_active_ticket_by_ckey(initiator_ckey))
		to_chat(usr, span_warning("This user already has an active mentorhelp ticket. Please close it first or use the existing one."), confidential = TRUE)
		return

	var/options = tgui_alert(usr, "Use the first message in this ticket, or a custom option?", "Defer to Mentors", list("First Message", "Custom"))
	if(!options)
		return

	var/message
	switch(options)
		if("First Message")
			message = initial_message
		if("Custom")
			var/custom_msg = tgui_input_text(usr, "Text to Send to Mentors", "Defer to Mentors")
			if(!custom_msg)
				return
			message = "DEFERRED BY ADMIN [usr.key]: [custom_msg]\n\nOriginal message: [initial_message]"

	if(!message)
		return

	var/datum/mentorhelp/MH = GLOB.mentorhelp_manager.create_ticket(initiator, message)
	if(!MH)
		return
	MH.subject = subject
	MH.broadcast_unhandled(message, initiator)

	AddInteraction("Deferred to Mentors by [key_name_admin(usr)].", plain_message = "Deferred to Mentors by [usr.key]", message_type = "system")
	to_chat(initiator, span_adminhelp("[usr.key] has deferred your ticket to Mentors."), confidential = TRUE)
	log_admin_private("Ticket [TicketHref("#[id]")] deferred to mentors by [usr.key].")
	for(var/client/admin in GLOB.admins)
		if(is_staff(admin) || is_mentor(admin))
			to_chat(admin, span_adminnotice("[usr.key] has deferred [initiator.key]'s ticket to Mentors."), confidential = TRUE)
	SSblackbox.LogAhelp(id, "Defer", "Deferred to mentors by [usr.key]", null, usr.ckey)
	Close(silent = TRUE)

/datum/admin_help/proc/mark_ticket(mob/marking_admin)
	var/mob/user = marking_admin || usr
	if(state != AHELP_ACTIVE)
		to_chat(user, span_warning("This ticket is already closed!"), confidential = TRUE)
		return
	if(marked_admin)
		if(marked_admin == user.ckey)
			unmark_ticket()
			return
		to_chat(user, span_warning("This ticket has already been marked by [marked_admin]."), confidential = TRUE)
		var/unmark_option = tgui_alert(user, "This message has been marked by [marked_admin]. Do you want to override?", "Marked Ticket", list("Overwrite Mark", "Unmark", "Cancel"))
		if(unmark_option == "Unmark")
			unmark_ticket()
			return
		if(unmark_option != "Overwrite Mark")
			return

	var/key_name = key_name_admin(user)
	AddInteraction("Marked by [key_name].",
		plain_message = "Marked by [user.key]", message_type = "system")
	to_chat(initiator, span_adminhelp("An admin is preparing to respond to your ticket."), confidential = TRUE)
	var/msg = "Ticket [TicketHref("#[id]")] marked by [key_name]."
	message_admins(msg)
	SSblackbox.LogAhelp(id, "Marked", "Marked by [user.key]", sender = user.ckey)
	marked_admin = user.ckey

/datum/admin_help/proc/unmark_ticket()
	var/key_name = key_name_admin(usr)
	AddInteraction("Unmarked by [key_name] (previously [marked_admin]).",
		plain_message = "Unmarked by [usr.key] (previously [marked_admin])", message_type = "system")
	var/msg = "Ticket [TicketHref("#[id]")] unmarked by [key_name]."
	message_admins(msg)
	SSblackbox.LogAhelp(id, "Unmarked", "Unmarked by [usr.key] (previously [marked_admin])", sender = usr.ckey)
	marked_admin = null

/// Resolve ticket with a premade message
/datum/admin_help/proc/AutoReply()
	var/key_name = key_name_admin(usr)
	if(state != AHELP_ACTIVE)
		to_chat(usr, span_warning("This ticket is already closed!"), confidential = TRUE)
		return

	if(marked_admin != usr.ckey)
		if(marked_admin)
			SEND_SOUND(usr, sound('_horizon/sound/adminhelp-error.ogg', volume = 30)) // [HORIZON-EDIT] ADMIN-TICKETS
			to_chat(usr, span_warning("This ticket is currently marked by [marked_admin]. Please override their mark to interact with this ticket!"), confidential = TRUE)
			return
		else
			mark_ticket(usr)

	var/chosen = tgui_input_list(usr, "Which auto response do you wish to send?", "AutoReply", GLOB.adminreplies)
	var/datum/autoreply/admin/response = GLOB.adminreplies[chosen]

	if(!response || !istype(response))
		return

	var/msg = "[span_boldwarning("- AdminHelp marked as [response.title]! -")]<br>"
	msg += span_warning("[response.message]")

	if(initiator)
		to_chat(initiator, msg, confidential = TRUE)

	msg = "Ticket [TicketHref("#[id]")] marked as [response.title] by [key_name]"
	message_admins(msg)
	AddInteraction("Marked as [response.title] by [key_name]",
		plain_message = "Marked as [response.title] by [usr.key]", message_type = "system")
	SSblackbox.LogAhelp(id, "Autoreply", "Marked as [response.title] by [usr.key]", null,  usr.ckey)
	if(response.closer)
		Resolve(silent = TRUE)

/datum/admin_help/proc/OpenInTicketPanel()
	var/client/C = usr.client
	if(!C?.holder)
		return
	if(!C.ticket_panel)
		C.ticket_panel = new /datum/ticket_panel()
	C.ticket_panel.selected_tab = ADMIN_TAB
	C.ticket_panel.selected_ticket = id
	SSadmin_verbs.dynamic_invoke_verb(C, /datum/admin_verb/ticket_panel)
// [/HORIZON-ADD]

//Show the ticket panel (LEGACY browse view)
/datum/admin_help/proc/TicketPanel()
	var/list/dat = list("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Ticket #[id]</title></head>")
	var/ref_src = "[REF(src)]"
	dat += "<h4>Admin Help Ticket #[id]: [LinkedReplyName(ref_src)]</h4>"
	dat += "<b>State: [ticket_status()]</b>"
	dat += "[FOURSPACES][TicketHref("Refresh", ref_src)][FOURSPACES][TicketHref("Re-Title", ref_src, "retitle")]"
	if(state != AHELP_ACTIVE)
		dat += "[FOURSPACES][TicketHref("Reopen", ref_src, "reopen")]"
	dat += "<br><br>Opened at: [round_timestamp(wtime = opened_at)] (Approx [DisplayTimeText(world.time - opened_at)] ago)"
	if(closed_at)
		dat += "<br>Closed at: [round_timestamp(wtime = closed_at)] (Approx [DisplayTimeText(world.time - closed_at)] ago)"
	dat += "<br><br>"
	if(initiator)
		dat += "<b>Actions:</b> [FullMonty(ref_src)]<br>"
	else
		dat += "<b>DISCONNECTED</b>[FOURSPACES][ClosureLinks(ref_src)]<br>"
	dat += "<br><b>Log:</b><br><br>"
	for(var/I in ticket_interactions)
		dat += "[I]<br>"

	// Helper for opening directly to player ticket history
	dat += "<br><br><b>Player Ticket History:</b>"
	dat += "[FOURSPACES]<A href='byond://?_src_=holder;[HrefToken()];player_ticket_history=[initiator_ckey]'>Open</A>"

	// Append any tickets also opened by this user if relevant
	var/list/related_tickets = GLOB.ahelp_tickets.TicketsByCKey(initiator_ckey)
	if (related_tickets.len > 1)
		dat += "<br/><b>Other Tickets by User</b><br/>"
		for (var/datum/admin_help/related_ticket in related_tickets)
			if (related_ticket.id == id)
				continue
			dat += "[related_ticket.TicketHref("#[related_ticket.id]")] ([related_ticket.ticket_status()]): [related_ticket.name]<br/>"
	dat += "</html>"

	usr << browse(dat.Join(), "window=ahelp[id];size=750x480")

/**
 * Renders the current status of the ticket into a displayable string
 */
/datum/admin_help/proc/ticket_status()
	switch(state)
		if(AHELP_ACTIVE)
			return "<font color='red'>OPEN</font>"
		if(AHELP_RESOLVED)
			return "<font color='green'>RESOLVED</font>"
		if(AHELP_CLOSED)
			return "CLOSED"
		else
			stack_trace("Invalid ticket state: [state]")
			return "INVALID, CALL A CODER"

// [HORIZON-EDIT] ADMIN-TICKETS
/datum/admin_help/proc/set_subject(new_subject, client/setter)
	if(!new_subject || !setter)
		return FALSE

	subject = sanitize(copytext_char(new_subject, 1, 100))

	message_admins("[setter.ckey] set the subject of ticket [id] to: [subject]")
	defer_ticket_panel_update()

	return TRUE
// [/HORIZON-EDIT]

/datum/admin_help/proc/Retitle()
	var/new_title = tgui_input_text(usr, "Enter a title for the ticket", "Rename Ticket", name) // [HORIZON-EDIT] ADMIN-TICKETS
	if(new_title)
		name = new_title
		//not saying the original name cause it could be a long ass message
		var/msg = "Ticket [TicketHref("#[id]")] titled [name] by [key_name_admin(usr)]"
		message_admins(msg)
	TicketPanel() //we have to be here to do this

//Forwarded action from admin/Topic
/datum/admin_help/proc/Action(action)
	if(webhook_sent != WEBHOOK_NONE)
		var/datum/discord_embed/embed = new()
		embed.title = "Ticket #[id]"
		if(CONFIG_GET(string/adminhelp_ahelp_link))
			var/ahelp_link = replacetext(CONFIG_GET(string/adminhelp_ahelp_link), "$RID", GLOB.round_id)
			ahelp_link = replacetext(ahelp_link, "$TID", id)
			embed.url = ahelp_link
		embed.description = "[key_name(usr)] has sent an action to this ticket. Action ID: [action]"
		if(webhook_sent == WEBHOOK_URGENT)
			send2adminchat_webhook(embed, urgent = TRUE)
		if(webhook_sent == WEBHOOK_NON_URGENT || CONFIG_GET(string/regular_adminhelp_webhook_url) != CONFIG_GET(string/urgent_adminhelp_webhook_url))
			send2adminchat_webhook(embed, urgent = FALSE)
		webhook_sent = WEBHOOK_NONE
	// [HORIZON-EDIT] ADMIN-TICKETS
	switch(action)
		if("ticket")
			OpenInTicketPanel()
		if("retitle")
			Retitle()
		if("mark")
			mark_ticket()
		if("reject")
			Reject()
		if("reply")
			usr.client.cmd_ahelp_reply(initiator)
		if("autoreply")
			AutoReply()
		if("close")
			Close()
		if("resolve")
			Resolve()
		if("reopen")
			Reopen()
		if("defer")
			defer_to_mentors()
	// [/HORIZON-EDIT]

/datum/admin_help/proc/player_ticket_panel()
	var/list/dat = list("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Ticket Panel</title></head>")
	dat += "<b>State: "
	switch(state)
		if(AHELP_ACTIVE)
			dat += "<font color='red'>OPEN</font></b>"
		if(AHELP_RESOLVED)
			dat += "<font color='green'>RESOLVED</font></b>"
		if(AHELP_CLOSED)
			dat += "CLOSED</b>"
		else
			dat += "UNKNOWN</b>"
	dat += "\n[FOURSPACES]<A href='byond://?_src_=usr;tguiless_ticket_panel=1'>Refresh</A>"
	dat += "<br><br>Opened at: [round_timestamp("hh:mm:ss", opened_at)] (Approx [DisplayTimeText(world.time - opened_at)] ago)"
	if(closed_at)
		dat += "<br>Closed at: [round_timestamp("hh:mm:ss", closed_at)] (Approx [DisplayTimeText(world.time - closed_at)] ago)"
	dat += "<br><br>"
	dat += "<br><b>Log:</b><br><br>"
	for (var/interaction in player_interactions)
		dat += "[interaction]<br>"

	var/datum/browser/player_panel = new(usr, "ahelp[id]", 0, 620, 480)
	player_panel.set_content(dat.Join())
	player_panel.open()


//
// TICKET STATCLICK
//

/obj/effect/statclick/ahelp
	var/datum/admin_help/ahelp_datum

/obj/effect/statclick/ahelp/Initialize(mapload, datum/admin_help/AH)
	ahelp_datum = AH
	. = ..()

/obj/effect/statclick/ahelp/update()
	return ..(ahelp_datum.name)

/obj/effect/statclick/ahelp/Click()
	if (!usr.client?.holder)
		message_admins("[key_name_admin(usr)] non-holder clicked on an ahelp statclick! ([src])")
		usr.log_message("non-holder clicked on an ahelp statclick! ([src])", LOG_ADMIN)
		return

	// [HORIZON-EDIT] ADMIN-TICKETS
	// Open the TGUI ticket panel
	if(usr.client.holder)
		if(!usr.client.ticket_panel)
			usr.client.ticket_panel = new /datum/ticket_panel()
		usr.client.ticket_panel.selected_tab = ADMIN_TAB
		usr.client.ticket_panel.selected_ticket = ahelp_datum.id
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/ticket_panel)
		to_chat(usr, span_notice("Accessing Ticket Panel... (Click <A href='byond://?_src_=holder;[HrefToken()];ahelp=[REF(ahelp_datum)];ahelp_action=ticket'>here</A> for legacy view)"), confidential = TRUE)
	// [/HORIZON-EDIT]

/obj/effect/statclick/ahelp/Destroy()
	ahelp_datum = null
	return ..()

//
// CLIENT PROCS
//

/client/proc/giveadminhelpverb()
	add_verb(src, /client/verb/adminhelp)
	deltimer(adminhelptimerid)
	adminhelptimerid = 0

GLOBAL_DATUM_INIT(admin_help_ui_handler, /datum/admin_help_ui_handler, new)

/datum/admin_help_ui_handler
	var/list/ahelp_cooldowns = list()

/datum/admin_help_ui_handler/ui_state(mob/user)
	return GLOB.always_state

/datum/admin_help_ui_handler/ui_data(mob/user)
	. = list()
	var/list/admins = get_admin_counts(R_BAN)
	.["adminCount"] = length(admins["present"])

/datum/admin_help_ui_handler/ui_static_data(mob/user)
	. = list()
	.["bannedFromUrgentAhelp"] = is_banned_from(user.ckey, "Urgent Adminhelp")
	.["urgentAhelpPromptMessage"] = CONFIG_GET(string/urgent_ahelp_user_prompt)
	var/webhook_url = CONFIG_GET(string/urgent_adminhelp_webhook_url)
	if(webhook_url)
		.["urgentAhelpEnabled"] = TRUE

/datum/admin_help_ui_handler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Adminhelp")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/admin_help_ui_handler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/client/user_client = usr.client
	var/message = sanitize_text(trim(params["message"]))

	// [HORIZON-EDIT] ADMIN-TICKETS
	if(params["recipient"] == "mentor")
		perform_mentorhelp(user_client, message)
		ui.close()
		return
	// [/HORIZON-EDIT]

	var/urgent = !!params["urgent"]
	var/list/admins = get_admin_counts(R_BAN)
	if(length(admins["present"]) != 0 || is_banned_from(user_client.ckey, "Urgent Adminhelp"))
		urgent = FALSE

	if(user_client.adminhelptimerid)
		return

	perform_adminhelp(user_client, message, urgent)
	ui.close()

/datum/admin_help_ui_handler/proc/perform_adminhelp(client/user_client, message, urgent)
	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	if(!message)
		return

	//handle muting and automuting
	if(user_client.prefs.muted & MUTE_ADMINHELP)
		to_chat(user_client, span_danger("Error: Admin-PM: You cannot send adminhelps (Muted)."), confidential = TRUE)
		return
	if(user_client.handle_spam_prevention(message, MUTE_ADMINHELP))
		return

	BLACKBOX_LOG_ADMIN_VERB("Adminhelp")

	if(urgent)
		if(!COOLDOWN_FINISHED(src, ahelp_cooldowns?[user_client.ckey]))
			urgent = FALSE // Prevent abuse
		else
			COOLDOWN_START(src, ahelp_cooldowns[user_client.ckey], CONFIG_GET(number/urgent_ahelp_cooldown) * (1 SECONDS))

	if(user_client.current_ticket)
		user_client.current_ticket.TimeoutVerb()
		if(urgent)
			var/sanitized_message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
			user_client.current_ticket.send_message_to_tgs(sanitized_message, urgent = TRUE)
		user_client.current_ticket.MessageNoRecipient(message, urgent)
		return

	new /datum/admin_help(message, user_client, FALSE, urgent)

// [HORIZON-EDIT] ADMIN-TICKETS
/datum/admin_help_ui_handler/proc/perform_mentorhelp(client/user_client, message)
	if(GLOB.say_disabled)
		to_chat(user_client, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	if(!message)
		return

	if(user_client.prefs.muted & MUTE_MHELP)
		to_chat(user_client, span_danger("Error: Mentor-PM: You cannot send mentorhelps (Muted)."), confidential = TRUE)
		return
	if(user_client.handle_spam_prevention(message, MUTE_MHELP))
		return

	BLACKBOX_LOG_ADMIN_VERB("Mentorhelp")

	message = strip_html(html_decode(trim(message)))

	if(user_client.current_mhelp && user_client.current_mhelp.open)
		var/datum/mentorhelp/open_mhelp = user_client.current_mhelp
		open_mhelp.message_handlers(message, user_client, open_mhelp.mentor)
		return

	user_client.current_mhelp = new(user_client)
	if(!user_client.current_mhelp.broadcast_request(user_client, message))
		QDEL_NULL(user_client.current_mhelp)
// [/HORIZON-EDIT]

GAME_VERB_HIDDEN(/client, no_tgui_adminhelp, "NoTguiAdminhelp")
	VERB_ARG(message, VERB_ARG_TYPE_MESSAGE, VERB_ARG_SOURCE_INPUT)
	if(adminhelptimerid)
		return

	message = trim(message)

	GLOB.admin_help_ui_handler.perform_adminhelp(src, message, FALSE)

// [HORIZON-EDIT] ADMIN-TICKETS
GAME_VERB(/client, adminhelp, "Adminhelp", "Admin")
	if(current_ticket || (current_mhelp && current_mhelp.open))
		view_latest_ticket()
		return
	GLOB.admin_help_ui_handler.ui_interact(mob)
	to_chat(src, span_boldnotice("Adminhelp failing to open or work? <a href='byond://?src=[REF(src)];tguiless_adminhelp=1'>Click here</a>"))

GAME_VERB(/client, mentorhelp, "Mentorhelp", "Admin")
	if(current_mhelp && current_mhelp.open)
		view_latest_ticket()
		return
	GLOB.admin_help_ui_handler.ui_interact(mob)

// Opens the TGUI player ticket panel listing the player's own tickets.
GAME_VERB(/client, view_latest_ticket, "Ticket Panel", "Admin")
	if(!player_ticket_panel)
		player_ticket_panel = new /datum/player_ticket_panel()
	player_ticket_panel.open_for(src)
	to_chat(src, span_boldnotice("Ticket panel failing to open or work? <a href='byond://?src=[REF(src)];tguiless_ticket_panel=1'>Click here</a>"))

/client/proc/legacy_player_ticket_panel()
	if(current_ticket)
		current_ticket.player_ticket_panel()
		return

	// No open admin ticket: fall back to the player's open mentorhelp thread
	if(current_mhelp && current_mhelp.open)
		current_mhelp.player_ticket_panel()
		return

	// Check if the client had previous tickets, and show the latest one
	var/list/prev_tickets = list()
	var/datum/admin_help/last_ticket
	// Check all resolved tickets for this player
	for(var/datum/admin_help/resolved_ticket in GLOB.ahelp_tickets.resolved_tickets)
		if(resolved_ticket.initiator_ckey == ckey) // Initiator is a misnomer, it's always the non-admin player even if an admin bwoinks first
			prev_tickets += resolved_ticket
	// Check all closed tickets for this player
	for(var/datum/admin_help/closed_ticket in GLOB.ahelp_tickets.closed_tickets)
		if(closed_ticket.initiator_ckey == ckey)
			prev_tickets += closed_ticket
	// Take the most recent entry of prev_tickets and open the panel on it
	if(LAZYLEN(prev_tickets))
		last_ticket = prev_tickets[prev_tickets.len]
		last_ticket.player_ticket_panel()
		return

	// Fall back to the player's most recent archived mentorhelp thread
	var/datum/mentorhelp/last_mhelp
	for(var/mhelp_id in GLOB.mentorhelp_manager.archived_tickets)
		var/datum/mentorhelp/archived_mhelp = GLOB.mentorhelp_manager.archived_tickets[mhelp_id]
		if(archived_mhelp && ckey(archived_mhelp.author_key) == ckey)
			last_mhelp = archived_mhelp
	if(last_mhelp)
		last_mhelp.player_ticket_panel()
		return

	// client had no tickets this round
	to_chat(src, span_warning("You have not had any tickets this round."))
// [/HORIZON-EDIT]

//
// LOGGING
//

/// Use this proc when an admin takes action that may be related to an open ticket on what
/// what can be a client, ckey, or mob
/// player_message: If the message should be shown in the player ticket panel, fill this out
/// log_in_blackbox: Whether or not this message with the blackbox system.
/// If disabled, this message should be logged with a different proc call
/proc/admin_ticket_log(what, message, player_message, log_in_blackbox = TRUE)
	var/client/mob_client
	var/mob/Mob = what
	if(istype(Mob))
		mob_client = Mob.client
	else
		mob_client = what
	if(istype(mob_client) && mob_client.current_ticket)
		if (isnull(player_message))
			mob_client.current_ticket.AddInteraction(message)
		else
			mob_client.current_ticket.AddInteraction(message, player_message)
		if(log_in_blackbox)
			SSblackbox.LogAhelp(mob_client.current_ticket.id, "Interaction", message, mob_client.ckey, usr.ckey)
		return mob_client.current_ticket
	if(istext(what)) //ckey
		var/datum/admin_help/active_admin_help = GLOB.ahelp_tickets.CKey2ActiveTicket(what)
		if(active_admin_help)
			if (isnull(player_message))
				active_admin_help.AddInteraction(message)
			else
				active_admin_help.AddInteraction(message, player_message)
			if(log_in_blackbox)
				SSblackbox.LogAhelp(active_admin_help.id, "Interaction", message, what, usr.ckey)
			return active_admin_help

//
// HELPER PROCS
//

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = list(), "noflags" = list(), "afk" = list(), "stealth" = list(), "present" = list())
	for(var/client/X in GLOB.admins)
		.["total"] += X
		if(requiredflags != NONE && !check_rights_for(X, requiredflags))
			.["noflags"] += X
		else if(X.is_afk())
			.["afk"] += X
		else if(X.holder.fakekey)
			.["stealth"] += X
		else
			.["present"] += X

/proc/send2tgs_adminless_only(source, msg, requiredflags = R_BAN)
	var/list/adm = get_admin_counts(requiredflags)
	var/list/activemins = adm["present"]
	. = activemins.len
	if(. <= 0)
		var/final = ""
		var/list/afkmins = adm["afk"]
		var/list/stealthmins = adm["stealth"]
		var/list/powerlessmins = adm["noflags"]
		var/list/allmins = adm["total"]
		if(!afkmins.len && !stealthmins.len && !powerlessmins.len)
			final = "[msg] - No admins online"
		else
			final = "[msg] - All admins stealthed\[[english_list(stealthmins)]\], AFK\[[english_list(afkmins)]\], or lacks +BAN\[[english_list(powerlessmins)]\]! Total: [allmins.len] "
		send2adminchat(source,final)
		send2otherserver(source,final)

/**
 * Sends a message to a set of cross-communications-enabled servers using world topic calls
 *
 * Arguments:
 * * source - Who sent this message
 * * msg - The message body
 * * type - The type of message, becomes the topic command under the hood
 * * target_servers - A collection of servers to send the message to, defined in config
 * * additional_data - An (optional) associated list of extra parameters and data to send with this world topic call
 */
/proc/send2otherserver(source, msg, type = "Ahelp", target_servers, list/additional_data = list())
	if(!CONFIG_GET(string/comms_key))
		debug_world_log("Server cross-comms message not sent for lack of configured key")
		return

	var/our_id = CONFIG_GET(string/cross_comms_name)
	additional_data["message_sender"] = source
	additional_data["message"] = msg
	additional_data["source"] = "([our_id])"
	additional_data += type

	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	for(var/I in servers)
		if(I == our_id) //No sending to ourselves
			continue
		if(target_servers && !(I in target_servers))
			continue
		world.send_cross_comms(I, additional_data)

/// Sends a message to a given cross comms server by name (by name for security).
/world/proc/send_cross_comms(server_name, list/message, auth = TRUE)
	set waitfor = FALSE
	if (auth)
		var/comms_key = CONFIG_GET(string/comms_key)
		if(!comms_key)
			debug_world_log("Server cross-comms message not sent for lack of configured key")
			return
		message["key"] = comms_key
	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	var/server_url = servers[server_name]
	if (!server_url)
		CRASH("Invalid cross comms config: [server_name]")
	world.Export("[server_url]?[list2params(message)]")


/proc/tgsadminwho()
	var/list/message = list("Admins: ")
	var/list/admin_keys = list()
	for(var/adm in GLOB.admins)
		var/client/C = adm
		admin_keys += "[C][C.holder.fakekey ? "(Stealth)" : ""][C.is_afk() ? "(AFK)" : ""]"

	for(var/admin in admin_keys)
		if(LAZYLEN(message) > 1)
			message += ", [admin]"
		else
			message += "[admin]"

	return jointext(message, "")

/proc/keywords_lookup(msg,external)

	//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
	var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	var/founds = ""
	for(var/mob/M in GLOB.mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i >= 1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i in 1 to surname_found-1)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							var/is_antag = found.is_antag()
							founds += "Name: [found.name]([found.real_name]) Key: [found.key] Ckey: [found.ckey] [is_antag ? "(Antag)" : null] "
							msg += "[original_word]<font size='1' color='[is_antag ? "red" : "black"]'>(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminmoreinfo=[REF(found)]'>?</A>|<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];adminplayerobservefollow=[REF(found)]'>F</A>)</font> "
							continue
		msg += "[original_word] "
	if(external)
		if(founds == "")
			return "Search Failed"
		else
			return founds

	return msg

/proc/get_mob_by_name(msg)
	//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
	var/list/ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//who might fit the shoe
	var/list/potential_hits = list()

	for(var/i in GLOB.mob_list)
		var/mob/M = i
		var/list/nameWords = list()
		if(!M.mind)
			continue

		for(var/string in splittext(LOWER_TEXT(M.real_name), " "))
			if(!(string in ignored_words))
				nameWords += string
		for(var/string in splittext(LOWER_TEXT(M.name), " "))
			if(!(string in ignored_words))
				nameWords += string

		for(var/string in nameWords)
			if(string in msglist)
				potential_hits += M
				break

	return potential_hits

/**
 * Checks a given message to see if any of the words are something we want to treat specially, as detailed below.
 *
 * There are 3 cases where a word is something we want to act on
 * 1. Admin pings, like @adminckey. Pings the admin in question, text is not clickable
 * 2. Datum refs, like @0x2001169 or @mob_23. Clicking on the link opens up the VV for that datum
 * 3. Ticket refs, like #3. Displays the status and ahelper in the link, clicking on it brings up the ticket panel for it.
 * Returns a list being used as a tuple. Index ASAY_LINK_NEW_MESSAGE_INDEX contains the new message text (with clickable links and such)
 * while index ASAY_LINK_PINGED_ADMINS_INDEX contains a list of pinged admin clients, if there are any.
 *
 * Arguments:
 * * msg - the message being scanned
 */
/proc/check_asay_links(msg)
	var/list/msglist = splittext(msg, " ") //explode the input msg into a list
	var/list/pinged_admins = list() // if we ping any admins, store them here so we can ping them after
	var/modified = FALSE // did we find anything?

	var/i = 0
	for(var/word in msglist)
		i++
		if(!length(word))
			continue

		switch(word[1])
			if("@")
				var/stripped_word = ckey(copytext(word, 2))

				// first we check if it's a ckey of an admin
				var/client/client_check = GLOB.directory[stripped_word]
				if(client_check?.holder)
					msglist[i] = "<u>[word]</u>"
					pinged_admins[stripped_word] = client_check
					modified = TRUE
					continue

				// then if not, we check if it's a datum ref

				var/word_with_brackets = "\[[stripped_word]\]" // the actual memory address lookups need the bracket wraps
				var/datum/datum_check = locate(word_with_brackets)
				if(!istype(datum_check))
					continue
				msglist[i] = "<u><a href='byond://?_src_=vars;[HrefToken(forceGlobal = TRUE)];Vars=[word_with_brackets]'>[word]</A></u>"
				modified = TRUE

			if("#") // check if we're linking a ticket
				var/possible_ticket_id = text2num(copytext(word, 2))
				if(!possible_ticket_id)
					continue

				var/datum/admin_help/ahelp_check = GLOB.ahelp_tickets?.TicketByID(possible_ticket_id)
				if(!ahelp_check)
					continue

				var/state_word
				switch(ahelp_check.state)
					if(AHELP_ACTIVE)
						state_word = "Active"
					if(AHELP_CLOSED)
						state_word = "Closed"
					if(AHELP_RESOLVED)
						state_word = "Resolved"

				msglist[i]= "<u><A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[REF(ahelp_check)];ahelp_action=ticket'>[word] ([state_word] | [ahelp_check.initiator_key_name])</A></u>"
				modified = TRUE

	if(modified)
		var/list/return_list = list()
		return_list[ASAY_LINK_NEW_MESSAGE_INDEX] = jointext(msglist, " ") // without tuples, we must make do!
		return_list[ASAY_LINK_PINGED_ADMINS_INDEX] = pinged_admins
		return return_list


#undef WEBHOOK_URGENT
#undef WEBHOOK_NONE
#undef WEBHOOK_NON_URGENT
