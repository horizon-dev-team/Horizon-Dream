GLOBAL_DATUM_INIT(mentorhelp_manager, /datum/mentorhelp_manager, new)

/datum/mentorhelp_manager
	var/list/active_tickets = list()
	var/list/archived_tickets = list()
	var/ticket_counter = 1

/datum/mentorhelp_manager/proc/get_ticket_by_id(id)
	if(active_tickets["[id]"])
		return active_tickets["[id]"]
	return archived_tickets["[id]"]

/datum/mentorhelp_manager/proc/get_active_ticket_by_ckey(ckey)
	if(!ckey)
		return null
	for(var/id in active_tickets)
		var/datum/mentorhelp/MH = active_tickets[id]
		if(MH && ckey(MH.author_key) == ckey(ckey))
			return MH
	return null

/datum/mentorhelp_manager/proc/create_ticket(client/author, message)
	var/datum/mentorhelp/MH = new(author)
	if(!MH || QDELETED(MH))
		return null
	MH.initial_message = message
	MH.latest_message = message
	author.current_mhelp = MH
	return MH

// Represents a mentorhelp thread
/datum/mentorhelp
	var/id = 0

	// The client/player who initiated (authored) the mentorhelp thread
	var/client/author = null
	// The author's key
	var/author_key = ""
	var/author_ic_name = ""
	var/author_role = ""

	// The mentor who's responding to this mentorhelp thread
	// If this is null, it means no mentor has responded yet
	var/client/mentor = null
	var/mentor_key = ""

	// If this thread is still open
	var/open = TRUE
	var/initial_message = ""
	var/latest_message = ""
	var/subject = ""
	var/list/ticket_interactions = list()

	var/opened_at = 0
	var/closed_at = 0

	var/list/time_activity = list("opened_at" = null, "closed_at" = null)

/datum/mentorhelp/New(client/thread_author)
	..()

	if(!thread_author)
		qdel(src)
		return

	var/datum/mentorhelp/existing = GLOB.mentorhelp_manager.get_active_ticket_by_ckey(thread_author.ckey)
	if(existing)
		to_chat(thread_author, span_warning("You already have an active mentor help ticket. Please wait for a mentor to respond."), confidential = TRUE)
		qdel(src)
		return

	opened_at = world.time
	time_activity["opened_at"] = round_timestamp(wtime = opened_at)

	author = thread_author
	author_key = thread_author.key

	if(thread_author.mob)
		author_ic_name = thread_author.mob.real_name || thread_author.mob.name || "Unknown"
		var/mob/M = thread_author.mob
		author_role = get_mob_role(M)

	id = GLOB.mentorhelp_manager.ticket_counter++

	GLOB.mentorhelp_manager.active_tickets["[id]"] = src
	defer_ticket_panel_update() // [HORIZON-ADD] ADMIN-TICKETS

/datum/mentorhelp/Destroy()
	if(open && GLOB.mentorhelp_manager.active_tickets["[id]"] == src)
		GLOB.mentorhelp_manager.active_tickets -= "[id]"
	else if(GLOB.mentorhelp_manager.archived_tickets["[id]"] == src)
		GLOB.mentorhelp_manager.archived_tickets -= "[id]"

	author.current_mhelp = null
	author = null
	mentor = null
	return ..()

/*
 * Helpers
 */

/// Get the role string for a mob, adapted for /tg/
/proc/get_mob_role(mob/M)
	if(!M)
		return "Unknown"
	if(isobserver(M))
		return "Ghost"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind?.assigned_role?.title)
			return H.mind.assigned_role.title
		else if(H.job)
			return H.job
	if(M.mind?.assigned_role?.title)
		return M.mind.assigned_role.title
	if(M.job)
		return M.job
	return "Unknown"

/datum/mentorhelp/proc/check_author()
	if(!author)
		close()
		return FALSE
	return TRUE

/datum/mentorhelp/proc/check_open(client/C)
	if(!open)
		to_chat(C, span_notice("This mentorhelp thread is closed!"), confidential = TRUE)
		return FALSE
	return TRUE

/datum/mentorhelp/proc/get_author_ic_name()
	if(author && author.mob)
		author_ic_name = author.mob.real_name || author.mob.name || "Unknown"
	return author_ic_name || "Unknown"

