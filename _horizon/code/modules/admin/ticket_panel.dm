/datum/ticket_panel
	var/selected_tab = ADMIN_TAB
	var/selected_ticket = null

/datum/ticket_panel/Destroy(force, ...)
	SStgui.close_uis(src)
	return ..()

/datum/ticket_panel/proc/get_player_info(client/C)
	if(!C || !C.mob)
		return null

	var/mob/M = C.mob
	var/list/info = list()

	if(M.real_name)
		info["ic_name"] = M.real_name

	// Antag status instead of faction
	if(M.mind?.special_roles?.len)
		info["faction"] = "Antag: [M.mind.special_roles.Join(", ")]"
	else
		info["faction"] = null

	info["role"] = get_mob_role(M)

	return info

/// [HORIZON-ADD] ADMIN-TICKETS
/// Resolves the mob of the player the given ticket belongs to, based on the selected tab.
/datum/ticket_panel/proc/get_ticket_player(ticket_id)
	switch(selected_tab)
		if(ADMIN_TAB)
			var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
			return istype(AH) ? AH.initiator?.mob : null
		if(MENTOR_TAB)
			var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
			return istype(MH) ? MH.author?.mob : null
	return null

/datum/ticket_panel/proc/strip_pm_prefix(message)
	if(!istext(message) || !message)
		return message
	var/static/regex/pm_prefix = regex(@"^(?:Reply )?PM [Ff]rom[ -].+?(?: to[ -].+?)?: ")
	return pm_prefix.Replace(message, "")

/datum/ticket_panel/proc/instant_update()
	SStgui.update_uis(src)

/proc/broadcast_ticket_panels()
	for(var/client/viewer in GLOB.clients)
		var/datum/ticket_panel/panel = viewer?.ticket_panel
		if(panel)
			panel.instant_update()

/proc/defer_ticket_panel_update()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(broadcast_ticket_panels)), 1, TIMER_UNIQUE)
// [/HORIZON-ADD]

/datum/ticket_panel/proc/format_adminhelp_ticket(datum/admin_help/AH, client/viewer = null)
	var/status = AH.state == AHELP_ACTIVE ? "open" : AH.state == AHELP_RESOLVED ? "resolved" : "closed"

	var/list/formatted_responses = list()
	for(var/key in AH.ticket_interactions)
		var/list/interaction = AH.ticket_interactions[key]
		var/list/stripped = interaction.Copy()
		stripped["message"] = strip_pm_prefix(stripped["message"])
		formatted_responses += list(stripped)

	var/list/player_info = get_player_info(AH.initiator)

	return list(
		"id" = AH.id,
		"subject" = AH.subject,
		"author" = AH.initiator_key_name || "Unknown",
		"message" = AH.initial_message || "No message",
		"latest_message" = strip_pm_prefix(AH.latest_message),
		"status" = status,
		"timestamp" = AH.time_activity["opened_at"],
		"closed_at" = AH.time_activity["closed_at"],
		"claimed_by" = AH.marked_admin,
		"all_responses" = formatted_responses,
		"viewer_is_claiming" = (AH.marked_admin == (viewer ? viewer.ckey : usr?.ckey) ? TRUE : FALSE),
		"is_archived" = (AH.state != AHELP_ACTIVE),
		"ic_name" = player_info ? player_info["ic_name"] : null,
		"faction" = player_info ? player_info["faction"] : null,
		"role" = player_info ? player_info["role"] : null
	)

