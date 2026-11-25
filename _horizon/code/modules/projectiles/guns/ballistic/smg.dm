/obj/item/gun/ballistic/automatic/hd_gun/remis/smg
	worn_icon = '_horizon/icons/obj/items/guns/worn/back.dmi'
	equip_sound = '_horizon/sound/weapons/guns/weap_away.ogg'
	drop_sound = '_horizon/sound/weapons/guns/drop_lightgun.wav'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	suppressed = SUPPRESSED_NONE
	full_auto = TRUE
	w_class = WEIGHT_CLASS_BULKY

// ppsh
/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/ppsh
	name = "\improper PPS"
	desc = "A Papaschi machine pistol, simple to produce. Takes 32-round magazines. \
		Chambered in 9mm."
	icon = '_horizon/icons/obj/items/guns/smg.dmi'
	base_icon_state = "ppsh"
	icon_state = "ppsh"
	accepted_magazine_type = /obj/item/ammo_box/magazine/ppsh9mm
	weapon_weight = WEAPON_MEDIUM
	force = 10
	fire_delay = 2
	burst_size = 3
	custom_price = 4000

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/ppsh/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 31, 16)

// hksmg
/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/solitario
	name = "\improper Solitario Inseguro R5 submachine gun"
	desc = "A reliable submachine gun with a high-magazine capacity maufactured by popular civilian arms dealer S&I"
	icon = '_horizon/icons/obj/items/guns/smg.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/smg_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/smg_righthand.dmi'
	inhand_icon_state = "hksmg"
	base_icon_state = "hksmg"
	icon_state = "hksmg"
	rack_sound = '_horizon/sound/weapons/guns/smg/hksmg_rack.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/smg/hksmg_lockback.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/smg/hksmg_lockin.wav'
	load_sound = '_horizon/sound/weapons/guns/smg/hksmg_magin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/smg/hksmg_magin.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/smg/hksmg_magout.wav'
	eject_sound = '_horizon/sound/weapons/guns/smg/hksmg_magout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	fire_sound = '_horizon/sound/weapons/guns/smg/hksmg.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/smg/hksmg_silenced.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/hksmg22lr
	weapon_weight = WEAPON_LIGHT
	bolt_type = BOLT_TYPE_LOCKING
	slot_flags = ITEM_SLOT_BELT
	force = 10
	recoil = 0.2
	fire_delay = 2
	burst_size = 2
	can_suppress = TRUE
	suppressor_x_offset = 9
	gunshot_animation_information = list(
		"pixel_x" = 15, \
		"pixel_y" = 2, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -10, \
		"recoil_angle_lower" = -20, \
		"recoil_burst_speed" = 0.5, \
		"return_burst_speed" = 0.5, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.1,
		"duration" = 1,
	)
	custom_price = 10000

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/solitario/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 30, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/bastardo
	name = "\improper Feio Bastardo R1 submachine gun"
	desc = "A fully-automatic submachine gun issued to ZoomTech officers and military force with an accelerated fire delay, comes with a folding stock, and a threaded barrel for suppression."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/smg_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/smg_righthand.dmi'
	worn_icon_state = "vityaz"
	inhand_icon_state = "vityaz"
	base_icon_state = "vityaz"
	icon_state = "vityaz"
	load_sound = '_horizon/sound/weapons/guns/smg/hksmg_magin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/smg/hksmg_magin.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/smg/hksmg_magout.wav'
	eject_sound = '_horizon/sound/weapons/guns/smg/hksmg_magout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/aksafety1.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/akrack.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/smg/vityaz_silenced.ogg'
	fire_sound = '_horizon/sound/weapons/guns/smg/vityaz.ogg'
	burst_select_sound = '_horizon/sound/weapons/guns/rifle/aksafety1.wav'
	accepted_magazine_type = /obj/item/ammo_box/magazine/bastardo9mm
	weapon_weight = WEAPON_MEDIUM
	force = 10
	recoil = 0.2
	fire_delay = 2
	burst_size = 2
	can_suppress = TRUE
	suppressor_x_offset = 6
	gunshot_animation_information = list(
		"pixel_x" = 15, \
		"pixel_y" = 2, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -10, \
		"recoil_angle_lower" = -20, \
		"recoil_burst_speed" = 0.5, \
		"return_burst_speed" = 0.5, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.15, \
		"duration" = 1, \
	)
	custom_price = 20000

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/bastardo/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 42, 18)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/thump
	name = "\improper Cesno Thump R2 submachine gun"
	desc = "A fully-automatic submachine gun that fires in optional three-round bursts, comes with a threaded barrel, and was engineered as a direct upgrade to the Solitario to .45 ACP."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/smg_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/smg_righthand.dmi'
	worn_icon_state = "ump"
	inhand_icon_state = "ump"
	base_icon_state = "ump"
	icon_state = "ump"
	lock_back_sound = '_horizon/sound/weapons/guns/smg/thump_lockback.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/smg/thump_lockin.wav'
	rack_sound = '_horizon/sound/weapons/guns/smg/thump_rack.wav'
	load_sound = '_horizon/sound/weapons/guns/smg/thump_magin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/smg/thump_magin.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/smg/thump_magout.wav'
	eject_sound = '_horizon/sound/weapons/guns/smg/thump_magout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	fire_sound = '_horizon/sound/weapons/guns/smg/thump.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/smg/thump_silenced.wav'
	accepted_magazine_type = /obj/item/ammo_box/magazine/thump45
	weapon_weight = WEAPON_MEDIUM
	bolt_type = BOLT_TYPE_LOCKING
	force = 10
	recoil = 0.2
	fire_delay = 1.7
	burst_size = 3
	can_suppress = TRUE
	suppressor_x_offset = 6
	client_recoil_animation_information = list(
		"strength" = 0.25, \
		"duration" = 1, \
	)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/thump/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 43, 16)

