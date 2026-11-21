/obj/projectile
	speed = 2
	icon = '_horizon/icons/obj/items/guns/projectiles/projectiles.dmi'

/obj/projectile/bullet
	wound_falloff_tile = -2
	embed_falloff_tile = 0
	ricochets_max = 2
	ricochet_chance = 20
	ricochet_incidence_leeway = 45

// MARK: Pistol
/obj/projectile/bullet/c22lr
	name = ".22lr bullet"
	damage = 20
	wound_bonus = 5

/obj/projectile/bullet/c45
	damage = 35
	wound_bonus = 0

/obj/projectile/bullet/anaquilador
	icon_state = "lebullet"
	damage = 60
	wound_bonus = 25

/obj/projectile/bullet/c380
	name = ".380 ACP bullet"
	damage = 28
	wound_bonus = 5

// MARK: Revolver
/obj/projectile/bullet/a357
	name = ".357 magnum bullet"
	damage = 48
	wound_bonus = 0
	wound_falloff_tile = -2

/obj/projectile/bullet/c38
	name = ".38 suspicious bullet"
	damage = 28
	wound_bonus = 0
	embed_falloff_tile = 0
	ricochet_chance = 20

/obj/projectile/bullet/c38/pluspee
	name = ".38 suspicious bullet"
	damage = 34
	wound_bonus = 2
	embed_falloff_tile = 0
	ricochet_chance = 20

/obj/projectile/bullet/a500
	name = ".500 magnum bullet"
	damage = 60
	wound_bonus = 0
	wound_falloff_tile = -2

// MARK: Rifle
/obj/projectile/bullet/a762
	damage = 60
	wound_falloff_tile = -2

/obj/projectile/bullet/a556
	damage = 50
	wound_falloff_tile = -1

/obj/projectile/bullet/a545
	damage = 55
	wound_falloff_tile = -1
	wound_bonus = 0

/obj/projectile/bullet/a545/ap
	damage = 51
	armour_penetration = 30

/obj/projectile/bullet/a49234g11
	damage = 41
	wound_bonus = 2

/obj/projectile/bullet/a556steyr
	damage = 40
	wound_bonus = 10

/obj/projectile/bullet/a762svd
	damage = 70
	wound_bonus = 2
	wound_falloff_tile = 0

/obj/projectile/bullet/a762svd/ap
	damage = 68
	armour_penetration = 30

/obj/projectile/bullet/a762x51
	damage = 65
	wound_bonus = 2
	wound_falloff_tile = 0

/obj/projectile/bullet/a276
	damage = 80


// MARK: Shotgun
/obj/projectile/bullet/shotgun_beanbag
	damage = 15
	wound_bonus = 15
	stamina = 20

/obj/projectile/bullet/pellet/shotgun_rubbershot
	name = "rubbershot pellet"
	damage = 4
	wound_bonus = 4
	stamina = 3

/obj/projectile/bullet/shotgun_slug
	name = "12g slug"
	damage = 60

/obj/projectile/bullet/pellet/shotgun_buckshot
	name = "12g pellet"
	damage = 10
	wound_falloff_tile = 0
	sharpness = SHARP_POINTY

/obj/projectile/bullet/pellet/shotgun_flechette
	name = "12g flechette"
	damage = 6
	wound_bonus = -3
	wound_falloff_tile = -1
	sharpness = SHARP_POINTY

/obj/projectile/bullet/shotgun_bolas
	name = "4g slug"
	damage = 80
	wound_bonus = 10
	sharpness = SHARP_POINTY

/obj/projectile/bullet/pellet/shotgun_bolas/buckshot
	name = "4g pellet"
	damage = 20
	wound_bonus = 10
	wound_falloff_tile = 0
	sharpness = SHARP_POINTY


// MARK: Shrapnel
/obj/projectile/bullet/shrapnel
	name = "flying shrapnel shard"
	icon_state = "shrapnel1"
	base_icon_state = "shrapnel"
	damage = 14
	range = 5
	weak_against_armour = TRUE
	dismemberment = 0
	ricochets_max = 0
	ricochet_chance = 0
	shrapnel_type = /obj/item/shrapnel
	ricochet_incidence_leeway = 60
	hit_prone_targets = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = 30
	var/state_variation = 5

/obj/projectile/bullet/shrapnel/Initialize(mapload)
	. = ..()
	if(state_variation)
		icon_state = "[base_icon_state][rand(1, state_variation)]"

// MARK: Launcher
/obj/projectile/bullet/l40mm
	name = "40mm fragmentation grenade"
	desc = "MEU DEUS"
	icon = '_horizon/icons/obj/items/guns/projectiles/projectiles.dmi'
	icon_state = "bolter"
	damage = 60
	embed_type = null
	shrapnel_type = null
	range = 7

/obj/projectile/bullet/l40mm/on_range()
	explosion(get_turf(src), devastation_range = -1, heavy_impact_range = 2, light_impact_range = 4, flame_range = 2, flash_range = 3, adminlog = FALSE, explosion_cause = src)
	return ..()

/obj/projectile/bullet/l40mm/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	explosion(target, devastation_range = -1, heavy_impact_range = 2, light_impact_range = 4, flame_range = 2, flash_range = 3, adminlog = FALSE, explosion_cause = src)
	return BULLET_ACT_HIT

// MARK: Energy
/obj/projectile/beam/laser/nasr
	name = "laser"
	icon = '_horizon/icons/obj/items/guns/projectiles/projectiles.dmi'
	icon_state = "laser"
	damage = 70
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	tracer_type = null
	impact_type = null

/obj/projectile/beam/laser/siren
	name = "plasma ball"
	icon = '_horizon/icons/obj/items/guns/projectiles/projectiles.dmi'
	icon_state = "plasma"
	damage = 30
	light_color = LIGHT_COLOR_LIGHT_CYAN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	tracer_type = null
	impact_type = null
