/// Base attachment item. It carries no gun logic itself: everything happens in its
/// /datum/component/gun_attachment, picked with attachment_component_type.
/// See _horizon/code/datums/components/gun_attachment.dm for how to add an attachment.
/obj/item/attachment
	name = "broken attachment"
	desc = "alert coders"
	icon = '_horizon/icons/obj/guns/attachments.dmi'
	w_class = WEIGHT_CLASS_SMALL

	/// Component type that implements this attachment's behaviour.
	var/attachment_component_type = /datum/component/gun_attachment
	/// The component instance, see get_attachment_component().
	var/datum/component/gun_attachment/attachment_comp

/obj/item/attachment/Initialize(mapload)
	. = ..()
	get_attachment_component()

/obj/item/attachment/Destroy()
	// The component is deleted together with its parent, only drop our reference.
	attachment_comp = null
	return ..()

/// Returns the attachment component, creating it if needed. Safe to call before Initialize()
/// has run, which is why a gun spawning with default attachments can use it right away.
/obj/item/attachment/proc/get_attachment_component()
	if(!attachment_comp)
		attachment_comp = AddComponent(attachment_component_type)
	return attachment_comp

/// A switched on toggle attachment shows its "-on" icon state, which also drives the overlay on the gun.
/obj/item/attachment/update_icon_state()
	var/is_active = attachment_comp?.active
	icon_state = "[initial(icon_state)][is_active ? "-on" : ""]"
	return ..()