/datum/ticket_panel/proc/format_mentorhelp_ticket(datum/mentorhelp/MH, client/viewer = null)
	if(!viewer)
		viewer = usr.client

	var/status = MH.open ? (MH.mentor ? "claimed" : "open") : "closed"

	var/list/player_info = get_player_info(MH.author)

	var/ic_name = (player_info ? player_info["ic_name"] : null) || MH.get_author_ic_name()
	var/faction = (player_info ? player_info["faction"] : null)
	var/role = (player_info ? player_info["role"] : null) || MH.get_author_role()

	var/list/formatted_responses = list()
	for(var/key in MH.ticket_interactions)
		var/list/interaction = MH.ticket_interactions[key]
		var/list/filtered_interaction = interaction.Copy()

		filtered_interaction["author"] = MH.get_display_name(viewer, interaction["author"])

		if(viewer && !is_staff(viewer))
			if(MH.author_key && filtered_interaction["message"])
				filtered_interaction["message"] = replacetext(filtered_interaction["message"], MH.author_key, ic_name)

		formatted_responses += list(filtered_interaction)

	var/display_author = MH.get_display_name(viewer, MH.author)

	var/display_msg = MH.initial_message
	var/display_latest = MH.latest_message
	if(viewer && !is_staff(viewer))
		if(MH.author_key)
			display_msg = replacetext(display_msg, MH.author_key, ic_name)
			display_latest = replacetext(display_latest, MH.author_key, ic_name)

	return list(
		"id" = MH.id,
		"subject" = MH.subject,
		"author" = display_author || "Unknown",
		"message" = display_msg || "No message",
		"latest_message" = display_latest,
		"status" = status,
		"timestamp" = MH.time_activity["opened_at"],
		"closed_at" = MH.time_activity["closed_at"],
		"claimed_by" = MH.mentor ? MH.mentor.ckey : null,
		"all_responses" = formatted_responses,
		"viewer_is_claiming" = (MH.mentor && (MH.mentor.ckey == viewer?.ckey) ? TRUE : FALSE),
		"is_archived" = !MH.open,
		"ic_name" = ic_name,
		"faction" = faction,
		"role" = role
	)

/datum/ticket_panel/ui_data(mob/user)
	if(!user?.client)
		return

	var/client/C = user.client
	if(!C.ticket_panel)
		C.ticket_panel = new /datum/ticket_panel()

	var/list/data = list(
		"is_admin" = is_staff(C) ? TRUE: FALSE,
		"is_mentor" = is_mentor(C) ? TRUE : FALSE,
		"selected_tab" = C.ticket_panel.selected_tab,
		"selected_ticket" = C.ticket_panel.selected_ticket,
		"admin_open_tickets" = list(),
		"mentor_open_tickets" = list(),
		"admin_archived_tickets" = list(),
		"mentor_archived_tickets" = list()
	)

	if(is_staff(user.client))
		for(var/datum/admin_help/AH in GLOB.ahelp_tickets.active_tickets)
			data["admin_open_tickets"] += list(format_adminhelp_ticket(AH, C))

		for(var/datum/admin_help/AH in GLOB.ahelp_tickets.closed_tickets)
			data["admin_archived_tickets"] += list(format_adminhelp_ticket(AH, C))

		for(var/datum/admin_help/AH in GLOB.ahelp_tickets.resolved_tickets)
			data["admin_archived_tickets"] += list(format_adminhelp_ticket(AH, C))

	for(var/id in GLOB.mentorhelp_manager.active_tickets)
		var/datum/mentorhelp/MH = GLOB.mentorhelp_manager.get_ticket_by_id(id)
		if(istype(MH))
			data["mentor_open_tickets"] += list(format_mentorhelp_ticket(MH, C))

	for(var/id in GLOB.mentorhelp_manager.archived_tickets)
		var/datum/mentorhelp/MH = GLOB.mentorhelp_manager.get_ticket_by_id(id)
		if(istype(MH))
			data["mentor_archived_tickets"] += list(format_mentorhelp_ticket(MH, C))

	return data

