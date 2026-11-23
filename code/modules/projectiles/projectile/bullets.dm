/obj/projectile/bullet
	name = "bullet"
	icon_state = "bullet_tracer"
	damage = 60
	damage_type = BRUTE
	armor_flag = BULLET
	hitsound_wall = /datum/sound_effect/ricochet
	sharpness = SHARP_POINTY
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	shrapnel_type = /obj/item/shrapnel/bullet
	embed_type = /datum/embedding/bullet
	wound_bonus = 0
	// [HORIZON-EDIT] GunRework
	wound_falloff_tile = -2 // (was -5)
	embed_falloff_tile = 0 // (was -3)
	ricochets_max = 2
	ricochet_chance = 20
	ricochet_incidence_leeway = 45
	// [HORIZON-ADD] GunRework

/obj/projectile/bullet/smite
	name = "divine retribution"
	damage = 10

/datum/embedding/bullet
	embed_chance = 20
	fall_chance = 2
	jostle_chance = 0
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.5
	pain_mult = 3
	rip_time = 1 SECONDS
	stealthy_embed = TRUE
