// grenade launcher
/obj/item/gun/ballistic/revolver/grenadelauncher/hd_gun
	pin = /obj/item/firing_pin
	pickup_sound = '_horizon/sound/weapons/guns/generic_draw.wav' // [HORIZON-ADD] GunRework family default
	dry_fire_sound = '_horizon/sound/weapons/guns/empty.wav' // [HORIZON-ADD] GunRework family default
	carry_weight = 2.5 KILOGRAMS // [HORIZON-ADD] GunRework family default

/obj/item/gun/ballistic/shotgun/grenadelauncher/hd_gun/batata
	name = "40mm Batata Frita explosive fragmentation launcher"
	desc = "A pump-operated grenade launcher that filled the need for yet another firearm instead of an important invention or update."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_righthand.dmi'
	inhand_icon_state = "chlake"
	icon_state = "chinalake"
	base_icon_state = "chinalake"
	fire_sound = '_horizon/sound/weapons/guns/launcher/batata.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/launcher/batata_lock_back.ogg'
	bolt_drop_sound = '_horizon/sound/weapons/guns/launcher/batata_lockin.wav'
	rack_sound = '_horizon/sound/weapons/guns/launcher/batata_rack.ogg'
	load_sound = '_horizon/sound/weapons/guns/launcher/batata_load1.wav'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/grenadelauncher/batata
	pin = /obj/item/firing_pin
	slot_flags = null
	can_suppress = FALSE
	fire_delay = 3 SECONDS
	w_class = WEIGHT_CLASS_HUGE
	bolt_type = BOLT_TYPE_LOCKING
	empty_icon_state = FALSE
