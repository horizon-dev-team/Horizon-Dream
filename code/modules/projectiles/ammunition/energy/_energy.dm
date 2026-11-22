/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew."
	caliber = ENERGY
	projectile_type = /obj/projectile/energy
	slot_flags = null
	custom_materials = null
	var/e_cost = LASER_SHOTS(10, STANDARD_CELL_CHARGE) //The amount of energy a cell needs to expend to create this shot.
	var/select_name = CALIBER_ENERGY
	fire_sound = 'sound/items/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/red
	newtonian_force = 0.5
	muzzle_flash_color = LIGHT_COLOR_CYAN

// ======== [HORIZON-ADD] GunRework: hd_gun energy casings ========
/obj/item/ammo_casing/energy/siren
	fire_sound = '_horizon/sound/weapons/guns/energy/siren.wav'
	select_name = "well done steak"
	e_cost = 85
	projectile_type = /obj/projectile/beam/laser/siren

/obj/item/ammo_casing/energy/nasr
	fire_sound = '_horizon/sound/weapons/guns/energy/nasr.wav'
	select_name = "glue melter"
	e_cost = 100
	projectile_type = /obj/projectile/beam/laser/nasr
// ======== [/HORIZON-ADD] ========
