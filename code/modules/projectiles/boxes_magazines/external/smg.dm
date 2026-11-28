/obj/item/ammo_box/magazine/wt550m9
	name = "\improper WT-550 magazine (4.6x30mm)"
	desc = "A top-loading 4.6x30mm magazine, specifically for the WT-550 autorifle."
	icon_state = "46x30mmt-20"
	base_icon_state = "46x30mmt"
	ammo_band_icon = "+46x30mmab"
	ammo_band_color = null
	ammo_type = /obj/item/ammo_casing/c46x30mm
	caliber = CALIBER_46X30MM
	max_ammo = 20
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2)

/obj/item/ammo_box/magazine/wt550m9/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "\improper WT-550 magazine (4.6x30mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.6)

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "\improper WT-550 magazine (4.6x30mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.6, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)


/obj/item/ammo_box/magazine/smartgun
	name = "Abielle magazine (.160 Smart)"
	desc = "A deep .160 Smart magazine, suitable for the Abielle smart-SMG."
	icon_state = "smartgun"
	base_icon_state = "smartgun"
	ammo_type = /obj/item/ammo_casing/c160smart
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	caliber = CALIBER_160SMART
	max_ammo = 50

/obj/item/ammo_box/magazine/uzim9mm
	name = "\improper Uzi magazine (9mm)"
	desc = "A long 9mm magazine, suitable for the Uzi SMG."
	icon_state = "uzi9mm-32"
	base_icon_state = "uzi9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_box/magazine/smgm9mm
	name = "\improper SMG magazine (9mm)"
	desc = "A sleek 9mm magazine, suitable for the Nanotrasen Saber SMG."
	icon_state = "smg9mm"
	base_icon_state = "smg9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (9mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG magazine (9mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c9mm/fire

/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	desc = "A long .45 magazine, suitable for the C-20r SMG."
	icon_state = "c20r45"
	base_icon_state = "c20r45"
	ammo_band_icon = "+c20rab"
	ammo_band_color = null
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45
	max_ammo = 24

/obj/item/ammo_box/magazine/smgm45/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 2)]"

/obj/item/ammo_box/magazine/smgm45/ap
	name = "SMG magazine (.45 AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c45/ap

/obj/item/ammo_box/magazine/smgm45/hp
	name = "SMG magazine (.45 HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c45/hp

/obj/item/ammo_box/magazine/smgm45/incen
	name = "SMG magazine (.45 incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c45/inc

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45
	max_ammo = 50

// [HORIZON-ADD] GunRework
/obj/item/ammo_box/magazine/ppsh9mm
	name = "ppsh magazine (9mm)"
	icon = '_horizon/icons/obj/items/ammo/smg.dmi'
	icon_state = "550"
	base_icon_state = "550"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 32
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/ppsh9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? 30 : 0]"

/obj/item/ammo_box/magazine/hksmg22lr
	name = "R5 Submachine Gun mini-drum magazine (.22lr)"
	icon = '_horizon/icons/obj/items/ammo/smg.dmi'
	icon_state = "hksmg"
	base_icon_state = "hksmg"
	ammo_type = /obj/item/ammo_casing/c22lr
	caliber = CALIBER_22LR
	max_ammo = 40
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/hksmg22lr/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

/obj/item/ammo_box/magazine/hksmg380
	name = "R8 Submachine Gun magazine (.380 ACP)"
	icon = '_horizon/icons/obj/items/ammo/smg.dmi'
	icon_state = "vityaz"
	base_icon_state = "vityaz"
	ammo_type = /obj/item/ammo_casing/c380
	caliber = CALIBER_380
	max_ammo = 30
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/hksmg380/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

/obj/item/ammo_box/magazine/bastardo9mm
	name = "R1 Submachine Gun magazine (9mm)"
	icon = '_horizon/icons/obj/items/ammo/smg.dmi'
	icon_state = "vityaz"
	base_icon_state = "vityaz"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 30
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/bastardo9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

/obj/item/ammo_box/magazine/uzi9mm
	name = "R6 Submachine Gun magazine (9mm)"
	icon = '_horizon/icons/obj/items/ammo/smg.dmi'
	icon_state = "uzi"
	base_icon_state = "uzi"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 30
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/uzi9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

/obj/item/ammo_box/magazine/thump45
	name = "R2 Submachine Gun magazine (.45 ACP)"
	icon = '_horizon/icons/obj/items/ammo/smg.dmi'
	icon_state = "ump"
	base_icon_state = "ump"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45
	max_ammo = 25
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/thump45/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"
// [/HORIZON-ADD]
