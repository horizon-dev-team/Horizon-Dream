// Remove this dumb knockback shit pls
/obj/item/gun/ballistic/shotgun/hd_gun
	icon = '_horizon/icons/obj/items/guns/40x32.dmi'
	icon_state = "ithaca"
	base_icon_state = "ithaca"
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_righthand.dmi'
	inhand_icon_state = "ithaca"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	wielded_inhand_state = TRUE
	rack_sound_vary = FALSE
	sawn_inhand_state = TRUE
	empty_indicator = FALSE
	empty_icon_state = FALSE
	suppressed = SUPPRESSED_NONE
	worn_icon = '_horizon/icons/obj/items/guns/worn/back.dmi'
	equip_sound = '_horizon/sound/weapons/guns/weap_away.ogg'
	worn_icon_state = "shotgun"
	fire_sound = '_horizon/sound/weapons/guns/shotgun/shotgun.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/countryforold.wav'
	pickup_sound = '_horizon/sound/weapons/guns/shotgun/shotgun_draw.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/shotgun_lock_back.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/shotgun/shotgun_lockin.wav'
	rack_sound = '_horizon/sound/weapons/guns/shotgun/shotgun_cycle.wav'
	drop_sound = '_horizon/sound/weapons/guns/drop_heavygun.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/safety3.aac'
	safety_off_sound = '_horizon/sound/weapons/guns/safety3.aac'
	load_sound = '_horizon/sound/weapons/guns/shotgun/shell1.wav'
	load_sound_volume = 80
	safety_off_sound = '_horizon/sound/weapons/guns/shotgun/shotgun_safety2.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/shotgun/shotgun_safety1.wav'
	gunshot_animation_information = list(
		"pixel_x" = 24, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
		"add_pixel_x_sawn" = -5, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)
	force = 12
	pb_knockback = 0
	can_suppress = TRUE
	suppressor_x_offset = 13
	bolt_type = BOLT_TYPE_LOCKING
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	spread_unwielded = 12

/obj/item/gun/ballistic/shotgun/hd_gun/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 38, 16)

// DOUBLE BARRELED SHOTGUN
/obj/item/gun/ballistic/shotgun/doublebarrel/hd_gun
	pb_knockback = 0
	empty_icon_state = FALSE
	bolt_type = BOLT_TYPE_BREAK_ACTION
	can_suppress = FALSE
	safety_flags = NONE
	semi_auto = TRUE
	cylinder_shows_open = TRUE
	cylinder_shows_ammo_count = TRUE
	cylinder_wording = "barrel"
	wielded_inhand_state = FALSE
	worn_icon = '_horizon/icons/obj/items/guns/worn/back.dmi'
	worn_icon_state = "shotgun"
	equip_sound = '_horizon/sound/weapons/guns/weap_away.ogg'
	drop_sound = '_horizon/sound/weapons/guns/drop_heavygun.wav'
	pickup_sound = '_horizon/sound/weapons/guns/shotgun/shotgun_draw.wav'
	fire_sound = '_horizon/sound/weapons/guns/shotgun/shotgun.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/countryforold.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/db_in.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/shotgun/db_out.wav'
	load_sound = '_horizon/sound/weapons/guns/shotgun/db_load.wav'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	gunshot_animation_information = list(
		"pixel_x" = 24, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)

// The legendary
/obj/item/gun/ballistic/shotgun/doublebarrel/hd_gun/bobox
	name = "\"Executioner of Fate\""
	desc = "A \"signature\" double-barreled shotgun. Not in the brow - straight in the eye."
	icon = '_horizon/icons/obj/items/guns/shotgun.dmi'
	inhand_icon_state = "bobox"
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	base_icon_state = "bobox"
	icon_state = "bobox"
	worn_icon_state = "bobox"
	wielded_inhand_state = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT
	cylinder_wording = "barrel"
	rack_sound = '_horizon/sound/weapons/guns/revolver/hammer.ogg'
	drop_sound = '_horizon/sound/weapons/guns/drop_lightgun.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/db_in.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/shotgun/db_out.wav'
	fire_sound = '_horizon/sound/weapons/guns/shotgun/comgun.wav'
	load_sound = '_horizon/sound/weapons/guns/shotgun/db_load.wav'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/bobox
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/bobox
	slot_flags = ITEM_SLOT_BELT

