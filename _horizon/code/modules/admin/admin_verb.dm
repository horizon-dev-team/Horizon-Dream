/client
	show_popup_menus = FALSE

ADMIN_VERB(toggle_rightclickmenu, R_NONE, "Toggle Right Click Context Menu", "Allows you to right click.", ADMIN_CATEGORY_MAIN)
	user.toggle_rightclickmenu()

/client/proc/toggle_rightclickmenu()
	if(!holder)
		return

	if(!check_rights_for(src, R_VAREDIT))
		to_chat(src, span_warning("Only admins with var edit perms can use the right clicking menu."))
		return FALSE

	show_popup_menus = !show_popup_menus
	to_chat(src, span_warning("Right click context menu has been toggled [show_popup_menus ? "on" : "off"]."))
