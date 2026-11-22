// MARK: Pistol
/obj/item/ammo_box/magazine/m9mm
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "ruger9mm"
	base_icon_state = "ruger9mm"

/obj/item/ammo_box/magazine/m9mm_aps
	name = "pernetta 69r magazine (9mm)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "beretta9mm"
	base_icon_state = "beretta9mm"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/m45
	name = "pistol magazine (.45)"
	icon = '_horizon/icons/obj/items/ammo/pistol.dmi'
	icon_state = "pistol45"
	base_icon_state = "pistol45"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	drop_sound = '_horizon/sound/weapons/plastic_drop.ogg'

/obj/item/ammo_box/magazine/m45/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[min(round(ammo_count(), 2), 8)]"

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

// MARK: Rifle
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
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

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
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

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
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

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
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

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
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

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
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"
*/

// MARK: Shotgun
/obj/item/ammo_box/magazine/abyss_shotgun_drum
	name = "\improper Abyss Shotgun magazine"
	desc = "A 20-shell capacity magazine for the AN-12 shotgun."
	icon = '_horizon/icons/obj/items/ammo/shotgun.dmi'
	icon_state = "saiga_drum"
	base_icon_state = "saiga_drum"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = CALIBER_SHOTGUN
	max_ammo = 20
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/abyss_shotgun_drum/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"

// BULLDOG
/obj/item/ammo_box/magazine/m12g
	icon = '_horizon/icons/obj/items/ammo/shotgun.dmi'
	icon_state = "m12"
	base_icon_state = "m12"
// (no update_icon_state override: core's "[base_icon_state]-[ceil(ammo_count(FALSE)/8)*8]"
// already yields m12-8/m12-0 for the 8-round drum)

/obj/item/ammo_box/magazine/m12g/stun
	icon_state = "m12"
	base_icon_state = "m12"

/obj/item/ammo_box/magazine/m12g/slug
	icon_state = "m12"
	base_icon_state = "m12"

/obj/item/ammo_box/magazine/m12g/dragon
	icon_state = "m12"
	base_icon_state = "m12"

/obj/item/ammo_box/magazine/m12g/bioterror
	icon_state = "m12"
	base_icon_state = "m12"

/obj/item/ammo_box/magazine/m12g/meteor
	icon_state = "m12"
	base_icon_state = "m12"

// MARK: SMG
/obj/item/ammo_box/magazine/ppsh9mm
	name = "Mamasha magazine (9mm)"
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