/datum/mentorhelp/proc/get_author_role()
	if(author && author.mob)
		author_role = get_mob_role(author.mob)
	return author_role

/// Returns the display name for a subject, hiding the author's key from non-staff
/datum/mentorhelp/proc/get_display_name(client/viewer, subject)
	var/subject_key = ""
	var/subject_ic = ""

	if(istype(subject, /client))
		var/client/C = subject
		subject_key = C.key
		if(C.mob)
			subject_ic = C.mob.real_name || C.mob.name
	else if(istype(subject, /mob))
		var/mob/M = subject
		subject_key = M.key
		subject_ic = M.real_name || M.name
	else if(istext(subject))
		subject_key = subject

	if(!subject_key || ckey(subject_key) == ckey(author_key))
		if(viewer && is_staff(viewer))
			return author_key ? "[author_key]/([author_ic_name || "Unknown"])" : "Unknown"
		return author_ic_name || "Unknown"

	if(!subject_ic && mentor_key && ckey(subject_key) == ckey(mentor_key))
		subject_ic = ""

	if(viewer && is_staff(viewer))
		return subject_ic ? "[subject_key]/([subject_ic])" : subject_key

	return subject_key

/datum/mentorhelp/proc/log_message(msg, from_key, to_key, include_in_ticket = TRUE, plain_msg = null, message_type = "mentor")
	var/plain_text = plain_msg || strip_html(msg)
	var/log_msg = plain_text

	var/html_msg = msg
	if(!plain_msg)
		html_msg = "[span_mentorhelp("[from_key] -> [to_key]:")] [msg]"
	else if(from_key && to_key)
		html_msg = "[span_mentorhelp("[from_key] -> [to_key]:")] [plain_text]"

	if(from_key && to_key)
		var/from_ic = ""
		var/to_ic = ""

		if(from_key == author_key)
			from_ic = " ([get_author_ic_name()])"
		else if(mentor && from_key == mentor.key)
			from_ic = ""

		if(to_key == author_key)
			to_ic = " ([get_author_ic_name()])"

		log_msg = "[from_key]([from_ic]) -> [to_key]([to_ic]): [plain_text]"

	log_admin_private(log_msg)

	if(include_in_ticket)
		var/html_message = "[server_timestamp()]: [html_msg]"
		var/list/structured_data = list(
			"timestamp" = round_timestamp(),
			"author" = from_key || "System",
			"message" = html_encode(plain_text),
			"html_message" = html_msg,
			"type" = message_type,
			"islink" = null,
		)

		ticket_interactions[html_message] = structured_data
		latest_message = plain_text
		defer_ticket_panel_update() // [HORIZON-ADD] ADMIN-TICKETS

/datum/mentorhelp/proc/notify(text, to_thread_mentor = TRUE, to_mentors = TRUE, to_staff = TRUE, unformatted_text = null)
	var/list/hitlist = list()
	if(to_thread_mentor && mentor)
		hitlist |= mentor
	for(var/client/candidate in GLOB.admins)
		if(to_mentors && is_mentor(candidate))
			hitlist |= candidate
		else if(to_staff && is_staff(candidate))
			hitlist |= candidate

	var/unformatted = unformatted_text || text
	var/latest_msg_unformatted = unformatted

	for(var/client/receiver in hitlist)
		if(istype(receiver))
			var/msg_to_send = text
			if(!is_staff(receiver))
				if(author_key)
					msg_to_send = replacetext(msg_to_send, author_key, get_author_ic_name())
			var/displaymsg = "[span_mentorhelp("<span class='prefix'>MENTOR LOG:</span> <span class='message'>[msg_to_send]</span>")]"
			to_chat(receiver, displaymsg, confidential = TRUE)

	if(!to_mentors)
		if(author_key)
			latest_msg_unformatted = replacetext(latest_msg_unformatted, author_key, get_author_ic_name())
		latest_message = latest_msg_unformatted

	var/html_message = "[server_timestamp()]: [text]"
	var/list/structured_data = list(
		"timestamp" = round_timestamp(),
		"author" = "System",
		"message" = html_encode(unformatted),
		"html_message" = text,
		"type" = "system",
		"islink" = null,
	)
	ticket_interactions[html_message] = structured_data
	defer_ticket_panel_update() // [HORIZON-ADD] ADMIN-TICKETS

