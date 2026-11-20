/obj/item/ammo_box
	carry_weight = 2 KILOGRAMS
	var/bullet_spill = list('_horizon/sound/weapons/guns/bullet_spill1.wav', '_horizon/sound/weapons/guns/bullet_spill2.wav', '_horizon/sound/weapons/guns/bullet_spill3.wav')
	var/bullet_load = list('_horizon/sound/weapons/guns/bullet_load1.wav', '_horizon/sound/weapons/guns/bullet_load2.wav', '_horizon/sound/weapons/guns/bullet_load3.wav')

/obj/item/ammo_box/attack_self(mob/user)
	var/obj/item/ammo_casing/casing = get_round()
	if(!casing)
		return

	casing.forceMove(drop_location())
	//incase they're using TK
	if(!user.is_holding(src) || !user.put_in_hands(casing))
		casing.bounce_away(bounce_angle = null, spread_multiplier = 0.75, still_warm = FALSE, sound_delay = 0)
	playsound(src, pick(bullet_spill), 60, TRUE)
	to_chat(user, span_notice("I remove a round from [src]!"))
	casing.update_appearance()
	update_appearance()

/// stored_ammo can hold type paths (top_off starting) or live casings (in contents).
/// Parent get_carry_weight already walks contents; only path entries need an explicit mass.
/obj/item/ammo_box/get_carry_weight(list/seen)
	. = ..(seen)
	for(var/obj/item/ammo_casing/casing as anything in stored_ammo)
		if(!ispath(casing))
			continue
		var/w = initial(casing.carry_weight)
		if(isnull(w))
			w = weight_class_to_kg(initial(casing.w_class))
		. += w

/obj/item/ammo_box/add_notes_box()
	var/list/readout = list()
	readout += span_notice("<b>Capacity:</b> [max_ammo]")
	var/obj/item/ammo_casing/mag_ammo = get_and_shuffle_round()
	if(istype(mag_ammo))
		readout += "[mag_ammo.add_notes_ammo()]"
	else
		readout += span_notice("<b>Caliber:</b> [caliber]")
	return readout.Join("\n")

/obj/item/ammo_box/a762svd
	name = "ammo box (7.62x54R)"
	icon = '_horizon/icons/obj/items/ammo/boxes.dmi'
	icon_state = "riflebox"
	ammo_type = /obj/item/ammo_casing/a762svd
	max_ammo = 120

/obj/item/ammo_box/a762svd/ap
	name = "armor-piercing ammo box (7.62x54R)"
	icon = '_horizon/icons/obj/items/ammo/boxes.dmi'
	icon_state = "riflebox-AP"
	ammo_type = /obj/item/ammo_casing/a762svd/ap
	max_ammo = 120

/obj/item/ammo_box/a54539abyss
	name = "ammo box (5.45x39)"
	icon = '_horizon/icons/obj/items/ammo/boxes.dmi'
	icon_state = "riflebox"
	ammo_type = /obj/item/ammo_casing/a545
	max_ammo = 120

/obj/item/ammo_box/a54539abyss/ap
	name = "armor-piercing ammo box (5.45x39)"
	icon = '_horizon/icons/obj/items/ammo/boxes.dmi'
	icon_state = "riflebox-AP"
	ammo_type = /obj/item/ammo_casing/a545/ap
	max_ammo = 120

/obj/item/ammo_box/a556winter
	name = "ammo box (5.56x45)"
	icon = '_horizon/icons/obj/items/ammo/boxes.dmi'
	icon_state = "riflebox"
	ammo_type = /obj/item/ammo_casing/a556
	max_ammo = 120

