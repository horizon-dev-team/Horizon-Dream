// MARK: Пеналы
/obj/item/storage/belt/medipenal
	name = "medipen case"
	desc = "A compact and very convenient case that holds up to 5 medipens. A special clip lets it be attached to a pocket or a belt, and thanks to its small size it fits inside a box or a medkit."
	icon = '_horizon/icons/obj/medipenal.dmi'
	icon_state = "penal"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_SMALL
	max_integrity = 300
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'

/obj/item/storage/belt/medipenal/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 5
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 10
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/reagent_containers/syringe
		))

/obj/item/storage/belt/medipenal/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(length(contents))
		icon_state = "penal[length(contents)]"

/obj/item/storage/belt/medipenal/attack_hand(mob/user, list/modifiers)
	if(loc == user)
		if((user.get_item_by_slot(ITEM_SLOT_BELT) == src) || (user.get_item_by_slot(ITEM_SLOT_LPOCKET) == src) || (user.get_item_by_slot(ITEM_SLOT_RPOCKET) == src))
			if(!user.can_perform_action(src))
				return
			atom_storage?.show_contents(user)
	else ..()
	return

/obj/item/storage/medkit/field_surgery
	name = "field surgery kit"
	desc = "A compact set of the most essential medical instruments for emergency surgical intervention in the field."
	icon_state = "medkit_tactical"
	inhand_icon_state = "medkit-tactical"
	damagetype_healed = HEAL_ALL_DAMAGE
	storage_type = /datum/storage/medkit/surgery/holding

/obj/item/storage/medkit/field_surgery/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/scalpel/advanced = 1,
		/obj/item/retractor/advanced = 1,
		/obj/item/cautery/advanced = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/bonesetter = 1,
		/obj/item/blood_filter = 1,
		/obj/item/breathing_bag=1,
		/obj/item/defibrillator/compact/loaded = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1,
		/obj/item/healthanalyzer/super = 1)
	generate_items_inside(items_inside,src)

// MARK: Дыхательная груша
/obj/item/breathing_bag
	name = "breathing bag"
	desc = "Also known as an Ambu bag - a manual, mechanical device used to perform artificial ventilation of the lungs."
	icon = '_horizon/icons/obj/med_items.dmi'
	icon_state = "breathing_bag"
	lefthand_file = 'icons/mob/inhands/clothing/masks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/masks_righthand.dmi'
	inhand_icon_state = "m_mask"
	custom_materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 1

/obj/item/breathing_bag/attack(mob/living/M, mob/user)
	if(M == user)
		return
	if (M.is_mouth_covered())
		to_chat(user, span_warning("Remove the patient's mask to perform artificial ventilation!"))
		return
	to_chat(user, span_notice("You press the breathing mask against [M.name]'s face."))
	if(!do_after(user, 30, user))
		to_chat(user, span_warning("It's not working!"))
		return
	. = ..()
	playsound(user,'_horizon/sound/breathing_bag.ogg', 100, TRUE)
	for(var/ivl in 1 to 15)
		if(!do_after(user, 10, user))
			return
		to_chat(user, span_notice("You perform artificial ventilation of the lungs!"))
		M.adjust_oxy_loss(-15)

// MARK: Мед-Сканер
/obj/item/healthanalyzer/range
	name = "long-range health analyzer"
	desc = "A handheld body scanner capable of accurately detecting the patient's vital signs from a distance."
	icon = '_horizon/icons/obj/tools.dmi'
	lefthand_file = '_horizon/icons/obj/in_hands/tools_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/in_hands/tools_righthand.dmi'
	icon_state = "ranged_analyzer"
	reach = 3
	custom_premium_price = 1000
