// [HORIZON-EDIT] NewTooltip
/*
Call openToolTip(usr, src, params, title, content) from MouseEntered() and closeToolTip(usr) from MouseExited().
The tooltip is attached to the object (screen-loc minus icon-x/y), measured while hidden, then placed with one winset.
Themes are CSS classes in tooltip.html; by default one is chosen from the player's UI style.
*/

#define TOOLTIP_WINDOW_PREFIX "ttooltip"
#define TOOLTIP_LOAD_TIMEOUT (5 SECONDS)

/datum/tooltip
	var/client/owner
	var/window
	var/window_created_at = 0
	var/loaded = FALSE
	var/active = FALSE
	var/atom/last_target
	var/seq = 0
	var/list/options
	var/pending_payload

/datum/tooltip/New(client/C)
	..()
	if(!istype(C))
		return
	owner = C
	INVOKE_ASYNC(src, PROC_REF(create_window))

/datum/tooltip/Destroy(force)
	clear_target()
	if(owner && window)
		winset(owner, window, "parent=none")
	owner = null
	options = null
	pending_payload = null
	return ..()

/datum/tooltip/proc/create_window()
	if(!owner)
		return
	if(window)
		winset(owner, window, "parent=none")
	window = "[TOOLTIP_WINDOW_PREFIX][round(world.time)][rand(1, 999999)]"
	loaded = FALSE
	window_created_at = world.time
	winset(owner, window, list2params(list(
		"parent" = SKIN_MAP_SCREEN,
		"type" = "browser",
		"pos" = "0,0",
		"size" = "1x1",
		"anchor1" = "0,0",
		"is-visible" = "false",
		"is-disabled" = "true", // never steal mouse input from the map
	)))
	owner << browse(build_page(), "window=[window]")
	winset(owner, SKIN_MAPWINDOW_MAP, "focus=1") // browse() takes focus

/datum/tooltip/proc/build_page()
	var/html = file2text('code/modules/tooltip/tooltip.html')
	var/map_control = SKIN_MAPWINDOW_MAP
	var/config = "<script>window.tooltip_config = { ref: '[REF(src)]', windowId: '[window]', mapControlId: '[map_control]' };</script>"
	return replacetext(html, "<!-- TOOLTIP_CONFIG -->", config)

/// Rebuild the window if its page never reported in
/datum/tooltip/proc/ensure_window()
	if(!window || (!loaded && world.time - window_created_at > TOOLTIP_LOAD_TIMEOUT))
		create_window()

/// Show a tooltip below `target` (above if there is no room). `mouse` is the params string of MouseEntered().
/datum/tooltip/proc/show(atom/target, mouse, title, content, theme = "default")
	if(!owner || QDELETED(target))
		return FALSE
	if(!title && !content)
		return FALSE
	var/list/mouse_data = parse_mouse(mouse)
	if(!mouse_data)
		return FALSE

	ensure_window()
	set_target(target)

	var/list/text_parts = build_text(title, content)
	var/list/view_tiles = getviewsize(owner.view)

	options = list(
		"title" = text_parts[1],
		"content" = text_parts[2],
		"theme" = theme || "default",
		"mouse" = mouse_data,
		"bounds" = get_target_bounds(target),
		"view" = list("width" = view_tiles[1], "height" = view_tiles[2]),
	)
	active = TRUE
	push()
	return TRUE

/// Replace the text of the tooltip that is showing, keeping its place
/datum/tooltip/proc/update_text(title, content)
	if(!active || !owner || !length(options))
		return FALSE
	var/list/text_parts = build_text(title, content)
	options["title"] = text_parts[1]
	options["content"] = text_parts[2]
	push()
	return TRUE

/datum/tooltip/proc/hide()
	pending_payload = null
	clear_target()
	if(!active)
		return TRUE
	active = FALSE
	seq++
	if(loaded && owner)
		owner << output(list2params(list(seq)), "[window]:tooltip.hide")
	return TRUE

/datum/tooltip/proc/push()
	seq++
	var/payload = json_encode(list(
		"seq" = seq,
		"options" = options,
		"tile" = list("width" = ICON_SIZE_X, "height" = ICON_SIZE_Y),
	))
	if(!loaded)
		pending_payload = payload
		return
	pending_payload = null
	owner << output(list2params(list(payload)), "[window]:tooltip.show")

/datum/tooltip/proc/build_text(title, content)
	if(istext(title) && istext(content) && length(title) && length(content))
		title = "<h1>[title]</h1>"
		content = "<p>[content]</p>"
	else if(length(title))
		title = "<p>[title]</p>"
	else if(length(content))
		content = "<p>[content]</p>"
	if(istext(title))
		title = replacetext(title, "\proper", "")
		title = replacetext(title, "\improper", "")
	return list(title || "", content || "")