/// Adds a seclite (flashlight) attachment point to this SMG.
/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/thump/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 30, \
		overlay_y = 14)

// SUPPRESSED HK SMG
/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/solitario/suppressed
	name = "Solitario-SD Inseguro R7 \"Saber\" submachine gun"
	desc = "An integrally suppressed version of the Solitario, changed post-factory to be chambered in .380, however. This has made the drum mags incompatible."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	fire_sound = '_horizon/sound/weapons/guns/smg/hksmg380_silenced.ogg'
	suppressed_sound = '_horizon/sound/weapons/guns/smg/hksmg380_silenced.ogg'
	weapon_weight = WEAPON_MEDIUM
	worn_icon_state = "hksmgs"
	inhand_icon_state = "hksmgs"
	base_icon_state = "hksmgs"
	icon_state = "hksmgs"
	fire_delay = 1.4
	burst_size = 3
	accepted_magazine_type = /obj/item/ammo_box/magazine/hksmg380
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	empty_icon_state = FALSE
	can_suppress = TRUE
	can_unsuppress = FALSE
	w_class = WEIGHT_CLASS_SMALL
	client_recoil_animation_information = list(
		"strength" = 0.15, \
		"duration" = 1, \
	)
	default_attachments = list(/obj/item/attachment/silencer/integrated)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/solitario/suppressed/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 46, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/solitario/suppressed/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/bolsa
	name = "\improper Bolsa R6 submachine gun"
	desc = "An antique, compact submachine gun that is prohibited to civillians in many stations. Discontinued, but it still has It's strengths, that being the extendable stock and the size."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/smg_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/smg_righthand.dmi'
	worn_icon_state = "uzi"
	inhand_icon_state = "uzi"
	base_icon_state = "uzi"
	icon_state = "uzi"
	load_sound = '_horizon/sound/weapons/guns/smg/bolsa_magin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/smg/bolsa_magin.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/smg/bolsa_magout.wav'
	eject_sound = '_horizon/sound/weapons/guns/smg/bolsa_magout.wav'
	rack_sound = '_horizon/sound/weapons/guns/smg/bolsa_rack.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/smg/bolsa_silenced.wav'
	fire_sound = '_horizon/sound/weapons/guns/smg/bolsa.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/smg/bolsa_lockback.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/smg/bolsa_lockin.wav'
	burst_select_sound = '_horizon/sound/weapons/guns/smg/bolsa_safety.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/smg/bolsa_safety.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/smg/bolsa_safety.wav'
	accepted_magazine_type = /obj/item/ammo_box/magazine/uzi9mm
	foldable = TRUE
	folded = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	bolt_type = BOLT_TYPE_OPEN
	slot_flags = ITEM_SLOT_BELT
	carry_weight = 2.2 KILOGRAMS
	force = 10
	recoil = 0.2
	fire_delay = 2
	burst_size = 2
	can_suppress = TRUE
	suppressor_x_offset = 2
	gunshot_animation_information = list(
		"pixel_x" = 21, \
		"pixel_y" = 5, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -10, \
		"recoil_angle_lower" = -20, \
		"recoil_burst_speed" = 0.5, \
		"return_burst_speed" = 0.5, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.2,
		"duration" = 1,
	)
	custom_price = 20000

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/bolsa/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 41, 18)
