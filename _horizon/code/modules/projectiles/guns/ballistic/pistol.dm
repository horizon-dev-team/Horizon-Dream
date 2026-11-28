// Base for all hd_gun pistols: family-wide sounds and stats.
/obj/item/gun/ballistic/automatic/pistol/hd_gun
	fire_delay = 1
	carry_weight = 1 KILOGRAMS
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	suppressed = SUPPRESSED_NONE
	safety_off_sound = '_horizon/sound/weapons/guns/pistol/pistol_safety.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/pistol/pistol_safety.wav'
	pickup_sound = '_horizon/sound/weapons/guns/pistol/pistol_draw.wav'
	equip_sound = '_horizon/sound/weapons/guns/pistol/pistol_holster.wav'
	drop_sound = '_horizon/sound/weapons/guns/drop_lightgun.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/pistol/pistol_lockback.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/pistol/pistol_lockin.wav'
	eject_sound = '_horizon/sound/weapons/guns/pistol/pistol_magout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/pistol/pistol_magout.wav'
	eject_sound_vary = FALSE
	rack_sound_vary = FALSE
	load_sound = '_horizon/sound/weapons/guns/pistol/pistol_magin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/pistol/pistol_magin.wav'
	rack_sound = '_horizon/sound/weapons/guns/pistol/pistol_rack.wav'
	w_class = WEIGHT_CLASS_NORMAL
	suppressor_x_offset = 10
	dry_fire_sound = '_horizon/sound/weapons/guns/empty.wav'
	client_recoil_animation_information = list("strength" = 0.35, "duration" = 2)

// RUGER MKIV
/obj/item/gun/ballistic/automatic/pistol/hd_gun/ruger
	name = "\improper Plinker pistol"
	desc = "A small, easily concealable 9mm handgun. Has a threaded barrel for suppressors."
	icon_state = "ruger"
	base_icon_state = "ruger"
	gunshot_animation_information = list(
		"pixel_x" = 15, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30, \
	)
	custom_price = 3000

/obj/item/gun/ballistic/automatic/pistol/hd_gun/ruger/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 17, 12)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/m1911
	name = "\improper Cold 1911"
	desc = "A classical copy of a antique design, even centuries later is efficient for close-quarter combat and self-defence at the cost of magazine capacity."
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	icon_state = "m1911"
	base_icon_state = "m1911"
	gunshot_animation_information = list(
		"pixel_x" = 16, \
		"pixel_y" = 2, \
		"inactive_when_suppressed" = TRUE,
	)
	recoil_animation_information = list()
	fire_sound = '_horizon/sound/weapons/guns/pistol/colt.wav'
	rack_sound = '_horizon/sound/weapons/guns/pistol/pistol_rack.wav'
	force = 10
	w_class = WEIGHT_CLASS_NORMAL
	carry_weight = 1 KILOGRAMS
	custom_price = 3500

/obj/item/gun/ballistic/automatic/pistol/hd_gun/m1911/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 23, 14)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/cortes
	name = "\improper Cortes .45"
	desc = "A lavish pistol for a lavish life."
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	icon_state = "USP"
	base_icon_state = "USP"
	gunshot_animation_information = list(
		"pixel_x" = 16, \
		"pixel_y" = 2, \
		"inactive_when_suppressed" = TRUE,
	)
	recoil_animation_information = list()
	fire_sound = '_horizon/sound/weapons/guns/pistol/USP.ogg'
	rack_sound = '_horizon/sound/weapons/guns/pistol/john_rack.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/pistol/john_lockback.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/pistol/john_lockin.wav'
	accepted_magazine_type = /obj/item/ammo_box/magazine/u45
	can_suppress = FALSE
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	carry_weight = 1 KILOGRAMS
	custom_price = 3500

/obj/item/gun/ballistic/automatic/pistol/hd_gun/combatmaster
	name = "\improper Frag Master 2511"
	desc = "An expensive, reliable handgun with a large magazine capacity. \
			Very similar to the Cold 1911, but chambered in 9mm and made with modern materials such as a polymer handle and titanium frame."
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	icon_state = "combatmaster"
	base_icon_state = "combatmaster"
	fire_sound = '_horizon/sound/weapons/guns/pistol/combatmaster.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/pistol/combatmaster_silenced.wav'
	gunshot_animation_information = list(
		"pixel_x" = 15, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30,
	)
	force = 10
	suppressor_x_offset = 12
	accepted_magazine_type = /obj/item/ammo_box/magazine/combatmaster9mm
	w_class = WEIGHT_CLASS_NORMAL
	carry_weight = 1 KILOGRAMS
	custom_price = 4500

/obj/item/gun/ballistic/automatic/pistol/hd_gun/combatmaster/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 29, 14)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/glock17
	name = "\improper Gosma-17 9mm pistol"
	desc = "A chunky pistol often accompanied with the screams of thugs."
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	icon_state = "glock"
	base_icon_state = "glock"
	fire_sound = '_horizon/sound/weapons/guns/pistol/glock.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/pistol/glock_suppressed.wav'
	gunshot_animation_information = list(
		"pixel_x" = 15, \
		"pixel_y" = 5, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -20, \
		"recoil_angle_lower" = -35, \
	)
	force = 10
	accepted_magazine_type = /obj/item/ammo_box/magazine/glock9mm
	mag_display = TRUE
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	carry_weight = 1 KILOGRAMS
	custom_price = 2500

