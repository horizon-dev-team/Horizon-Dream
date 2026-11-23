/obj/item/attachment
	name = "broken attachment"
	desc = "alert coders"
	icon = '_horizon/icons/obj/guns/attachments.dmi'
	w_class = WEIGHT_CLASS_SMALL

	var/attachment_component_type = /datum/component/gun_attachment
	var/datum/component/gun_attachment/attachment_comp

/obj/item/attachment/Initialize(mapload)
	. = ..()
	get_attachment_component()

/obj/item/attachment/Destroy()
	attachment_comp = null
	return ..()

/obj/item/attachment/proc/get_attachment_component()
	if(!attachment_comp)
		attachment_comp = AddComponent(attachment_component_type)
	return attachment_comp

/obj/item/attachment/update_icon_state()
	var/is_active = attachment_comp?.active
	icon_state = "[initial(icon_state)][is_active ? "-on" : ""]"
	return ..()
