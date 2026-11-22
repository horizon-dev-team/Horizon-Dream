/obj/item/gun/energy/examine(mob/user)
	. = ..()
	if(cell)
		. += "<b>Charge:</b> [icon2html(GUN_INFO_ICON_SET, user, "battery")] [CEILING(cell.percent(), 1)]%"
	else
		. += span_warning("It has no power cell installed.")
