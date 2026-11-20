/obj/item/ammo_casing
	carry_weight = 20 GRAMS
	var/world_icon = '_horizon/icons/obj/items/ammo/casings_world.dmi'
	var/world_icon_state = "s-casing"

/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	if(world_icon)
		AddElement(/datum/element/world_icon, PROC_REF(update_icon_world))

/obj/item/ammo_casing/update_icon(updates)
	icon = initial(icon)
	return ..()

/obj/item/ammo_casing/proc/update_icon_world()
	icon = world_icon
	icon_state = "[world_icon_state][loaded_projectile ? "-live" : ""]"
	return UPDATE_ICON_STATE | UPDATE_OVERLAYS

// MARK: Pistol
/obj/item/ammo_casing/c22lr
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = ".22lr bullet casing"
	desc = "A 22 long rifle bullet casing."
	icon_state = "c22lr"
	base_icon_state = "c22lr"
	caliber = CALIBER_22LR
	projectile_type = /obj/projectile/bullet/c22lr
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/c22lr

/obj/item/ammo_casing/c9mm
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	icon_state = "c9mm"
	base_icon_state = "c9mm"
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/c9mm

/obj/item/ammo_casing/c45
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	icon_state = "c45"
	base_icon_state = "c45"
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/c45

/obj/item/ammo_casing/aniquilador
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = ".50 LE bullet casing"
	desc = "A .50 LE bullet casing."
	icon_state = "c45"
	base_icon_state = "c45"
	caliber = CALIBER_ANIQUILADOR
	projectile_type = /obj/projectile/bullet/anaquilador
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/aniquilador

/obj/item/ammo_casing/c380
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = ".380 ACP bullet casing"
	desc = "A .380 ACP bullet casing."
	icon_state = "c22lr"
	base_icon_state = "c22lr"
	caliber = CALIBER_380
	projectile_type = /obj/projectile/bullet/c380
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/c380

// MARK: Revolver
/obj/item/ammo_casing/c38
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = ".38 suspicious bullet casing"
	desc = "A .38 suspicious bullet casing."
	icon_state = "c38"
	base_icon_state = "c38"
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/c38

/obj/item/ammo_casing/c38/pluspee
	name = ".38 suspicious +P bullet casing"
	desc = "A .38 suspicious bullet casing."
	icon_state = "c38"
	base_icon_state = "c38"
	projectile_type = /obj/projectile/bullet/c38/pluspee
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/c38/pluspee

/obj/item/ammo_casing/a357
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = ".357 magnum bullet casing"
	desc = "A .357 magnum bullet casing."
	icon_state = "c357"
	base_icon_state = "c357"
	caliber = CALIBER_357
	projectile_type = /obj/projectile/bullet/a357
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a357

/obj/item/ammo_casing/a500
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = ".500 magnum bullet casing"
	desc = "A .500 magnum bullet casing."
	icon_state = "c357"
	base_icon_state = "c357"
	caliber = CALIBER_500
	projectile_type = /obj/projectile/bullet/a500
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a500

// MARK: Rifle
/obj/item/ammo_casing/a762
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = "7.62 bullet casing"
	desc = "A 7.62 bullet casing."
	icon_state = "c762"
	base_icon_state = "c762"
	world_icon_state = "762-casing"
	caliber = CALIBER_A762
	projectile_type = /obj/projectile/bullet/a762
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a762

/obj/item/ammo_casing/a556
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = "5.56mm bullet casing"
	desc = "A 5.56mm bullet casing."
	icon_state = "c545"
	base_icon_state = "c545"
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a556
	world_icon_state = "545-casing"
	caliber = CALIBER_A556
	projectile_type = /obj/projectile/bullet/a556

/obj/item/ammo_casing/a545
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = "5.45x39 bullet casing"
	desc = "A 5.45x39 bullet casing."
	icon_state = "c545"
	base_icon_state = "c545"
	world_icon_state = "545-casing"
	caliber = CALIBER_545
	projectile_type = /obj/projectile/bullet/a545
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a545

/obj/item/ammo_casing/a545/ap
	name = "5.45x39 black-tip bullet casing"
	desc = "A 5.45x39 cartridge with a green and black tip."
	world_icon_state = "545b-casing"
	projectile_type = /obj/projectile/bullet/a545/ap

/obj/item/ammo_casing/a49234g11
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = "4.92x34 bullet"
	desc = "Somewhat rare caseless ammunition, If It's spent, the universe will explode."
	icon_state = "c545"
	base_icon_state = "c545"
	world_icon_state = "545-casing"
	caliber = CALIBER_UNCONVENTIONAL
	projectile_type = /obj/projectile/bullet/a49234g11
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a49234g11

/obj/item/ammo_casing/a556steyr
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = "5.56x45mm SCF"
	desc = "A dart-shaped flechette."
	icon_state = "flechette"
	base_icon_state = "flechette"
	world_icon_state = "545-casing"
	caliber = CALIBER_FLECHETTE
	projectile_type = /obj/projectile/bullet/a556steyr
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a556steyr