// ITHACA SHOTGUN
/obj/item/gun/ballistic/shotgun/hd_gun/ithaca
	name = "\improper modelo 37 \"Liquidador\""
	icon = '_horizon/icons/obj/items/guns/40x32.dmi'
	icon_state = "ithaca"
	base_icon_state = "ithaca"
	empty_indicator = FALSE
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/lethal

/obj/item/gun/ballistic/shotgun/hd_gun/ithaca/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 38, 16)

/obj/item/gun/ballistic/shotgun/hd_gun/hunting
	name = "OD Papaschi \"Hunter\""
	desc = "A Papaschi hunting shotgun. Chambered in 12 gauge."
	icon_state = "huntingshot"
	base_icon_state = "huntingshot"
	empty_icon_state = TRUE

/obj/item/gun/ballistic/shotgun/hd_gun/hunting/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 39, 16)

// ??? SHOTGUN
/obj/item/gun/ballistic/shotgun/hd_gun/riot
	name = "\improper Riot-S12 \"Downer\""
	desc = "A Riot Solution shotgun with a fixed tactical stock. It was developed as a non-lethal riot suppression solution. \
		Nevertheless, lethal ammunition can be used just as easily. \
		Chambered in 12 gauge."
	icon = '_horizon/icons/obj/items/guns/40x32.dmi'
	icon_state = "riot"
	base_icon_state = "riot"
	inhand_icon_state = "riot"
	empty_indicator = FALSE
	can_be_sawn_off = FALSE
	gunshot_animation_information = list(
		"pixel_x" = 25, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
		"add_pixel_x_sawn" = -4, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)
	suppressor_x_offset = 14

/obj/item/gun/ballistic/shotgun/hd_gun/riot/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 39, 16)

/obj/item/gun/ballistic/shotgun/automatic/hd_gun
	bolt_type = BOLT_TYPE_LOCKING
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/semigun_lock_back.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/shotgun/semigun_lockin.wav'

// BENELLI M4 SHOTGUN
/obj/item/gun/ballistic/shotgun/automatic/hd_gun/combat
	name = "\improper Shottex CQB shotgun"
	desc = "A semi-automatic shotgun that comes already kitted out. Holds 6(+1) rounds. Chambered in 12 gauge."
	icon = '_horizon/icons/obj/items/guns/40x32.dmi'
	icon_state = "combat"
	base_icon_state = "combat"
	inhand_icon_state = "combat"
	rack_sound = '_horizon/sound/weapons/guns/shotgun/semigun_cycle.wav'
	fire_sound = '_horizon/sound/weapons/guns/shotgun/semigun.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/semigun_silenced.wav'
	empty_indicator = FALSE
	gunshot_animation_information = list(
		"pixel_x" = 23, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
		"add_pixel_x_sawn" = -4, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)
	suppressor_x_offset = 13

/// Adds a seclite (flashlight) attachment point to this shotgun.
/obj/item/gun/ballistic/shotgun/automatic/hd_gun/combat/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 24, \
		overlay_y = 10)

