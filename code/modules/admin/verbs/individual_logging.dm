/proc/show_individual_logging_panel(mob/M, source = LOGSRC_CKEY, type = INDIVIDUAL_ATTACK_LOG)
	if(!M || !ismob(M))
		return

	var/datum/log_viewer/LV = new(M)
	if(source)
		LV.source_type = source
	if(type)
		LV.viewing_type = text2num(type)
	LV.ui_interact(usr)