/datum/mentorhelp/proc/broadcast_request(client/opener)
	if(!opener || !open || !check_author())
		return FALSE
	if(mentor)
		return TRUE

	var/message = strip_html(html_decode(
			tgui_input_text(opener.mob, "Please enter your message:", "MentorHelp", null, 500, TRUE)
		))
	if(!message)
		return FALSE
	if(!initial_message)
		initial_message = message

	latest_message = message

	broadcast_unhandled(message, opener)
	return TRUE

/datum/mentorhelp/proc/broadcast_unhandled(msg, client/sender)
	if(!mentor && open)
		message_handlers(msg, sender)
		addtimer(CALLBACK(src, PROC_REF(broadcast_unhandled), msg, sender), 5 MINUTES)

/datum/mentorhelp/proc/message_handlers(msg, client/sender, client/recipient, with_sound = TRUE, staff_only = FALSE, include_keys = TRUE)
	if(!sender || !check_author())
		return

	var/msg_type = "mentor"
	if(sender == author)
		msg_type = "legacy"
	else if(!sender)
		msg_type = "system"

	if(recipient)
		log_message(msg, sender.key, recipient.key, message_type = msg_type)
	else
		log_message(msg, sender.key, "All mentors", message_type = msg_type)

	// Sender feedback
	var/feedback_recipient_text
	if(recipient)
		var/display_text = get_display_name(sender, recipient)
		feedback_recipient_text = "<a href='byond://?src=[REF(src)];action=message'>[display_text]</a>"
	else
		feedback_recipient_text = "mentors"
	to_chat(sender, "[span_mentorhelp("<span class='prefix'>MentorHelp:</span> Message to [feedback_recipient_text]:")] [span_mentor(msg)]", confidential = TRUE)

	// Recipient direct message
	if(recipient)
		if(with_sound && (recipient.prefs?.toggles & SOUND_ADMINHELP))
			SEND_SOUND(recipient, sound('_horizon/sound/mhelp.ogg'))
		to_chat(recipient, wrap_message(msg, sender, recipient), confidential = TRUE)

	for(var/client/admin_client in GLOB.admins)
		var/formatted = msg
		var/soundfile

		if(!admin_client || admin_client == recipient)
			continue

		// Initial broadcast
		else if(!staff_only && !recipient && check_rights_for(admin_client, R_MENTOR))
			formatted = wrap_message(formatted, sender, admin_client)
			soundfile = '_horizon/sound/mhelp.ogg'

		// Eavesdrop
		else if(check_rights_for(admin_client, R_MENTOR) && (!staff_only || is_staff(admin_client)) && admin_client != sender)
			if(include_keys)
				var/sender_text = get_display_name(admin_client, sender)
				var/recipient_text = recipient ? get_display_name(admin_client, recipient) : "All mentors"
				formatted = span_mentorhelp("[sender_text] -> [recipient_text]: ") + msg

		else
			continue

		if(soundfile && with_sound && (admin_client.prefs?.toggles & SOUND_ADMINHELP))
			SEND_SOUND(admin_client, soundfile)
		to_chat(admin_client, formatted, confidential = TRUE)
	return

/datum/mentorhelp/proc/input_message(client/sender)
	if(!sender || !check_open(sender))
		return

	if(sender != author)
		if(!is_mentor(sender))
			return

		// If the mentor forgot to mark the mentorhelp, mark it for them
		if(!mentor)
			mark(sender)

		// Some other mentor is already taking care of this thread
		else if(mentor != sender)
			to_chat(sender, span_mentorhelp("<b>NOTICE:</b> A mentor is already handling this thread!"), confidential = TRUE)
			return

	var/target = mentor
	if(sender == mentor)
		target = author

	var/message = tgui_input_text(sender.mob, "Please enter your message:", "Mentor Help", null, null, TRUE)
	if(message)
		message = strip_html(html_decode(message))
		message_handlers(message, sender, target)
	return

