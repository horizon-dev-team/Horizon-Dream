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