/obj/item/ammo_casing/a762svd
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = "7.62x54R bullet casing"
	desc = "A 7.62x54R bullet casing."
	icon_state = "c762"
	base_icon_state = "c762"
	world_icon_state = "762-casing"
	caliber = CALIBER_54R
	projectile_type = /obj/projectile/bullet/a762svd
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a762svd

/obj/item/ammo_casing/a762svd/ap
	name = "7.62x54R black-tip bullet casing"
	desc = "A 7.62x54R black-tip bullet casing."
	world_icon_state = "762b-casing"
	caliber = CALIBER_54R
	projectile_type = /obj/projectile/bullet/a762svd/ap

/obj/item/ammo_casing/a762x51
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = "7.62x51 bullet casing"
	desc = "A 7.62x51 bullet casing."
	icon_state = "c762"
	base_icon_state = "c762"
	world_icon_state = "762-casing"
	caliber = CALIBER_51
	projectile_type = /obj/projectile/bullet/a762x51
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a762x51

/obj/item/ammo_casing/a276
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	name = ".276 Federson bullet casing"
	desc = "A .276 Federson bullet casing."
	icon_state = "c762"
	base_icon_state = "c762"
	world_icon_state = "762-casing"
	caliber = CALIBER_276
	projectile_type = /obj/projectile/bullet/a276
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/a276

// MARK: Shotgun
/obj/item/ammo_casing/shotgun
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	icon_state = "12gauge_slug"
	base_icon_state = "12gauge_slug"
	world_icon_state = "gshells"
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/shotgun

/obj/item/ammo_casing/shotgun/Initialize(mapload)
	if((type == /obj/item/ammo_casing/shotgun) && prob(0.1))
		name = "reggie slug"
		desc = "Hi, my name is Reggie, I like penetrating IIIA body armor."
	return ..()

/obj/item/ammo_casing/shotgun/rubbershot
	icon_state = "12gauge"
	base_icon_state = "12gauge"
	world_icon_state = "gshell"
	pellets = 12
	variance = 4

/obj/item/ammo_casing/shotgun/buckshot
	icon_state = "12gauge"
	base_icon_state = "12gauge"
	world_icon_state = "gshell"
	pellets = 8
	variance = 4.5

/obj/item/ammo_casing/shotgun/beanbag
	icon_state = "12gauge"
	base_icon_state = "12gauge"
	world_icon_state = "gshell"

/obj/item/ammo_casing/shotgun/flechette
	name = "shotgun flechette"
	desc = "A 12 gauge steel flechette. Contains 20 individual projectiles"
	pellets = 20
	variance = 18.5
	projectile_type = /obj/projectile/bullet/pellet/shotgun_flechette

/obj/item/ammo_casing/shotgun/bolas
	name =	"Consumidor de Buceta 4 guage slug"
	desc = "A 4 gauge destructive slug designed with the purpose of destroying armored structures at a range. \
			But It can destroy flesh, too."
	icon_state = "8gauge"
	base_icon_state = "8gauge"
	world_icon_state = "8gshell"
	caliber = CALIBER_KS23
	projectile_type = /obj/projectile/bullet/shotgun_bolas
	stack_type = /obj/item/ammo_box/magazine/ammo_stack/shotgun/bolas

/obj/item/ammo_casing/shotgun/bolas/buckshot
	name = "Estuprador-3 4 gauge buckshot"
	desc = "A 4 gauge anti-personnel buckshot shell for the sole purpose of completely fucking obliterating soft tissue from close range."
	icon_state = "8gauge"
	base_icon_state = "8gauge"
	world_icon_state = "8gshell"
	caliber = CALIBER_KS23
	pellets = 10
	variance = 10
	projectile_type = /obj/projectile/bullet/pellet/shotgun_bolas/buckshot

// MARK: Launcher
/obj/item/ammo_casing/l40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = CALIBER_40MM
	icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	world_icon = '_horizon/icons/obj/items/ammo/casings.dmi'
	world_icon_state = "40mmHE"
	icon_state = "40mmHE"
	base_icon_state = "40mmHE"
	projectile_type = /obj/projectile/bullet/l40mm

// MARK: Energy
/obj/item/ammo_casing/energy/siren
	fire_sound = '_horizon/sound/weapons/guns/energy/siren.wav'
	select_name = "well done steak"
	e_cost = 85
	projectile_type = /obj/projectile/beam/laser/siren

/obj/item/ammo_casing/energy/nasr
	fire_sound = list('_horizon/sound/weapons/guns/energy/nasr1.wav', '_horizon/sound/weapons/guns/energy/nasr2.wav', '_horizon/sound/weapons/guns/energy/nasr3.wav')
	select_name = "glue melter"
	e_cost = 100
	projectile_type = /obj/projectile/beam/laser/nasr