/// Sanitizes and wraps the message with some info and links
/datum/mentorhelp/proc/wrap_message(message, client/sender, client/recipient = null)
	var/message_title = "MentorPM"
	var/message_sender_key = ""
	var/message_sender_options = ""

	if(sender == author)
		message_title = "MentorHelp"
		var/display_text = get_display_name(recipient, sender)
		message_sender_key = "<a href='byond://?src=[REF(src)];action=message'>[display_text]</a>"
		message_sender_options = " (<a class='button' href='byond://?src=[REF(src)];action=mark'>Mark/Unmark</a>"
		message_sender_options += " | <a class='button' href='byond://?src=[REF(src)];action=close'>Close</a> | <a class='button' href='byond://?src=[REF(src)];action=autorespond'>AutoResponse</a>)"
	else
		var/display_text = get_display_name(recipient, sender)
		message_sender_key = "<a href='byond://?src=[REF(src)];action=message'>[display_text]</a>"

	var/message_header = span_mentorhelp("<span class='prefix'>[message_title] from [message_sender_key]:</span> <span class='message'>[message_sender_options]</span><br>")
	var/message_body = "&emsp;[span_mentor("<span class='message'>[message]</span>")]<br>"
	return (message_header + message_body)

/*
 * Marking
 */

/datum/mentorhelp/proc/mark(client/thread_mentor)
	if(!check_author())
		return

	if(!check_open(thread_mentor))
		return

	if(mentor)
		if(mentor == thread_mentor)
			to_chat(thread_mentor, span_mentorhelp("<b>NOTICE:</b> You are already handling this thread!"), confidential = TRUE)
			return
		var/choice = tgui_alert(thread_mentor.mob, "This mentorhelp is already claimed by [mentor.key]. Do you want to override and take over?", "Claim Mentorhelp", list("Override", "Cancel"))
		if(choice != "Override")
			return
		var/client/prev_mentor = mentor
		mentor = thread_mentor
		mentor_key = mentor.key

		log_admin_private("[mentor.key] has overridden [prev_mentor.key] on [author_key]'s mentorhelp")
		notify("[span_green(mentor.key)] has overridden [span_green(prev_mentor.key)] on [span_red(author_key)]'s mentorhelp.",
			unformatted_text = "[mentor.key] has overridden [prev_mentor.key] on [author_key]'s mentorhelp.")
		to_chat(author, span_mentorhelp("NOTICE: [get_display_name(author, mentor)] has taken over your thread and is preparing to respond."), confidential = TRUE)
		return

	if(!thread_mentor)
		return

	if(istype(thread_mentor, /mob))
		var/mob/M = thread_mentor
		thread_mentor = M.client

	if(!istype(thread_mentor))
		return

	if(!is_mentor(thread_mentor))
		return

	mentor = thread_mentor
	mentor_key = mentor.key

	log_admin_private("[mentor.key] has marked [author_key]'s mentorhelp")
	notify("[span_green(mentor.key)] has marked [span_red(author_key)]'s mentorhelp.",
		unformatted_text = "[mentor.key] has marked [author_key]'s mentorhelp.")
	to_chat(author, span_mentorhelp("NOTICE: [get_display_name(author, mentor)] has marked your thread and is preparing to respond."), confidential = TRUE)

/datum/mentorhelp/proc/unmark(client/thread_mentor)
	if(!check_author())
		return

	if(!check_open(thread_mentor))
		return

	if(!mentor)
		return

	if((!thread_mentor || thread_mentor != mentor) && !is_staff(thread_mentor))
		return

	log_admin_private("[mentor.key] has unmarked [author_key]'s mentorhelp")
	notify("[span_green(mentor.key)] has unmarked [span_red(author_key)]'s mentorhelp.",
		unformatted_text = "[mentor.key] has unmarked [author_key]'s mentorhelp.")
	to_chat(author, span_mentorhelp("NOTICE: [get_display_name(author, mentor)] has unmarked your thread and is no longer responding to it."), confidential = TRUE)
	mentor = null
	mentor_key = ""

/*
 * Misc.
 */

