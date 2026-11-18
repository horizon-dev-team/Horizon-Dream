/obj/item/card/id/advanced/debug
	icon = '_horizon/icons/obj/items/card.dmi'
	icon_state = "card_dev"
	trim = /datum/id_trim/admin/debug

/// Called when this card is equipped, updates SecHUD to use our custom icon file.
/obj/item/card/id/advanced/debug/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_ID && ishuman(user))
		update_custom_sechud(user)

/// Called when this card is dropped, restores original SecHUD.
/obj/item/card/id/advanced/debug/dropped(mob/user)
	. = ..()
	if(ishuman(user))
		restore_sechud(user)

/// Applies our custom SecHUD icon for the horizon_profession trim.
/obj/item/card/id/advanced/debug/proc/update_custom_sechud(mob/living/carbon/human/human)
	if(!human.hud_list || !human.hud_list[ID_HUD])
		return
	var/image/holder = human.hud_list[ID_HUD]
	holder.icon = '_horizon/icons/obj/hud.dmi'
	holder.icon_state = trim?.sechud_icon_state || "hudno_id"

/// Restores the original SecHUD icon file.
/obj/item/card/id/advanced/debug/proc/restore_sechud(mob/living/carbon/human/human)
	if(!human.hud_list || !human.hud_list[ID_HUD])
		return
	var/image/holder = human.hud_list[ID_HUD]
	holder.icon = 'icons/mob/huds/hud.dmi'
	// Re-read the icon state from the trim so it's not stale
	human.update_ID_card()

/obj/item/card/id/advanced/debug/get_trim_sechud_icon()
	return '_horizon/icons/obj/hud.dmi'