/obj/item/gun/ballistic/automatic/pistol/hd_gun/glock17/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 27, 18)

// WALTHER PPK
/obj/item/gun/ballistic/automatic/pistol/hd_gun/ppk
	name = "\improper Bombeiro 22lr pistol"
	desc = "The Walter Bomberio pistol is a reliable, easily concealable 22lr pistol. \
			Doesn't pack too much of a punch, but was famously used by a british secret agent."
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	icon_state = "ppk"
	base_icon_state = "ppk"
	fire_sound = '_horizon/sound/weapons/guns/pistol/walter.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/pistol/walter_silenced.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/pistol/walter_safety.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/pistol/walter_safety.wav'
	gunshot_animation_information = list(
		"pixel_x" = 11, \
		"pixel_y" = 1, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -10, \
		"recoil_angle_lower" = -20, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.35,
		"duration" = 2,
	)
	accepted_magazine_type = /obj/item/ammo_box/magazine/ppk22lr
	mag_display = TRUE
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_SMALL
	carry_weight = 500 GRAMS
	suppressor_x_offset = 8
	custom_price = 900

/obj/item/gun/ballistic/automatic/pistol/hd_gun/ppk/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 22, 12)

// "DEAGLE"
/obj/item/gun/ballistic/automatic/pistol/hd_gun/aniquilador
	name = "\improper Aniquilador .50 LE Anti-Personnel Firearm"
	desc = "A very rare firearm that can be found within experimental military bases, comes loaded with .50 LE, Living Exterminator rounds. \
		Feeling the gun in your hand, he never stops nervously shaking and vibrating until you aim down the sights at a living being."
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/pistol_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/pistol_righthand.dmi'
	inhand_icon_state = "one"
	icon_state = "aniquilador"
	base_icon_state = "aniquilador"
	gunshot_animation_information = list(
		"pixel_x" = 16, \
		"pixel_y" = 2, \
	)
	recoil_animation_information = list()
	fire_sound = '_horizon/sound/weapons/guns/pistol/one.ogg'
	rack_sound = '_horizon/sound/weapons/guns/pistol/one_rack.ogg'
	lock_back_sound = '_horizon/sound/weapons/guns/pistol/one_lockback.ogg'
	bolt_drop_sound = '_horizon/sound/weapons/guns/pistol/one_lockin.ogg'
	force = 10
	fire_delay = 8
	accepted_magazine_type = /obj/item/ammo_box/magazine/aniquilador
	w_class = WEIGHT_CLASS_NORMAL
	can_unsuppress = FALSE
	verb_say = "ravishes"
	carry_weight = 2 KILOGRAMS
	custom_price = 5500

/obj/item/gun/ballistic/automatic/pistol/hd_gun/aniquilador/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 27, 16)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/john
	name = "\improper John .50 AE Pistol"
	desc = "Who's that? Oh It's just John, don't worry. It's a plinking pistol."
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/pistol_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/pistol_righthand.dmi'
	inhand_icon_state = "five7"
	icon_state = "glockl"
	base_icon_state = "glockl"
	gunshot_animation_information = list(
		"pixel_x" = 16, \
		"pixel_y" = 2, \
	)
	recoil_animation_information = list()
	fire_sound = '_horizon/sound/weapons/guns/pistol/john.wav'
	rack_sound = '_horizon/sound/weapons/guns/pistol/john_rack.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/pistol/john_lockback.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/pistol/john_lockin.wav'
	force = 15
	fire_delay = 2
	accepted_magazine_type = /obj/item/ammo_box/magazine/john
	w_class = WEIGHT_CLASS_NORMAL
	can_unsuppress = FALSE
	carry_weight = 2 KILOGRAMS
	custom_price = 5500

/obj/item/gun/ballistic/automatic/pistol/hd_gun/john/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 30, 18)


/obj/item/gun/ballistic/automatic/pistol/hd_gun/pm9
	name = "\improper PM9"
	desc = "An old Soviet pistol. It fires quickly. Uses 9mm ammo."
	icon = '_horizon/icons/obj/items/guns/pistol.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/pistol_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/pistol_righthand.dmi'
	inhand_icon_state = "pm9"
	icon_state = "pm9"
	base_icon_state = "pm9"
	gunshot_animation_information = list(
		"pixel_x" = 16, \
		"pixel_y" = 2, \
	)
	client_recoil_animation_information = list(
		"strength" = 1,
		"duration" = 2,
	)
	fire_sound = '_horizon/sound/weapons/guns/pistol/pm9.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/pistol/pm9_suppressed.wav'
	rack_sound = '_horizon/sound/weapons/guns/pistol/pm9_rack.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/pistol/pm9_lockback.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/pistol/pm9_lockin.wav'
	load_sound = '_horizon/sound/weapons/guns/pistol/pm9_magin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/pistol/pm9_magin.wav'
	eject_sound = '_horizon/sound/weapons/guns/pistol/pm9_magout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/pistol/pm9_magout.wav'
	force = 15
	fire_delay = 2
	accepted_magazine_type = /obj/item/ammo_box/magazine/pm9
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_NORMAL
	suppressor_x_offset = 9
	carry_weight = 2
	custom_price = 5500
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/pistol/hd_gun/pm9/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 27, 16)
