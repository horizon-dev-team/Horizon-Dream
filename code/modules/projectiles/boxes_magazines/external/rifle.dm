/obj/item/ammo_box/magazine/m223
	name = "toploader magazine (.223)"
	desc = "A top-loading .223 magazine, suitable for the M-90gl carbine."
	icon_state = ".223"
	ammo_band_icon = "+.223ab"
	ammo_type = /obj/item/ammo_casing/a223
	caliber = CALIBER_A223
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/m223/phasic
	name = "toploader magazine (.223 Phasic)"
	desc = parent_type::desc + "<br>Carries phasic rounds, which completely ignore armor and phase through cover, but not targets."
	ammo_type = /obj/item/ammo_casing/a223/phasic

// .38 (Battle Rifle) //

/obj/item/ammo_box/magazine/m38
	name = "battle rifle magazine (.38)"
	desc = "A .38 magazine for a BR-38 battle rifle."
	icon_state = "38mag"
	base_icon_state = "38mag"
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = /obj/item/ammo_casing/c38
	caliber = CALIBER_357_38
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	max_ammo = 15
	ammo_band_icon = "+38mag_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/magazine/m38/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][ammo_count() ? "-ammo" : ""]"

/obj/item/ammo_box/magazine/m38/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/m38/trac
	name = "battle rifle magazine (.38 TRAC)"
	desc = parent_type::desc + " TRAC bullets embed a tracking implant within the target's body and are entirely nonlethal."
	ammo_type = /obj/item/ammo_casing/c38/trac
	ammo_band_color = COLOR_AMMO_TRACK
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 0.75, /datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT)

/obj/item/ammo_box/magazine/m38/match
	name = "battle rifle magazine (.38 Match)"
	desc = parent_type::desc + " These rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match
	ammo_band_color = COLOR_AMMO_MATCH

/obj/item/ammo_box/magazine/m38/match/bouncy
	name = "battle rifle magazine (.38 Rubber)"
	desc = parent_type::desc + " These rounds are incredibly bouncy and MOSTLY nonlethal, making them great to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy
	ammo_band_color = COLOR_AMMO_RUBBER
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)

/obj/item/ammo_box/magazine/m38/true
	name = "battle rifle magazine (.38 True Strike)"
	desc = parent_type::desc + " Bullets bounce towards new targets with surprising accuracy and can strike through armored target"
	ammo_type = /obj/item/ammo_casing/c38/match/true
	ammo_band_color = COLOR_AMMO_TRUESTRIKE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2, /datum/material/bluespace = SHEET_MATERIAL_AMOUNT * 0.75)

/obj/item/ammo_box/magazine/m38/dumdum
	name = "battle rifle magazine (.38 DumDum)"
	desc = parent_type::desc + " These rounds expand on impact, allowing them to shred the target and cause massive bleeding. Very weak against armor and distant targets."
	ammo_type = /obj/item/ammo_casing/c38/dumdum
	ammo_band_color = COLOR_AMMO_DUMDUM

/obj/item/ammo_box/magazine/m38/hotshot
	name = "battle rifle magazine (.38 Hot Shot)"
	desc = parent_type::desc + " Hot Shot bullets contain an incendiary payload."
	ammo_type = /obj/item/ammo_casing/c38/hotshot
	ammo_band_color = COLOR_AMMO_HOTSHOT
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 0.75)

/obj/item/ammo_box/magazine/m38/iceblox
	name = "battle rifle magazine (.38 Iceblox)"
	desc = parent_type::desc + " Iceblox bullets contain a cryogenic payload."
	ammo_type = /obj/item/ammo_casing/c38/iceblox
	ammo_band_color = COLOR_AMMO_ICEBLOX
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 0.75)

/obj/item/ammo_box/magazine/m38/flare
	name = "battle rifle magazine (.38 Flare)"
	desc = parent_type::desc + " Flare casings launch a concentrated particle beam towards a target, lighting them up for everyone to see."
	ammo_type = /obj/item/ammo_casing/c38/flare
	ammo_band_color = COLOR_AMMO_HELLFIRE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2, /datum/material/uranium = SHEET_MATERIAL_AMOUNT * 0.75, /datum/material/gold = SHEET_MATERIAL_AMOUNT * 0.75)

