// horizon-dev-sync[bot] port
// Variables/procs on /obj/projectile and /obj/item/ammo_casing that are
// referenced by horizon mechanics but not present in upstream /tg/station.

/obj/item/ammo_casing
	/// If FALSE, the casing will not bounce / play bounce sounds when ejected.
	/// Set FALSE for energy casings, foam darts, etc. that shouldn't clang.
	var/heavy_metal = TRUE

/obj/projectile
	/// If TRUE, the projectile deals no damage. Used by /obj/projectile/blood.
	var/nodamage = FALSE