/// screen-loc is the cursor on screen, icon-x/y (vis-x/y for vis_contents) the cursor inside the object's icon.
/// Returns null when screen-loc is missing or malformed.
/datum/tooltip/proc/parse_mouse(mouse)
	if(!istext(mouse))
		return null
	var/list/params_list = params2list(mouse)
	var/screen_loc_text = params_list["screen-loc"]
	if(!istext(screen_loc_text))
		return null
	var/list/screen_loc = splittext(screen_loc_text, ",")
	if(length(screen_loc) != 2)
		return null
	var/list/left_parts = splittext(screen_loc[1], ":")
	var/list/bottom_parts = splittext(screen_loc[2], ":")
	var/left_tiles = text2num(left_parts[1])
	var/bottom_tiles = text2num(bottom_parts[1])
	if(isnull(left_tiles) || isnull(bottom_tiles))
		return null
	return list(
		"left" = list(
			"tiles" = left_tiles,
			"pixels" = length(left_parts) >= 2 ? text2num(left_parts[2]) : 0,
			"icon" = text2num(params_list["icon-x"]),
			"vis" = text2num(params_list["vis-x"]),
		),
		"bottom" = list(
			"tiles" = bottom_tiles,
			"pixels" = length(bottom_parts) >= 2 ? text2num(bottom_parts[2]) : 0,
			"icon" = text2num(params_list["icon-y"]),
			"vis" = text2num(params_list["vis-y"]),
		),
	)

/// Size of the object on screen in unscaled pixels (wide HUD slots are 48x32)
/datum/tooltip/proc/get_target_bounds(atom/target)
	var/static/list/dimensions_by_file = list()
	var/target_icon = target.icon
	if(!isfile(target_icon))
		return list("width" = ICON_SIZE_X, "height" = ICON_SIZE_Y)
	var/cache_key = "[target_icon]"
	var/list/dimensions = dimensions_by_file[cache_key]
	if(!dimensions)
		var/icon/measured = icon(target_icon)
		dimensions = list(measured.Width() || ICON_SIZE_X, measured.Height() || ICON_SIZE_Y)
		dimensions_by_file[cache_key] = dimensions
	return list("width" = dimensions[1], "height" = dimensions[2])

/datum/tooltip/proc/set_target(atom/target)
	if(last_target == target)
		return
	if(last_target)
		UnregisterSignal(last_target, COMSIG_QDELETING)
	last_target = target
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_qdel))

/datum/tooltip/proc/clear_target()
	if(last_target)
		UnregisterSignal(last_target, COMSIG_QDELETING)
		last_target = null

/datum/tooltip/proc/on_target_qdel(datum/source)
	SIGNAL_HANDLER

	if(source != last_target)
		return
	last_target = null
	INVOKE_ASYNC(src, PROC_REF(hide))

/// The page only reports that it has loaded, or that something went wrong
/datum/tooltip/Topic(href, href_list)
	..()
	if(!owner || usr?.client != owner)
		return
	if(href_list["window"] != window) // late word from a replaced window
		return
	switch(href_list["action"])
		if("loaded")
			loaded = TRUE
			if(active && pending_payload)
				var/payload = pending_payload
				pending_payload = null
				owner << output(list2params(list(payload)), "[window]:tooltip.show")
		if("error")
			log_world("TOOLTIP ERROR ([window]): [copytext(href_list["message"], 1, 200)]")

/datum/tooltip/proc/reset()
	hide()
	create_window()

/// Theme is a CSS class in tooltip.html; by default it is chosen from the user's UI style
/proc/openToolTip(mob/user = null, atom/movable/tip_src = null, params = null, title = "", content = "", theme = "")
	if(!istype(user) || !user.client?.tooltips)
		return
	var/ui_style = user.client?.prefs?.read_preference(/datum/preference/choiced/ui_style)
	if(!theme && ui_style)
		theme = LOWER_TEXT(ui_style)
	if(!theme)
		theme = "default"
	user.client.tooltips.show(tip_src, params, title, content, theme)

/proc/closeToolTip(mob/user)
	if(!istype(user) || !user.client?.tooltips)
		return
	user.client.tooltips.hide()

/proc/updateToolTip(mob/user = null, title = "", content = "")
	if(!istype(user) || !user.client?.tooltips)
		return
	user.client.tooltips.update_text(title, content)

GAME_VERB(/client, reset_tooltips, "Reset Tooltips", "OOC")
	tooltips?.reset()
	to_chat(src, span_notice("Tooltips reset."))

#undef TOOLTIP_WINDOW_PREFIX
#undef TOOLTIP_LOAD_TIMEOUT
// [/HORIZON-EDIT]
