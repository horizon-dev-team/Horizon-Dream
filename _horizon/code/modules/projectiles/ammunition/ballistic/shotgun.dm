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