// BROWNING 2000 SHOTGUN
/obj/item/gun/ballistic/shotgun/automatic/hd_gun/b2000
	name = "\improper Shottex \"Classical\""
	desc = "A classic pump-action shotgun by Shottex, their slogan: \"No shotgun in the house - and life goes south!\". \
		Holds 4(+1) rounds. Chambered in 12 gauge."
	icon = '_horizon/icons/obj/items/guns/40x32.dmi'
	icon_state = "b2000"
	base_icon_state = "b2000"
	bolt_wording = "slide"
	empty_indicator = FALSE
	rack_sound = '_horizon/sound/weapons/guns/shotgun/semigun_cycle.wav'
	fire_sound = '_horizon/sound/weapons/guns/shotgun/semigun.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/semigun_silenced.wav'
	gunshot_animation_information = list(
		"pixel_x" = 25, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
		"add_pixel_x_sawn" = -5, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// BELADOR 2021 SILENCED SHOTGUN
/obj/item/gun/ballistic/shotgun/automatic/hd_gun/b2021
	name = "\improper Shottex \"Pigeon\""
	desc = "The Shottex \"Pigeon\" shotgun combines customization, crude engineering and killer accuracy. \
		Has a built-in suppressor. \
		Holds 9(+1) rounds. Chambered in 12 gauge."
	icon = '_horizon/icons/obj/items/guns/40x32.dmi'
	icon_state = "b2021"
	inhand_icon_state = "b2021"
	base_icon_state = "b2021"
	bolt_wording = "slide"
	semi_auto = FALSE
	empty_indicator = FALSE
	can_unsuppress = FALSE
	rack_sound = '_horizon/sound/weapons/guns/shotgun/semigun_cycle.wav'
	fire_sound = '_horizon/sound/weapons/guns/shotgun/rape_gun.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/belador_silenced.wav'
	gunshot_animation_information = list(
		"pixel_x" = 25, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
		"add_pixel_x_sawn" = -5, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/b2021
	can_suppress = TRUE
	default_attachments = list(/obj/item/attachment/silencer/integrated)

// AA12 i guess AUTOMATIC SHOTGUN
/obj/item/gun/ballistic/shotgun/hd_gun/bulldog
	name = "\improper Modelo 1337 \"Torturador\""
	desc = "A magazine-fed semi-automatic shotgun. Manufactured by the Spaniards over at Modelo. \
		Only 8(+1 in the chamber) round drum magazines fit its loading port! \
		Chambered in 12 gauge. "
	icon = '_horizon/icons/obj/items/guns/40x32.dmi'
	icon_state = "automatic"
	base_icon_state = "automatic"
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_righthand.dmi'
	inhand_icon_state = "auto"
	bolt_wording = "bolt"
	special_mags = FALSE
	mag_display_ammo = FALSE
	empty_indicator = FALSE
	empty_alarm = FALSE
	casing_ejector = TRUE
	bolt_type = BOLT_TYPE_STANDARD
	empty_icon_state = TRUE
	rack_sound = '_horizon/sound/weapons/guns/shotgun/autogun_cycle.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/autogun_lock_back.wav'
	fire_sound = '_horizon/sound/weapons/guns/shotgun/rape_gun.wav'
	load_sound = '_horizon/sound/weapons/guns/shotgun/autogun_magin.ogg'
	load_empty_sound = '_horizon/sound/weapons/guns/shotgun/autogun_magin.ogg'
	eject_empty_sound = '_horizon/sound/weapons/guns/shotgun/autogun_magout.ogg'
	eject_sound = '_horizon/sound/weapons/guns/shotgun/autogun_magout.ogg'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/belador_silenced.wav'
	load_sound_volume = 40
	gunshot_animation_information = list(
		"pixel_x" = 25, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
		"add_pixel_x_sawn" = -5, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)
	pin = /obj/item/firing_pin
	can_suppress = TRUE
	suppressor_x_offset = 12

/obj/item/gun/ballistic/shotgun/hd_gun/bulldog/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 37, 16)

// SAIGA-12 AUTOMATIC SHOTGUN
/obj/item/gun/ballistic/shotgun/hd_gun/abyss
	name = "\improper AD-12 Papaschi"
	desc = "A magazine-fed Papaschi automatic shotgun. Holds 20 rounds. \
		Chambered in 12 gauge."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/shotgun_righthand.dmi'
	inhand_icon_state = "saiga"
	icon_state = "saiga"
	worn_icon_state = "saiga"
	base_icon_state = "saiga"
	bolt_wording = "bolt"
	mag_display = TRUE
	empty_icon_state = TRUE
	bolt_type = BOLT_TYPE_STANDARD
	special_mags = FALSE
	mag_display_ammo = TRUE
	semi_auto = TRUE
	internal_magazine = FALSE
	rack_sound_vary = FALSE
	casing_ejector = TRUE
	rack_sound = '_horizon/sound/weapons/guns/shotgun/autogun_cycle.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/autogun_lock_back.wav'
	fire_sound = '_horizon/sound/weapons/guns/shotgun/rape_gun.wav'
	load_sound = '_horizon/sound/weapons/guns/shotgun/autogun_magin.ogg'
	load_empty_sound = '_horizon/sound/weapons/guns/shotgun/autogun_magin.ogg'
	eject_empty_sound = '_horizon/sound/weapons/guns/shotgun/autogun_magout.ogg'
	eject_sound = '_horizon/sound/weapons/guns/shotgun/autogun_magout.ogg'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/belador_silenced.wav'
	load_sound_volume = 40
	gunshot_animation_information = list(
		"pixel_x" = 31, \
		"pixel_y" = 0, \
		"inactive_when_suppressed" = TRUE, \
		"add_pixel_x_sawn" = -5, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)
	pin = /obj/item/firing_pin
	accepted_magazine_type = /obj/item/ammo_box/magazine/abyss_shotgun_drum
	suppressor_x_offset = 8

/obj/item/gun/ballistic/shotgun/hd_gun/abyss/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 45, 16)