/datum/mentorhelp/proc/reopen()
	if(!check_author())
		return

	if(open)
		to_chat(usr, span_warning("This ticket is already open!"), confidential = TRUE)
		return

	if(GLOB.mentorhelp_manager.get_active_ticket_by_ckey(author_key))
		to_chat(usr, span_warning("This user already has an open mentor ticket. Please close it first or use the existing one."), confidential = TRUE)
		return FALSE

	if(!author && author_key)
		for(var/client/C in GLOB.clients)
			if(C.ckey == ckey(author_key))
				author = C
				break

	var/datum/mentorhelp/existing_mh = GLOB.mentorhelp_manager.get_active_ticket_by_ckey(author_key)
	if(existing_mh && existing_mh != src)
		if(tgui_alert(usr, "[get_display_name(usr.client, author)] already has an open mentorhelp thread. Would you like to close it and reopen this one?", "Existing Mentorhelp Found", list("Yes", "No")) == "Yes")
			existing_mh.close(usr.client)
		else
			to_chat(usr, span_notice("Using the existing mentorhelp thread for [get_display_name(usr.client, author)]."), confidential = TRUE)
			return FALSE

	open = TRUE
	closed_at = null
	time_activity["closed_at"] = null

	if(GLOB.mentorhelp_manager.archived_tickets["[id]"] == src)
		GLOB.mentorhelp_manager.archived_tickets -= "[id]"
		GLOB.mentorhelp_manager.active_tickets["[id]"] = src

	if(author)
		author.current_mhelp = src

	log_admin_private("[usr.key] reopened [author_key]'s mentorhelp thread")
	notify("[span_green(usr.key)] has reopened this mentorhelp thread.",
		unformatted_text = "[usr.key] has reopened this mentorhelp thread.")

/datum/mentorhelp/proc/reopenForClient(client/C)
	if(!C || !C.holder)
		return
	usr = C.mob
	reopen()

/datum/mentorhelp/proc/close(client/closer)
	if(!open)
		return

	if(!author)
		notify("[span_red(author_key)]'s mentorhelp thread has been closed due to the author disconnecting.")
		log_admin_private("[author_key]'s mentorhelp thread was closed because of a disconnection")
		open = FALSE
		if(GLOB.mentorhelp_manager.active_tickets["[id]"] == src)
			GLOB.mentorhelp_manager.active_tickets -= "[id]"
			GLOB.mentorhelp_manager.archived_tickets["[id]"] = src
		closed_at = world.time
		time_activity["closed_at"] = round_timestamp(wtime = closed_at)
		return

	if(mentor && closer && (closer != mentor) && (closer != author) && !is_staff(closer))
		to_chat(closer, span_mentorhelp("<b>NOTICE:</b> Another mentor is handling this thread!"), confidential = TRUE)
		return

	if(!open)
		return

	mentor = null
	open = FALSE

	if(GLOB.mentorhelp_manager.active_tickets["[id]"] == src)
		GLOB.mentorhelp_manager.active_tickets -= "[id]"
		GLOB.mentorhelp_manager.archived_tickets["[id]"] = src

	if(closer)
		log_admin_private("[closer.key] closed [author_key]'s mentorhelp")
		if(closer == author)
			to_chat(author, span_notice("You have closed your mentorhelp thread."), confidential = TRUE)
			notify("[span_red(author_key)] closed their mentorhelp thread.",
				unformatted_text = "[author_key] closed their mentorhelp thread.")
		else
			to_chat(author, span_notice("Your mentorhelp thread has been closed by [get_display_name(author, closer)]."), confidential = TRUE)
			notify("[span_green(closer.key)] closed [span_red(author_key)]'s mentorhelp thread.",
				unformatted_text = "[closer.key] closed [author_key]'s mentorhelp thread.")
		closed_at = world.time
		time_activity["closed_at"] = round_timestamp(wtime = closed_at)
		if(author && author.current_mhelp == src)
			author.current_mhelp = null
		return

	to_chat(author, span_notice("Your mentorhelp thread has been closed."), confidential = TRUE)
	notify("[span_red(author_key)]'s mentorhelp thread has been closed.",
			unformatted_text = "[author_key]'s mentorhelp thread has been closed.")
	closed_at = world.time
	time_activity["closed_at"] = round_timestamp(wtime = closed_at)

	if(author && author.current_mhelp == src)
		author.current_mhelp = null

/datum/mentorhelp/proc/Respond(msg, client/responder)
	if(!check_author())
		return

	if(!check_open(responder))
		return

	if(!is_mentor(responder))
		return

	if(!src.mentor)
		mark(responder)

	msg = strip_html(html_decode(msg))
	if(!msg)
		return

	message_handlers(msg, responder, author)
	return TRUE

