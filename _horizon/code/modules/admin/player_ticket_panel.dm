/**
 * # Player Ticket Panel
 *
 * Player-facing TGUI chat with staff about the viewing player's own ticket.
 * Simplified single-conversation view of the staff Ticket Panel design:
 *
 * - No ticket list sidebar: the panel always shows the single most relevant
 *   ticket of the selected type (the open one, else the newest archived
 *   one); a header toggle switches to the player's other ticket type.
 * - Ticket ids are never displayed to the player (they would leak the
 *   round-wide ticket count); ids only flow through act params for routing.
 * - Only the viewing player's own tickets are ever formatted or reachable
 *   through ui_act, so other players' tickets stay invisible.
 * - The player can close their own open ticket (admin or mentor) from the
 *   panel, mirroring the mentorhelp close behaviour.
 */
/datum/player_ticket_panel
	var/selected_tab = "admin"
	var/selected_ticket = null

/datum/player_ticket_panel/Destroy(force, ...)
	SStgui.close_uis(src)
	return ..()

/datum/player_ticket_panel/proc/instant_update()
	SStgui.update_uis(src)

/datum/player_ticket_panel/ui_state(mob/user)
	return GLOB.always_state

/// Author display name for the player's view of a ticket log entry.
/// The player's own messages show as "You" instead of their ckey.
/datum/player_ticket_panel/proc/format_response_author(client/viewer, author)
	if(!istext(author) || author == "System")
		return "System"
	if(ckey(author) == viewer?.ckey)
		return "You"
	return author

/// Formats one of the player's own adminhelp tickets for them.
/datum/player_ticket_panel/proc/format_player_adminhelp_ticket(datum/admin_help/AH, client/viewer)
	var/status = AH.state == AHELP_ACTIVE ? "open" : AH.state == AHELP_RESOLVED ? "resolved" : "closed"

	var/list/formatted_responses = list()
	for(var/key in AH.ticket_interactions)
		var/list/interaction = AH.ticket_interactions[key]
		var/list/stripped = interaction.Copy()
		stripped["message"] = strip_pm_prefix(stripped["message"])
		stripped["author"] = format_response_author(viewer, stripped["author"])
		formatted_responses += list(stripped)

	return list(
		"id" = AH.id,
		"subject" = AH.subject,
		"status" = status,
		"timestamp" = AH.time_activity["opened_at"],
		"closed_at" = AH.time_activity["closed_at"],
		"claimed_by" = AH.marked_admin,
		"all_responses" = formatted_responses,
		"is_archived" = (AH.state != AHELP_ACTIVE),
	)

/// Formats one of the player's own mentorhelp tickets for them.
/datum/player_ticket_panel/proc/format_player_mentorhelp_ticket(datum/mentorhelp/MH, client/viewer)
	if(!viewer)
		viewer = usr.client

	var/status = MH.open ? (MH.mentor ? "claimed" : "open") : "closed"

	var/list/formatted_responses = list()
	for(var/key in MH.ticket_interactions)
		var/list/interaction = MH.ticket_interactions[key]
		var/list/stripped = interaction.Copy()
		stripped["message"] = strip_pm_prefix(stripped["message"])

		var/author_name = stripped["author"]
		if(!istext(author_name) || author_name == "System")
			stripped["author"] = "System"
		else if(ckey(author_name) == ckey(MH.author_key))
			stripped["author"] = "You"
		else
			stripped["author"] = MH.get_display_name(viewer, author_name)
		formatted_responses += list(stripped)

	return list(
		"id" = MH.id,
		"subject" = MH.subject,
		"status" = status,
		"timestamp" = MH.time_activity["opened_at"],
		"closed_at" = MH.time_activity["closed_at"],
		"claimed_by" = MH.mentor ? MH.get_display_name(viewer, MH.mentor) : null,
		"all_responses" = formatted_responses,
		"is_archived" = !MH.open,
	)