// KS23 | TOZ-123 DESTROYER
/obj/item/gun/ballistic/shotgun/hd_gun/bolas
	name = "\improper DS-4 Papaschi"
	desc = "A cumbersome shotgun that holds 4 enormous shells. \
		Chambered in 4 gauge."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	icon_state = "bolas"
	base_icon_state = "bolas"
	inhand_icon_state = "bolas"
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/bolas
	fire_sound = '_horizon/sound/weapons/guns/shotgun/bolas.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/bolas_silenced.wav'
	load_sound = '_horizon/sound/weapons/guns/shotgun/bolas_load1.wav'
	client_recoil_animation_information = list(
		"strength" = 1.5,
		"duration" = 3.5,
	)
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/bolas_lock_back.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/shotgun/bolas_lockin.wav'
	rack_sound = '_horizon/sound/weapons/guns/shotgun/bolas_pump.wav'
	slot_flags = null
	can_suppress = TRUE
	suppressor_x_offset = 11

/obj/item/gun/ballistic/shotgun/hd_gun/bolas/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 45, 16)

// SPAS 12
/obj/item/gun/ballistic/shotgun/hd_gun/denominator
	name = "\improper Riot-S12 \"Special\""
	desc = "An automatic shotgun with pump-action cocking. Can switch between semi-automatic and fully automatic fire modes. \
	Press MMB while the pump is closed and the safety is off."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	icon_state = "spas"
	base_icon_state = "spas"
	inhand_icon_state = "spas"
	worn_icon_state = "spas"
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/spas_lock_back.ogg'
	bolt_drop_sound = '_horizon/sound/weapons/guns/shotgun/spas_lockin.ogg'
	rack_sound = '_horizon/sound/weapons/guns/shotgun/spas_cycle.ogg'
	fire_sound = '_horizon/sound/weapons/guns/shotgun/spas.ogg'
	var/semi = FALSE
	var/spas_semi_click = '_horizon/sound/weapons/guns/shotgun/spas_click.ogg'
	foldable = TRUE
	fold_open_sound = '_horizon/sound/weapons/guns/rifle/ak_stock_open.wav'
	fold_close_sound = '_horizon/sound/weapons/guns/rifle/ak_stock_close.wav'
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/spas


/obj/item/gun/ballistic/shotgun/hd_gun/denominator/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 41, 16)
