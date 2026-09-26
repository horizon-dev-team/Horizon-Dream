// MARK: Тактический Кислородный Баллон

/obj/item/tank/internals/tactical
	name = "tactical oxygen tank"
	desc = "A military-grade oxygen tank for space operations. The construction is rather bulky and can only be mounted on hardsuits and heavy outerwear. It features a system of magnetic mounts and stabilizing straps to secure most standard weapon types. A universal weapon case for non-standard models is also included."
	icon = '_horizon/icons/obj/tank_tactical.dmi'
	icon_state = "tank"
	worn_icon = '_horizon/icons/obj/in_mob/tank_tactical_back.dmi'
	worn_icon_state = "empty"
	icon_status_overlay = '_horizon/icons/obj/tank_tactical.dmi'
	tank_holder_icon_state = null
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 15
	dog_fashion = null
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_SUITSTORE
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'

/obj/item/tank/internals/tactical/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/tactical)
	update_appearance()

/obj/item/tank/internals/tactical/populate_gas()
	air_contents.set_gas(/datum/gas/oxygen, (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/datum/storage/pockets/tactical
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_BULKY
	rustle_sound = FALSE
	attack_hand_interact = TRUE

/datum/storage/pockets/tactical/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/gun/ballistic,
		/obj/item/gun/energy,
		/obj/item/kinetic_crusher,
		/obj/item/gun/grenadelauncher
	))


/obj/item/tank/internals/tactical/attack_hand(mob/user)
	if(loc != user || user.get_item_by_slot(ITEM_SLOT_SUITSTORE) != src || !user.can_perform_action(src))
		return ..()

	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] draws [I] from [src]."), span_notice("You draw [I] from [src]."))
		user.put_in_hands(I)
		update_appearance()
		user.update_suit_storage()
	else
		to_chat(user, span_warning("The straps are unfastened, [capitalize(src.name)] is empty."))
	return ..()

/obj/item/tank/internals/tactical/update_icon_state()
	icon_state = initial(icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(!length(contents))
		return ..()
	var/obj/item/I = contents[1]
	worn_icon_state = "full"
	playsound(I, 'sound/items/equip/toolbelt_equip.ogg', 25, TRUE)
	return ..()

/obj/item/tank/internals/tactical/update_overlays()
	. = ..()
	if(!length(contents))
		. += mutable_appearance(icon, "straps-open", layer)
		return
	var/obj/item/I = contents[1]
	var/mutable_appearance/gun_overlay = mutable_appearance(I.icon, I.icon_state)
	var/matrix/M = matrix()
	M.Turn(-90)
	M.Translate(2, 0)
	gun_overlay.transform = M
	. += gun_overlay
	. += mutable_appearance(icon, "straps-closed", layer)

// MARK: Tactical Tanks
/obj/item/tank/internals/tactical/wt550/Initialize(mapload)
	. = ..()
	new /obj/item/gun/ballistic/automatic/wt550(src)
	update_appearance()

/obj/item/tank/internals/tactical/pulse/Initialize(mapload)
	. = ..()
	new /obj/item/gun/energy/pulse(src)
	update_appearance()

/obj/item/tank/internals/tactical/e_gun/Initialize(mapload) //ERT Commander, ERT Medic, ERT Engineer,
	. = ..()
	new /obj/item/gun/energy/e_gun(src)
	update_appearance()

/obj/item/tank/internals/tactical/e_gun_taser/Initialize(mapload) //ERT Security, Охранник Инвизиторов
	. = ..()
	new /obj/item/gun/energy/e_gun/stun(src)
	update_appearance()