/// Whether the player has any own tickets of the given type, open or archived.
/datum/player_ticket_panel/proc/has_own_tickets(client/C, tab)
	if(!C)
		return FALSE
	if(tab == "admin")
		return length(GLOB.ahelp_tickets.TicketsByCKey(C.ckey)) > 0
	for(var/list/mhelp_list in list(GLOB.mentorhelp_manager.active_tickets, GLOB.mentorhelp_manager.archived_tickets))
		for(var/id in mhelp_list)
			var/datum/mentorhelp/MH = mhelp_list[id]
			if(istype(MH) && ckey(MH.author_key) == C.ckey)
				return TRUE
	return FALSE

/// Selects the most relevant own ticket for the current selected_tab: the
/// open one first, then the newest archived one, or null if there is none.
/datum/player_ticket_panel/proc/pick_best_ticket(client/C)
	if(!C)
		return
	if(selected_tab == "admin")
		var/datum/admin_help/open_admin = GLOB.ahelp_tickets.CKey2ActiveTicket(C.ckey)
		if(open_admin)
			selected_ticket = open_admin.id
			return
		var/datum/admin_help/last_admin
		for(var/datum/admin_help/AH in GLOB.ahelp_tickets.TicketsByCKey(C.ckey))
			if(AH.state != AHELP_ACTIVE && (!last_admin || AH.id > last_admin.id))
				last_admin = AH
		selected_ticket = last_admin?.id
		return
	var/datum/mentorhelp/open_mentor = GLOB.mentorhelp_manager.get_active_ticket_by_ckey(C.ckey)
	if(open_mentor)
		selected_ticket = open_mentor.id
		return
	var/datum/mentorhelp/last_mentor
	for(var/id in GLOB.mentorhelp_manager.archived_tickets)
		var/datum/mentorhelp/MH = GLOB.mentorhelp_manager.archived_tickets[id]
		if(istype(MH) && ckey(MH.author_key) == C.ckey && (!last_mentor || MH.id > last_mentor.id))
			last_mentor = MH
	selected_ticket = last_mentor?.id

/datum/player_ticket_panel/ui_data(mob/user)
	var/client/C = user?.client
	if(!C)
		return

	// Keep the selection valid: if the selected ticket vanished (round end,
	// cleanup), fall back to the most relevant ticket for this tab.
	if(isnull(selected_ticket) || !get_own_ticket(C, selected_ticket))
		pick_best_ticket(C)

	var/list/data = list(
		"selected_tab" = selected_tab,
		"has_admin_tickets" = has_own_tickets(C, "admin"),
		"has_mentor_tickets" = has_own_tickets(C, "mentor"),
		"selected_ticket" = null,
	)

	if(!isnull(selected_ticket))
		var/datum/own_ticket = get_own_ticket(C, selected_ticket)
		if(selected_tab == "admin")
			var/datum/admin_help/AH = own_ticket
			if(AH)
				data["selected_ticket"] = format_player_adminhelp_ticket(AH, C)
		else
			var/datum/mentorhelp/MH = own_ticket
			if(MH)
				data["selected_ticket"] = format_player_mentorhelp_ticket(MH, C)

	return data

/// Resolves one of the player's own tickets by id (scoped to the selected
/// tab), or null. Never trust ticket ids coming from ui_act params.
/datum/player_ticket_panel/proc/get_own_ticket(client/C, ticket_id)
	if(!C || !ticket_id)
		return null
	if(selected_tab == "admin")
		for(var/datum/admin_help/AH in GLOB.ahelp_tickets.TicketsByCKey(C.ckey))
			if(AH.id == ticket_id)
				return AH
	else
		var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
		if(istype(MH) && ckey(MH.author_key) == C.ckey)
			return MH
	return null

