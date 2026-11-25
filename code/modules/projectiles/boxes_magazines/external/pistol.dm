
// Makarov (9mm) //

/obj/item/ammo_box/magazine/m9mm
	name = "pistol magazine (9mm)"
	icon_state = "9x19p"
	base_icon_state = "9x19p"
	desc = "A 9mm handgun magazine, suitable for the Makarov pistol."
	ammo_band_icon = "+9x19ab"
	ammo_band_color = null
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 12
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE

/obj/item/ammo_box/magazine/m9mm/fire
	name = "pistol magazine (9mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c9mm/fire

/obj/item/ammo_box/magazine/m9mm/hp
	name = "pistol magazine (9mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/magazine/m9mm/ap
	name = "pistol magazine (9mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9mm/ap

// Stechkin APS (9mm) //
// [HORIZON-EDIT] GunRework
/obj/item/ammo_box/magazine/m9mm_aps
	name = "stechkin pistol magazine (9mm)"
	desc = "A 9mm handgun magazine, suitable for the Stechkin APS machine pistol."
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "beretta9mm" // ("9mmaps-15")
	base_icon_state = "beretta9mm" // ("9mmaps")
	ammo_band_icon = "+9mmapsab"
	ammo_band_color = null
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 15
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'
	multiple_sprites = AMMO_BOX_FULL_EMPTY
// [/HORIZON-EDIT]

/obj/item/ammo_box/magazine/m9mm_aps/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 5)]"

/obj/item/ammo_box/magazine/m9mm_aps/fire
	name = "stechkin pistol magazine (9mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c9mm/fire

/obj/item/ammo_box/magazine/m9mm_aps/hp
	name = "stechkin pistol magazine (9mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/magazine/m9mm_aps/ap
	name = "stechkin pistol magazine (9mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c9mm/ap

// Ansem (10mm) //

/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "A 10mm handgun magazine, suitable for the Ansem pistol."
	icon_state = "9x19p"
	base_icon_state = "9x19p"
	ammo_band_icon = "+9x19ab"
	ammo_band_color = null

	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 8
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c10mm/ap

// M1911 (.45) //

/obj/item/ammo_box/magazine/m45
	// [HORIZON-EDIT] GunRework
	name = "pistol magazine (.45)"
	desc = "A .45 handgun magazine, suitable for the M1911."
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "pistol45"
	base_icon_state = "pistol45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45
	max_ammo = 8
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	multiple_sprite_use_base = TRUE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/m45/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[min(round(ammo_count(), 2), 8)]"
// [HORIZON-ADD] GunRework

// Desert Eagle (.50 AE) //

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50 AE)"
	desc = "A .50 AE handgun magazine, suitable for the Desert Eagle."
	icon_state = "50ae"
	ammo_type = /obj/item/ammo_casing/a50ae
	caliber = CALIBER_50AE
	max_ammo = 7
	multiple_sprites = AMMO_BOX_PER_BULLET

// Regal Condor (.45) //

/obj/item/ammo_box/magazine/r45
	name = "regal condor magazine (.45 Reaper)"
	desc = "A very expensive .45 handgun magazine, suitable for the Regal Condor. Loaded with \"reaper\" rounds, which are dangerously effective against everything."
	icon_state = "r45-8"
	base_icon_state = "r45"
	ammo_type = /obj/item/ammo_casing/c45/reaper
	caliber = CALIBER_45
	max_ammo = 8
	multiple_sprites = AMMO_BOX_PER_BULLET
	multiple_sprite_use_base = TRUE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 10,
	)

// [HORIZON-ADD] GunRework
/obj/item/ammo_box/magazine/u45
	name = "pistol magazine (.45)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "usp"
	base_icon_state = "usp"
	max_ammo = 8
	ammo_type = /obj/item/ammo_casing/c45
	caliber = CALIBER_45
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/u45/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[min(round(ammo_count(), 2), 8)]"

/obj/item/ammo_box/magazine/combatmaster9mm
	name = "frag master magazine (9mm)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "combat"
	base_icon_state = "combat"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 20
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/combatmaster9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

/obj/item/ammo_box/magazine/glock9mm
	name = "Gosma-17 magazine (9mm)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "glock"
	base_icon_state = "glock"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 17
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/glock9mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

/obj/item/ammo_box/magazine/ppk22lr
	name = "walter bombeiro magazine (.22lr)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "ppk22lr"
	base_icon_state = "ppk22lr"
	ammo_type = /obj/item/ammo_casing/c22lr
	caliber = CALIBER_22LR
	max_ammo = 9
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/ppk22lr/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[min(round(ammo_count()), 9)]"

/obj/item/ammo_box/magazine/aniquilador
	name = "Anaquilador Magazine (.50 LE)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "one"
	base_icon_state = "one"
	ammo_type = /obj/item/ammo_casing/aniquilador
	caliber = CALIBER_ANIQUILADOR
	max_ammo = 10
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/aniquilador/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

/obj/item/ammo_box/magazine/john
	name = "John Magazine (.50 AE)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "glockl"
	base_icon_state = "glockl"
	ammo_type = /obj/item/ammo_casing/a50ae
	caliber = CALIBER_50
	max_ammo = 8
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/john/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

/obj/item/ammo_box/magazine/pm9
	name = "PM9 Evil Magazine (nine milie meter)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "cunny"
	base_icon_state = "cunny"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = CALIBER_9MM
	max_ammo = 25
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/pm9/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"
// [/HORIZON-ADD]