// [HORIZON-ADD] GunRework
/obj/item/ammo_box/magazine/a556winter
	name = "Inverno Genocídio universal magazine (5.56)"
	icon = '_horizon/icons/obj/items/ammo/rifle.dmi'
	icon_state = "inverno"
	base_icon_state = "inverno"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = CALIBER_A556
	max_ammo = 35
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'
	pickup_sound = '_horizon/sound/weapons/plastic_pickup.ogg'

/obj/item/ammo_box/magazine/a556winter/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count()]"

/obj/item/ammo_box/magazine/a556g36
	name = "Perdedor magazine (5.56)"
	icon = '_horizon/icons/obj/items/ammo/rifle.dmi'
	icon_state = "g36"
	base_icon_state = "g36"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = CALIBER_A556
	max_ammo = 30
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'
	pickup_sound = '_horizon/sound/weapons/plastic_pickup.ogg'

/obj/item/ammo_box/magazine/a556g36/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[CEILING(ammo_count(), 5)]"

/obj/item/ammo_box/magazine/a545
	name = "Abyss-Platform universal magazine (5.45x39)"
	icon = '_horizon/icons/obj/items/ammo/rifle.dmi'
	icon_state = "abrifle"
	base_icon_state = "abrifle"
	ammo_type = /obj/item/ammo_casing/a545
	caliber = CALIBER_545
	max_ammo = 30
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'
	pickup_sound = '_horizon/sound/weapons/plastic_pickup.ogg'

/obj/item/ammo_box/magazine/a545/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count()]"

/obj/item/ammo_box/magazine/a545/donator
	name = "Abyss-Platform paypig magazine (5.45x39)"
	icon_state = "gabrifle"
	base_icon_state = "gabrifle"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = CALIBER_A762

/obj/item/ammo_box/magazine/a545/donator/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? 30 : 0]"

/obj/item/ammo_box/magazine/a49234g11
	name = "Unwieldly O Guloseim magazine (4.92x34mm)"
	icon = '_horizon/icons/obj/items/ammo/rifle.dmi'
	icon_state = "grifle"
	base_icon_state = "grifle"
	ammo_type = /obj/item/ammo_casing/a49234g11
	caliber = CALIBER_UNCONVENTIONAL
	max_ammo = 55
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/a49234g11/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count()]"

/obj/item/ammo_box/magazine/a556steyr
	name = "Advanced Combat Rifle annular-primed flechette magazine (5.56×45mm)"
	icon = '_horizon/icons/obj/items/ammo/rifle.dmi'
	icon_state = "urifle"
	base_icon_state = "urifle"
	ammo_type = /obj/item/ammo_casing/a556steyr
	caliber = CALIBER_FLECHETTE
	max_ammo = 24
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'
	pickup_sound = '_horizon/sound/weapons/plastic_pickup.ogg'

/obj/item/ammo_box/magazine/a556steyr/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count()]"

/obj/item/ammo_box/magazine/a762svd
	name = "Lampiao marksman rifle magazine (7.62x54R)"
	icon = '_horizon/icons/obj/items/ammo/rifle.dmi'
	icon_state = "svd"
	base_icon_state = "svd"
	ammo_type = /obj/item/ammo_casing/a762svd
	caliber = CALIBER_54R
	max_ammo = 15
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/a762svd/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count()]"

/* [DISABLED] no gun uses the 7.62x51 / Arma marksman rifle set yet; re-enable together with the gun.
/obj/item/ammo_box/magazine/a762g3
	name = "Arma marksman rifle magazine (7.62x51)"
	icon = '_horizon/icons/obj/items/ammo/rifle.dmi'
	icon_state = "g3"
	base_icon_state = "g3"
	ammo_type = /obj/item/ammo_casing/a762x51
	caliber = CALIBER_51
	max_ammo = 20
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/a762g3/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count()]"
*/
// [/HORIZON-ADD]