/datum/player_ticket_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/client/C = ui.user?.client
	if(!C)
		return

	switch(action)
		if("select_tab")
			var/tab = params["tab"]
			if(tab != "admin" && tab != "mentor")
				return FALSE
			selected_tab = tab
			// Simplified window with no ticket list: switching the type
			// jumps straight to that type's most relevant own ticket.
			selected_ticket = null
			pick_best_ticket(C)
			return TRUE

		if("new_ticket")
			GLOB.admin_help_ui_handler.ui_interact(C.mob)
			return TRUE

		if("reply_ticket")
			var/message = sanitize_text(trim(params["message"]))
			var/ticket_id = text2num(params["ticket_id"])
			if(!message || !ticket_id)
				return FALSE

			var/datum/own_ticket = get_own_ticket(C, ticket_id)
			if(!own_ticket)
				return FALSE

			if(selected_tab == "admin")
				var/datum/admin_help/AH = own_ticket
				if(AH.state != AHELP_ACTIVE || C.current_ticket != AH)
					to_chat(C, span_warning("This ticket is closed. Please open a new one instead."), confidential = TRUE)
					return FALSE
				// Reuses the F1 window pipeline (mute, spam and say_disabled checks)
				GLOB.admin_help_ui_handler.perform_adminhelp(C, message, FALSE)
			else
				var/datum/mentorhelp/MH = own_ticket
				if(!MH.open || C.current_mhelp != MH)
					to_chat(C, span_warning("This mentor ticket is closed. Please open a new one instead."), confidential = TRUE)
					return FALSE
				GLOB.admin_help_ui_handler.perform_mentorhelp(C, message)

			instant_update()
			return TRUE

		if("close_ticket")
			var/ticket_id = text2num(params["ticket_id"])
			if(!ticket_id)
				return FALSE

			if(selected_tab == "mentor")
				var/datum/mentorhelp/MH = get_own_ticket(C, ticket_id)
				if(!istype(MH) || !MH.open)
					return FALSE

				MH.close(C)
			else
				// [HORIZON-EDIT] ADMIN-TICKETS: the initiator can
				// close their own admin ticket too, mirroring
				// mentor ticket behaviour
				var/datum/admin_help/AH = get_own_ticket(C, ticket_id)
				if(!istype(AH) || AH.state != AHELP_ACTIVE)
					return FALSE

				AH.player_close(C)

			instant_update()
			return TRUE

/datum/player_ticket_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerTicketPanel", "Ticket Panel")
		ui.set_autoupdate(TRUE)
		ui.open()

/// Opens the panel for a client, showing their most relevant ticket: the
/// open admin ticket, then the open mentorhelp thread, then the newest
/// archived ticket (admin first). Mirrors the legacy view_latest_ticket
/// fallback chain and the F1 redirect behavior.
/datum/player_ticket_panel/proc/open_for(client/C)
	if(!C)
		return

	selected_ticket = null
	selected_tab = "admin"

	if(istype(C.current_ticket))
		selected_ticket = C.current_ticket.id
	else if(istype(C.current_mhelp) && C.current_mhelp.open)
		selected_tab = "mentor"
	else
		// No open ticket: prefer whichever type has the newest archived one
		var/datum/admin_help/last_admin
		for(var/datum/admin_help/AH in GLOB.ahelp_tickets.TicketsByCKey(C.ckey))
			if(AH.state != AHELP_ACTIVE && (!last_admin || AH.id > last_admin.id))
				last_admin = AH
		var/datum/mentorhelp/last_mentor
		for(var/id in GLOB.mentorhelp_manager.archived_tickets)
			var/datum/mentorhelp/MH = GLOB.mentorhelp_manager.archived_tickets[id]
			if(istype(MH) && ckey(MH.author_key) == C.ckey && (!last_mentor || MH.id > last_mentor.id))
				last_mentor = MH
		if(!last_admin && last_mentor)
			selected_tab = "mentor"

	// Fill in the selection for the chosen tab if it was not set above
	if(isnull(selected_ticket))
		pick_best_ticket(C)

	if(C.mob)
		ui_interact(C.mob)
// [/HORIZON-ADD]