/datum/mentorhelp/Topic(href, list/href_list)
	if(!usr)
		return
	var/client/C = usr.client
	if(!istype(C))
		return

	switch(href_list["action"])
		if("message")
			input_message(C)
		if("autorespond")
			autoresponse(C)
		if("mark")
			if(!mentor)
				mark(C)
			else
				unmark(C)
		if("close")
			if(C == author || C == mentor || is_staff(C))
				close(C)

/*
 * Autoresponse
 */

/datum/mentorhelp/proc/autoresponse(client/responder)
	if(!check_author())
		return

	if(!check_open(responder))
		return

	if(!is_mentor(responder))
		return

	if(!mentor)
		mark(responder)
	else if(mentor != responder)
		to_chat(responder, span_notice("<b>NOTICE:</b> A mentor is already handling this thread!"), confidential = TRUE)
		return

	var/choice = tgui_input_list(usr, "Which autoresponse option do you want to send to the player?", "Autoresponse", GLOB.mentorreplies)
	var/datum/autoreply/mentor/response = GLOB.mentorreplies[choice]

	if(!response || !istype(response))
		return

	if(!check_author())
		return

	if(!check_open(responder))
		return

	if(!is_mentor(responder))
		return

	if(!mentor)
		mark(responder)
	else if(mentor != responder)
		to_chat(responder, span_notice("<b>NOTICE:</b> A mentor is already handling this thread!"), confidential = TRUE)
		return

	var/msg = "- MentorHelp marked as [response.title]! -"
	msg += "[response.message]"

	message_handlers(msg, responder, author)


/proc/message_mentors(message)
	for(var/client/mentor in GLOB.clients)
		if(is_mentor(mentor))
			to_chat(mentor, message, confidential = TRUE)
	return TRUE

/proc/mentorhelp_by_id(id)
	if(!id)
		return null
	return GLOB.mentorhelp_manager.get_ticket_by_id(id)


/datum/mentorhelp/proc/set_subject(new_subject, client/responder)
	if(!is_mentor(responder))
		return
	src.subject = sanitize(copytext_char(new_subject, 1, 100))
	defer_ticket_panel_update() // [HORIZON-ADD] ADMIN-TICKETS
	return TRUE

/datum/mentorhelp/proc/defer_to_admins(client/deferrer)
	if(!check_author())
		return

	if(!check_open(deferrer))
		return

	if(!is_mentor(deferrer))
		return

	if(mentor && mentor != deferrer)
		to_chat(deferrer, span_warning("This ticket is currently marked by [mentor.key]. Please override their mark to interact with this ticket!"), confidential = TRUE)
		return

	if(author.current_ticket)
		to_chat(deferrer, span_warning("This user already has an active adminhelp ticket. Please close it first or use the existing one."), confidential = TRUE)
		return

	var/options = tgui_alert(deferrer.mob, "Use the first message in this ticket, or a custom option?", "Defer to Admins", list("First Message", "Custom"))
	if(!options)
		return

	var/defer_header = "[deferrer.key] has deferred a ticket ([author_key]) to admins"

	var/message = ""
	switch(options)
		if("First Message")
			message = "[defer_header]\n\n[initial_message]"
		if("Custom")
			var/custom_msg = tgui_input_text(deferrer.mob, "Text to Send to Admins", "Defer to Admins")
			if(!custom_msg)
				return
			message = "[defer_header]\n\n[custom_msg]\n\nOriginal message: [initial_message]"

	if(!message)
		return

	var/datum/admin_help/help_ticket = new /datum/admin_help(message, author, FALSE)
	help_ticket.subject = subject
	help_ticket.AddInteraction("Deferred from Mentorhelp by [deferrer.key].", plain_message = "Deferred from Mentorhelp by [deferrer.key]", message_type = "system")

	notify("[span_red(deferrer.key)] deferred this ticket to admins.",
		unformatted_text = "[deferrer.key] deferred this ticket to admins.")
	to_chat(author, span_mentorhelp("[get_display_name(author, deferrer)] has deferred your ticket to Admins."), confidential = TRUE)
	log_admin_private("[deferrer.key] deferred [author_key]'s mentorhelp to admins.")
	for(var/client/admin in GLOB.admins)
		if(is_mentor(admin) || is_staff(admin))
			to_chat(admin, span_mentorhelp("[get_display_name(admin, deferrer)] has deferred [get_display_name(admin, author)]'s ticket to Admins."), confidential = TRUE)
	close(deferrer)
