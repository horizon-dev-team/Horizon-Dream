/obj/item/attachment/ammo_counter
	name = "ammunition counter"
	desc = "A computerized ammunition tracker for use on conventional firearms. Includes a small toggle for telling the user when ammo is depleted. Capable of mounting on both a railing or a scope, depending on the user's preference."
	icon = '_horizon/icons/obj/items/guns/attachments.dmi'
	icon_state = "ammo_counter"
	w_class = WEIGHT_CLASS_TINY

	attachment_component_type = /datum/component/gun_attachment/ammo_counter

/datum/component/gun_attachment/ammo_counter
	slot = ATTACHMENT_SLOT_SCOPE
	slot_choices = list(ATTACHMENT_SLOT_SCOPE, ATTACHMENT_SLOT_RAIL)
	feature_flags = ATTACH_REMOVABLE_HAND|ATTACH_TOGGLE|ATTACH_NO_SPRITE

/datum/component/gun_attachment/ammo_counter/get_attach_error(obj/item/gun/gun, mob/user)
	. = ..()
	if(.)
		return
	if(!istype(gun, /obj/item/gun/ballistic))
		return "[gun] has no magazine for [parent] to track!"
	if(gun.GetComponent(/datum/component/ammo_hud))
		return "[gun] already has an ammo counter installed!"

/datum/component/gun_attachment/ammo_counter/on_attached(obj/item/gun/gun, mob/user)
	. = ..()
	var/datum/component/ammo_hud/new_counter = gun.AddComponent(/datum/component/ammo_hud)
	new_counter?.wake_up(source = gun, user = user, slot = ITEM_SLOT_HANDS)

/datum/component/gun_attachment/ammo_counter/on_detached(obj/item/gun/gun, mob/user)
	. = ..()
	var/datum/component/ammo_hud/old_counter = gun.GetComponent(/datum/component/ammo_hud)
	if(old_counter)
		old_counter.turn_off()
		qdel(old_counter)

/datum/component/gun_attachment/ammo_counter/get_toggle_error(obj/item/gun/gun, mob/user)
	var/obj/item/gun/ballistic/ballistic_gun = gun
	if(!istype(ballistic_gun))
		return "[gun] has no magazine for [parent] to track!"
	if(initial(ballistic_gun.empty_alarm))
		return "[gun] already has a built-in empty magazine alarm."
	return ..()

/datum/component/gun_attachment/ammo_counter/on_toggled(obj/item/gun/gun, mob/user, silent)
	. = ..()
	var/obj/item/gun/ballistic/ballistic_gun = gun
	if(!istype(ballistic_gun))
		return
	ballistic_gun.empty_alarm = active ? TRUE : initial(ballistic_gun.empty_alarm)
	if(!silent && user)
		to_chat(user, span_notice("You turn [parent]'s alarm [active ? "on" : "off"]."))