/datum/ticket_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/client/current_client = ui.user.client
	var/client/parent_client = current_client
	var/mob/current_mob = ui.user

	if(!is_staff(current_client))
		selected_tab = MENTOR_TAB

	switch(action)
		if("refresh")
			return TRUE

		if("select_tab")
			if(params["tab"] == ADMIN_TAB && !is_staff(current_client))
				return FALSE
			if(!current_client.ticket_panel)
				parent_client.ticket_panel = new /datum/ticket_panel()
			parent_client.ticket_panel.selected_tab = params["tab"]
			parent_client.ticket_panel.selected_ticket = null
			return TRUE

		if("select_ticket")
			if(!parent_client.ticket_panel)
				parent_client.ticket_panel = new /datum/ticket_panel()
			parent_client.ticket_panel.selected_ticket = text2num(params["ticket_id"])
			return TRUE

		if("start_adminhelp")
			if(!is_staff(current_client))
				tgui_alert(current_mob, "Silly! You need to be an admin to use this feature.")
				return FALSE

			var/list/possible_targets = list()
			for(var/client/target in GLOB.clients)
				if(!target.mob)
					continue
				possible_targets[target] = "[target.key]"

			if(!LAZYLEN(possible_targets))
				tgui_alert(current_mob, "No players available to message.")
				return FALSE

			var/client/target = tgui_input_list(current_mob, "Select a player to message:", "New Adminhelp", possible_targets)
			if(!target || !istype(target) || !target.mob)
				return FALSE

			if(istype(target.current_ticket) && target.current_ticket.state == AHELP_ACTIVE)
				parent_client.ticket_panel.selected_tab = ADMIN_TAB
				parent_client.ticket_panel.selected_ticket = target.current_ticket.id
				to_chat(parent_client, span_notice("Switched to existing admin ticket for [target.key]"), confidential = TRUE)
				return TRUE

			parent_client.cmd_admin_pm(target, null)
			return TRUE

		if("start_mentorhelp")
			if(!is_mentor(current_client) && !is_staff(current_client))
				tgui_alert(current_mob, "You need to be a mentor or admin to use this feature.")
				return FALSE

			var/list/possible_targets = list()
			for(var/client/target in GLOB.clients)
				if(!target.mob)
					continue
				var/ic_name = target.mob.real_name || target.mob.name || "Unknown"
				if(is_staff(current_client))
					possible_targets[target] = "[target.key]/([ic_name])"
				else
					possible_targets[target] = "[ic_name]"

			if(!LAZYLEN(possible_targets))
				tgui_alert(current_mob, "No non-staff players available to message.")
				return FALSE

			var/client/target = tgui_input_list(current_mob, "Select a player to message:", "New Mentorhelp", possible_targets)
			if(!target || !istype(target) || !target.mob)
				return FALSE

			if(istype(target.current_mhelp) && target.current_mhelp.open)
				parent_client.ticket_panel.selected_tab = MENTOR_TAB
				parent_client.ticket_panel.selected_ticket = target.current_mhelp.id
				to_chat(parent_client, span_notice("Switched to existing mentor ticket for [target.current_mhelp.get_display_name(current_client, target)]"), confidential = TRUE)
				return TRUE

			if(GLOB.mentorhelp_manager.get_active_ticket_by_ckey(target.ckey))
				to_chat(current_mob, span_warning("This user already has an open mentor ticket. Please close it first or use the existing one."), confidential = TRUE)
				return FALSE

			var/msg = tgui_input_text(current_mob, "Enter your message:", "New Mentorhelp")
			if(!msg)
				return FALSE

			var/datum/mentorhelp/MH = GLOB.mentorhelp_manager.create_ticket(target, msg)
			if(!MH)
				return FALSE
			MH.notify(span_mentorhelp("[MH.get_display_name(null, current_client)] started a mentor conversation with [MH.get_display_name(current_client, target)]"),
				unformatted_text = "[MH.get_display_name(null, parent_client)] started a mentor conversation with [MH.get_display_name(current_client, target)]")
			MH.initial_message = msg
			MH.mark(parent_client)
			MH.Respond(msg, parent_client)

			return TRUE

		if("open_player_panel")
			if(!is_staff(current_client))
				to_chat(parent_client, span_warning("You don't have permission to open a player panel."), confidential = TRUE)
				return FALSE

			var/mob/player = get_ticket_player(text2num(params["ticket_id"]))
			if(!player || !player.ckey)
				to_chat(current_mob, span_warning("Could not find player associated with this ticket."), confidential = TRUE)
				return FALSE

			SSadmin_verbs.dynamic_invoke_verb(current_client, /datum/admin_verb/options_panel, player)
			return TRUE

		if("open_logs")
			if(!is_staff(current_client))
				to_chat(parent_client, span_warning("You don't have permission to open logs."), confidential = TRUE)
				return FALSE

			var/mob/player = get_ticket_player(text2num(params["ticket_id"]))
			if(!player)
				to_chat(current_mob, span_warning("Could not find player associated with this ticket."), confidential = TRUE)
				return FALSE

			var/datum/log_viewer/LV = new(player)
			LV.ui_interact(current_mob)
			return TRUE

		if("autoreply")
			var/ticket_id = text2num(params["ticket_id"])
			if(selected_tab == ADMIN_TAB)
				var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
				if(AH)
					AH.AutoReply()
					return TRUE
			else
				var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
				if(MH)
					MH.autoresponse(current_client)
					return TRUE

		if("reopen_ticket")
			var/ticket_id = text2num(params["ticket_id"])
			if(selected_tab == ADMIN_TAB)
				var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
				if(!AH)
					to_chat(current_mob, span_warning("Invalid admin ticket selected."), confidential = TRUE)
					return FALSE

				var/client/target = AH.initiator
				if(!target)
					to_chat(current_mob, span_warning("Could not find player associated with this ticket."), confidential = TRUE)
					return FALSE

				if(target.current_ticket && target.current_ticket.state == AHELP_ACTIVE)
					to_chat(current_mob, span_warning("This user already has an open ticket. Please close it first or use the existing one."), confidential = TRUE)
					return FALSE
				AH.Reopen()

				return TRUE
			else
				var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
				if(!MH)
					to_chat(current_mob, span_warning("Invalid mentor ticket selected."), confidential = TRUE)
					return FALSE

				if(GLOB.mentorhelp_manager.get_active_ticket_by_ckey(MH.author_key))
					to_chat(current_mob, span_warning("This user already has an open mentor ticket. Please close it first or use the existing one."), confidential = TRUE)
					return FALSE

				MH.reopen()

				return TRUE

		if("close_ticket")
			var/ticket_id = text2num(params["ticket_id"])
			switch(selected_tab)
				if(ADMIN_TAB)
					var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
					if(AH)
						if(AH.marked_admin && AH.marked_admin != current_mob.ckey)
							to_chat(current_mob, span_warning("You don't have permission to close this ticket."), confidential = TRUE)
							return
						if(AH.state != AHELP_ACTIVE)
							to_chat(current_mob, span_warning("This ticket is already [AH.state == AHELP_RESOLVED ? "resolved" : "closed"]."), confidential = TRUE)
							return
						AH.Resolve(current_mob.ckey, FALSE)
						message_admins("[key_name_admin(current_mob)] closed ticket #[ticket_id]")
						log_admin("Ticket #[ticket_id] closed by [key_name(current_mob)]")
				if(MENTOR_TAB)
					var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
					if(MH)
						if(!MH.open)
							to_chat(current_mob, span_warning("This mentor ticket is already closed."), confidential = TRUE)
							return

						if(MH.mentor && MH.mentor.ckey != current_mob.ckey && !is_staff(current_client))
							to_chat(current_mob, span_warning("You don't have permission to close this ticket."), confidential = TRUE)
							return

						MH.close(current_client)
						log_admin_private("Mentor ticket from [MH.author_key] closed by [key_name(current_mob)]")
					else
						to_chat(current_mob, span_warning("This ticket does not exist or has been deleted."), confidential = TRUE)
			return TRUE

		if("claim_ticket")
			var/ticket_id = text2num(params["ticket_id"])
			switch(selected_tab)
				if(ADMIN_TAB)
					var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
					if(AH)
						if(AH.marked_admin)
							if(AH.marked_admin == current_mob.ckey)
								AH.unmark_ticket()
								message_admins("[key_name_admin(current_mob)] unclaimed ticket #[ticket_id]")
							else
								AH.mark_ticket(current_mob)
						else
							AH.mark_ticket(current_mob)
							message_admins("[key_name_admin(current_mob)] claimed ticket #[ticket_id]")
				else
					var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
					if(!MH)
						return FALSE

					if(MH.mentor)
						if(MH.mentor.ckey == current_mob.ckey)
							MH.unmark(current_client)
						else
							MH.mark(current_client)
					else
						MH.mark(current_client)

			return TRUE

		if("defer_ticket")
			var/ticket_id = text2num(params["ticket_id"])
			switch(selected_tab)
				if(ADMIN_TAB)
					var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
					if(AH)
						AH.defer_to_mentors()
				if(MENTOR_TAB)
					var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
					if(MH)
						MH.defer_to_admins(current_client)
			return TRUE

		if("reply_ticket")
			var/ticket_id = text2num(params["ticket_id"])
			if(!ticket_id)
				return

			// Chat composer sends the text inline; the modal stays as a
			// fallback for callers that don't pass a message.
			var/message = params["message"]
			if(!istext(message))
				message = tgui_input_text(current_mob, "Enter your response:", "Reply to Ticket", multiline = TRUE)
			message = trim(message)
			if(!message || !current_mob.client)
				return

			if(selected_tab == ADMIN_TAB)
				var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
				if(AH)
					if(!AH.marked_admin)
						AH.mark_ticket(current_mob)
					current_client.cmd_admin_pm(AH.initiator, message)
			else
				var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
				if(MH)
					if(!MH.mentor)
						MH.mark(current_client)
					MH.Respond(message, current_client)

			return TRUE

		if("set_subject")
			var/ticket_id = text2num(params["ticket_id"])
			if(!ticket_id)
				return

			if(selected_tab == ADMIN_TAB)
				var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
				if(AH)
					var/new_subject = tgui_input_text(current_mob, "Enter a subject for this ticket:", "Set Ticket Subject", AH.subject, 100)
					if(!new_subject)
						return
					AH.set_subject(new_subject, current_client)
			else
				var/datum/mentorhelp/MH = mentorhelp_by_id(ticket_id)
				if(!MH)
					to_chat(current_mob, span_warning("This ticket does not exist."), confidential = TRUE)
					return
				var/new_subject = tgui_input_text(current_mob, "Enter a subject for this ticket:", "Set Ticket Subject", MH.subject, 100)
				if(!new_subject)
					return
				MH.set_subject(new_subject, current_mob.client)

			return TRUE

		if("get_author_notes")
			if(!check_rights_for(current_client, R_ADMIN))
				to_chat(current_mob, span_notice("You don't have permission to view author notes."), confidential = TRUE)
				return FALSE

			if(!(selected_tab == ADMIN_TAB))
				to_chat(current_mob, span_warning("You can only view author notes from admin tickets."), confidential = TRUE)
				return FALSE

			var/ticket_id = text2num(params["ticket_id"])
			var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
			if(!AH)
				to_chat(current_mob, span_warning("Unable to find ticket."), confidential = TRUE)
				return FALSE

			if(!AH.initiator || !AH.initiator.mob || !AH.initiator.mob.ckey)
				to_chat(current_mob, span_warning("Unable to find mob."), confidential = TRUE)
				return FALSE

			// Use the existing notes/messages system via topic href
			usr << browse("byond://?_src_=holder;[HrefToken()];showmessageckey=[AH.initiator.ckey]", "window=notes_[AH.initiator.ckey];size=1000x600")
			return TRUE

		if("ban_author")
			if(!check_rights_for(current_client, R_BAN))
				to_chat(current_mob, span_warning("You don't have permission to ban players."), confidential = TRUE)
				return FALSE

			var/ticket_id = text2num(params["ticket_id"])
			if(!ticket_id)
				return FALSE

			var/datum/admin_help/AH
			if(selected_tab == ADMIN_TAB)
				AH = GLOB.ahelp_tickets.TicketByID(ticket_id)
			else
				to_chat(current_mob, span_warning("Can only ban from admin tickets."), confidential = TRUE)
				return FALSE

			if(!AH || !AH.initiator)
				to_chat(current_mob, span_warning("Unable to find ticket or player."), confidential = TRUE)
				return FALSE

			var/mob/banned_mob = AH.initiator.mob
			if(!banned_mob || !banned_mob.ckey)
				to_chat(current_mob, span_warning("Unable to find player to ban."), confidential = TRUE)
				return FALSE

			// Use the existing ban panel system
			current_client.holder.ban_panel(player_key = banned_mob.ckey, player_ip = banned_mob.client?.address, player_cid = banned_mob.client?.computer_id, role = "Server", duration = BAN_PANEL_PERMANENT)

			return TRUE

/datum/ticket_panel/ui_interact(mob/user, datum/tgui/ui)
	// No throttle: every SStgui autoupdate tick (~1s) rebuilds ui_data and pushes
	// it, and ticket events (new message, state change) push immediately through
	// defer_ticket_panel_update() without waiting for the next tick.
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TicketPanel", "Ticket Panel")
		ui.set_autoupdate(TRUE)
		ui.open()


/datum/ticket_panel/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE

/// Admin verb to open the ticket panel
ADMIN_VERB(ticket_panel, R_ADMIN | R_MENTOR, "Ticket Panel", "Allows you to see tickets open for adminhelps and mentorhelps.", ADMIN_CATEGORY_GAME)
	if(!is_mentor(user) && !is_staff(user))
		to_chat(user, span_warning("You need to be an admin or mentor in order to access this panel..."), confidential = TRUE)
		return

	if(!user.mob)
		return

	var/datum/ticket_panel/ticket_panel = user.ticket_panel

	if(!ticket_panel)
		ticket_panel = new()
		user.ticket_panel = ticket_panel

	ticket_panel.ui_interact(user.mob)
