/obj/item/gun/ballistic/automatic/hd_gun
	pickup_sound = '_horizon/sound/weapons/guns/generic_draw.wav'
	dry_fire_sound = '_horizon/sound/weapons/guns/empty.wav'
	carry_weight = 2.5 KILOGRAMS
	client_recoil_animation_information = list("strength" = 0.35, "duration" = 2)

/obj/item/gun/ballistic/automatic/hd_gun/remis
	worn_icon = '_horizon/icons/obj/items/guns/worn/back.dmi'
	equip_sound = '_horizon/sound/weapons/guns/weap_away.ogg'
	drop_sound = '_horizon/sound/weapons/guns/drop_mediumgun.wav'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	rack_sound_vary = FALSE
	suppressed = SUPPRESSED_NONE
	load_sound_vary = FALSE
	eject_sound_vary = FALSE
	mag_display = TRUE
	mag_display_ammo = FALSE
	empty_indicator = FALSE
	empty_icon_state = TRUE
	wielded_inhand_state = TRUE
	weapon_weight = WEAPON_HEAVY
	spread_unwielded = 12
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	worn_icon = '_horizon/icons/obj/items/guns//worn/back.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_righthand.dmi'
	equip_sound = '_horizon/sound/weapons/guns/rifle_holster.ogg'

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare/m545
	name = "\improper Peacekeeper 545"
	desc = "Named nicknamed for the type of PMC armies that are generally found carrying them."
	worn_icon_state = "inverno"
	inhand_icon_state = "m4"
	icon_state = "m4"
	base_icon_state = "m4"
	fire_sound = '_horizon/sound/weapons/guns/rifle/g3.wav'
	load_sound = '_horizon/sound/weapons/guns/rifle/mmagin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/rifle/mmagin.wav'
	eject_sound = '_horizon/sound/weapons/guns/rifle/mmagout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/rifle/mmagout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/mrack.wav'
	fireselector_auto = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	fireselector_burst = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	fireselector_semi = '_horizon/sound/weapons/guns/rifle/aksafety1.wav'

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare/m545/ak
	name = "\improper Eclipse 545"
	desc = "Often found on... less than scrupulous PMC groups."
	inhand_icon_state = "ak"
	icon_state = "ak"
	base_icon_state = "ak"
	fire_sound = '_horizon/sound/weapons/guns/rifle/ak.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/rifle/ak_silenced.wav'
	load_sound = '_horizon/sound/weapons/guns/rifle/akmagin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/rifle/akmagin.wav'
	eject_sound = '_horizon/sound/weapons/guns/rifle/akmagout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/rifle/akmagout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/aksafety1.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/akrack.wav'
	fireselector_auto = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	fireselector_burst = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	fireselector_semi = '_horizon/sound/weapons/guns/rifle/aksafety1.wav'

/obj/item/gun/ballistic/automatic/hd_gun/remis/winter
	name = "\improper Inverno Genocídio NK-49 Assault Rifle"
	desc = "Inverno Genocídio, 'Winter Genocide' Assault Rifle firing in 5.56. Used by Ordin- Ordinat... ORDINATORS KILL THIS BASTARD!"
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_righthand.dmi'
	worn_icon_state = "inverno"
	inhand_icon_state = "inverno"
	icon_state = "inverno"
	base_icon_state = "inverno"
	accepted_magazine_type = /obj/item/ammo_box/magazine/a556winter
	fire_delay = 1.85
	burst_size = 3
	empty_icon_state = FALSE
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = '_horizon/sound/weapons/guns/rifle/niggakiller.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/rifle/niggakiller_silenced.wav'
	load_sound = '_horizon/sound/weapons/guns/rifle/mmagin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/rifle/mmagin.wav'
	eject_sound = '_horizon/sound/weapons/guns/rifle/mmagout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/rifle/mmagout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/mrack.wav'
	lock_back_sound = '_horizon/sound/weapons/guns/rifle/mlockback.ogg'
	bolt_drop_sound = '_horizon/sound/weapons/guns/rifle/mlockin.ogg'
	force = 14
	custom_price = 45000
	carry_weight = 3 KILOGRAMS
	can_unsuppress = FALSE
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -25, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.2,
		"duration" = 1,
	)

/obj/item/gun/ballistic/automatic/hd_gun/remis/winter
	suppressed = SUPPRESSED_QUIET
	can_muzzle_flash = FALSE

//Darkworld Gun
/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss
	name = "\improper Abyss Armaments Due Diligence"
	desc = "The double D as it's sometimes caused. Produced before the great war, but very resiliant. \
		The muzzle brake seems to be compatable with noise suppressors! So good."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_righthand.dmi'
	worn_icon_state = "nikonov"
	inhand_icon_state = "nikonov"
	icon_state = "nikonov"
	base_icon_state = "nikonov"
	accepted_magazine_type = /obj/item/ammo_box/magazine/a545
	fire_sound = '_horizon/sound/weapons/guns/rifle/ak.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/rifle/ak_silenced.wav'
	load_sound = '_horizon/sound/weapons/guns/rifle/akmagin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/rifle/akmagin.wav'
	eject_sound = '_horizon/sound/weapons/guns/rifle/akmagout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/rifle/akmagout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/aksafety1.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/akrack.wav'
	fireselector_auto = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	fireselector_burst = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	fireselector_semi = '_horizon/sound/weapons/guns/rifle/aksafety1.wav'
	fold_open_sound = '_horizon/sound/weapons/guns/rifle/ak_stock_open.wav'
	fold_close_sound = '_horizon/sound/weapons/guns/rifle/ak_stock_close.wav'
	force = 16
	fire_delay = 2
	burst_size = 2
	can_suppress = TRUE
	suppressor_x_offset = 10
	gunshot_animation_information = list(
		"pixel_x" = 32, \
		"pixel_y" = 3, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -10, \
		"recoil_angle_lower" = -20, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.2,
		"duration" = 1,
	)
	custom_price = 30000
	w_class = WEIGHT_CLASS_BULKY
	full_auto = TRUE
	foldable = TRUE
	folded = FALSE

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare/m545/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 43, 15)

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare/m545/ak/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 44, 18)

/obj/item/gun/ballistic/automatic/hd_gun/remis/winter/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 43, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 47, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/steyr/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 43, 14)

/obj/item/gun/ballistic/automatic/hd_gun/remis/svd/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 59, 14)

/obj/item/gun/ballistic/automatic/hd_gun/remis/g36/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 49, 14)

/obj/item/gun/ballistic/automatic/hd_gun/remis/g11
	name = "\improper Kh11 4.92x34mm Assault Rifle"
	desc = "An almost sci-fi designed rifle with a complex mechanism on the inside. \
	It was rumored in the past that the HRE was making a rifle that could be shot without casings being left behind, this chunky firearm is their sucess story."
	icon = '_horizon/icons/obj/items/guns/40x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_righthand.dmi'
	inhand_icon_state = "g11"
	icon_state = "g11"
	base_icon_state = "g11"
	accepted_magazine_type = /obj/item/ammo_box/magazine/a49234g11
	fire_sound = '_horizon/sound/weapons/guns/rifle/g11.ogg'
	load_sound = '_horizon/sound/weapons/guns/rifle/g11magin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/rifle/g11magin.wav'
	eject_sound = '_horizon/sound/weapons/guns/rifle/g11magout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/rifle/g11magout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/g11safety2.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/g11safety1.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/g11rack.wav'
	fireselector_auto = '_horizon/sound/weapons/guns/rifle/g11safety2.wav'
	fireselector_burst = '_horizon/sound/weapons/guns/rifle/g11safety2.wav'
	fireselector_semi = '_horizon/sound/weapons/guns/rifle/g11safety1.wav'
	force = 12
	fire_delay = 0.7
	burst_size = 3
	can_suppress = FALSE
	custom_price = 20000
	gunshot_animation_information = list(
		"pixel_x" = 21, \
		"pixel_y" = -1, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -10, \
		"recoil_angle_lower" = -20, \
		"recoil_burst_speed" = 0.5, \
		"return_burst_speed" = 0.5, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.3,
		"duration" = 2,
	)

//copypasted just to ensure that we can nuke the casing
/obj/item/gun/ballistic/automatic/hd_gun/remis/g11/handle_chamber(user, empty_chamber, from_firing, chamber_next_round)
	if((!semi_auto && from_firing) || (bolt_type == BOLT_TYPE_BREAK_ACTION))
		return
	var/obj/item/ammo_casing/casing = chambered //Find chambered round
	if(istype(casing)) //there's a chambered round
		if(QDELING(casing))
			stack_trace("Trying to move a qdeleted casing of type [casing.type]!")
			chambered = null
		else
			//Casing gets ejected and immediately deleted (i couldn't make this casing specific behavior)
			casing.forceMove(drop_location())
			SEND_SIGNAL(casing, COMSIG_CASING_EJECTED)
			if(!casing.loaded_projectile)
				qdel(casing)
			chambered = null
	if(chamber_next_round && (magazine?.max_ammo > 1))
		chamber_round()

/obj/item/gun/ballistic/automatic/hd_gun/remis/steyr
	name = "\improper Selo-Selo ACR Prototype Flechette-Firing Assault Rifle"
	desc = "A unique firearm that practically consists of one large piece with a barrel ran through the whole gun. Fires in steel-SCF Flechettes. \
		If you look hard enough, the entire gun seems to vibrate, and shake. It's almost like It's alive."
	gender = FEMALE
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_righthand.dmi'
	worn_icon_state = "steyr"
	inhand_icon_state = "steyr"
	icon_state = "steyr"
	base_icon_state = "steyr"
	accepted_magazine_type = /obj/item/ammo_box/magazine/a556steyr
	fire_sound = '_horizon/sound/weapons/guns/rifle/steyr.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/rifle/steyr_silenced.wav'
	load_sound = '_horizon/sound/weapons/guns/rifle/mmagin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/rifle/mmagin.wav'
	eject_sound = '_horizon/sound/weapons/guns/rifle/mmagout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/rifle/mmagout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/mrack.wav'
	actions_types = null
	force = 12
	suppressor_x_offset = 8
	can_suppress = TRUE
	verb_say = "passionately whispers"
	gunshot_animation_information = list(
		"pixel_x" = 29, \
		"pixel_y" = 0, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -10, \
		"recoil_angle_lower" = -20, \
		"recoil_burst_speed" = 0.5, \
		"return_burst_speed" = 0.5, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.1,
		"duration" = 1,
	)
	custom_price = 80000

/obj/item/gun/ballistic/automatic/hd_gun/remis/steyr/click_alt(mob/user)
	if(suppressed)
		return ..()
	var/sound_path = pick(
		'_horizon/sound/weapons/guns/rifle/voice_steyr/cyberpunk.wav',
		'_horizon/sound/weapons/guns/rifle/voice_steyr/consequences.wav',
		'_horizon/sound/weapons/guns/rifle/voice_steyr/thefeds.wav',
	)
	var/monologue
	switch(sound_path)
		if('_horizon/sound/weapons/guns/rifle/voice_steyr/cyberpunk.wav')
			monologue = "Cyberpunk is just a soyjack interpretation of the real world."
		if('_horizon/sound/weapons/guns/rifle/voice_steyr/consequences.wav')
			monologue = "Now you know the consequences of your actions."
		if('_horizon/sound/weapons/guns/rifle/voice_steyr/thefeds.wav')
			monologue = "I hate the feds."
	playsound(src, sound_path, 60, FALSE)
	if(monologue)
		say(monologue)
	INVOKE_ASYNC(src, PROC_REF(we_do_a_little_shaking))
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/automatic/hd_gun/remis/steyr/proc/we_do_a_little_shaking(intensity = 4, time_in = 2, time_out = 2, loops = 3)
	for(var/i in 1 to loops)
		animate(src, pixel_x = pixel_x + intensity, time = time_in)
		sleep(time_in)
		animate(src, pixel_x = pixel_x - intensity, time = time_out)
		sleep(time_out)

// 7.62x54R Lampiao sniper-rifle
/obj/item/gun/ballistic/automatic/hd_gun/remis/svd
	name = "\proper Judgement semi-automatic designated marksman rifle"
	desc = "A Judgement sniper-rifle firing in 7.62x54R, the design allows for comfortable medium and long range combat, and unconventional, but effective CQC against armored targets. \
	 Has a dovetail mount for a PSO-1M2-1 4x24 scope and a threaded barrel for a sound-suppressor. "
	icon = '_horizon/icons/obj/items/guns/64x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_righthand.dmi'
	worn_icon_state = "svd"
	inhand_icon_state = "svd"
	icon_state = "svd"
	base_icon_state = "svd"
	accepted_magazine_type = /obj/item/ammo_box/magazine/a762svd
	actions_types = null
	burst_size = 1
	fire_sound = '_horizon/sound/weapons/guns/rifle/svd.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/rifle/svd_silenced.wav'
	load_sound = '_horizon/sound/weapons/guns/rifle/svdmagin.wav'
	load_empty_sound = '_horizon/sound/weapons/guns/rifle/svdmagin.wav'
	eject_sound = '_horizon/sound/weapons/guns/rifle/svdmagout.wav'
	eject_empty_sound = '_horizon/sound/weapons/guns/rifle/svdmagout.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/aksafety2.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/aksafety1.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/akrack.wav'
	force = 13
	carry_weight = 4 KILOGRAMS
	custom_price = 30000
	recoil = 0.4
	can_suppress = TRUE
	suppressor_x_offset = 6
	suppressor_y_offset = 1
	gunshot_animation_information = list(
		"pixel_x" = 43, \
		"pixel_y" = 2, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -18, \
		"recoil_angle_lower" = -25, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.5,
		"duration" = 2,
	)

/obj/item/gun/ballistic/rifle/boltaction/hd_gun/remis
	worn_icon = '_horizon/icons/obj/items/guns/worn/back.dmi'
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_righthand.dmi'
	equip_sound = '_horizon/sound/weapons/guns/weap_away.ogg'
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	rack_sound_vary = FALSE
	suppressed = SUPPRESSED_NONE
	load_sound_vary = FALSE
	eject_sound_vary = FALSE
	mag_display = FALSE
	mag_display_ammo = FALSE
	empty_indicator = FALSE
	empty_icon_state = FALSE
	wielded_inhand_state = TRUE
	weapon_weight = WEAPON_HEAVY
	spread_unwielded = 12
	w_class = WEIGHT_CLASS_BULKY
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	can_be_sawn_off = FALSE
	can_jam = FALSE
	safety_flags = NONE
	pickup_sound = '_horizon/sound/weapons/guns/generic_draw.wav' // [HORIZON-ADD] GunRework family default
	dry_fire_sound = '_horizon/sound/weapons/guns/empty.wav' // [HORIZON-ADD] GunRework family default
	carry_weight = 2.5 KILOGRAMS // [HORIZON-ADD] GunRework family default
	client_recoil_animation_information = list("strength" = 0.35, "duration" = 2) // [HORIZON-ADD] GunRework family default

/obj/item/gun/ballistic/rifle/boltaction/hd_gun/remis/federson
	name = "\improper Dreaderson \"Brass Rain\" bolt-action rifle"
	desc = "A bolt-action rifle capable of piercing through armor, and making accurate shots even at a range. It's cursed by having It's own cartridge unfortunately, .276 Dreaderson."
	icon_state = "pedersen"
	base_icon_state = "pedersen"
	inhand_icon_state = "pedersen"
	worn_icon_state = "pedersen"
	fire_sound_volume = 100
	fire_sound = '_horizon/sound/weapons/guns/rifle/bolties/federson.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/rifle/bolties/federson_silenced.wav'
	rack_sound = '_horizon/sound/weapons/guns/rifle/bolties/federson_boltout.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/rifle/bolties/federson_boltin.wav'
	drop_sound = '_horizon/sound/weapons/guns/drop_mediumgun.wav'
	load_sound = '_horizon/sound/weapons/guns/rifle/bolties/federson_load1.wav'
	can_suppress = FALSE
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/federson
	rack_delay = 1

//G36
/obj/item/gun/ballistic/automatic/hd_gun/remis/g36
	name = "\improper Perdedor 5.56 Void International Assault Rifle"
	desc = "A sort-of melty, sort-of chocolately 5.56 assault rifle that has the appearance of something that would be easily churned and poured over toast or seafood."
	icon = '_horizon/icons/obj/items/guns/64x32.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/rifle_righthand.dmi'
	worn_icon_state = "g36"
	inhand_icon_state = "g36"
	icon_state = "g36"
	base_icon_state = "g36"
	accepted_magazine_type = /obj/item/ammo_box/magazine/a556g36
	fire_sound = '_horizon/sound/weapons/guns/rifle/g36.ogg'
	suppressed_sound = '_horizon/sound/weapons/guns/rifle/g36_suppressed.ogg'
	load_sound = '_horizon/sound/weapons/guns/rifle/g36_magin.ogg'
	load_empty_sound = '_horizon/sound/weapons/guns/rifle/g36_magin.ogg'
	eject_sound = '_horizon/sound/weapons/guns/rifle/g36_magout.ogg'
	eject_empty_sound = '_horizon/sound/weapons/guns/rifle/g36_magout.ogg'
	safety_off_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	rack_sound = '_horizon/sound/weapons/guns/smg/thump_rack.wav'
	fireselector_auto = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	fireselector_burst = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	fireselector_semi = '_horizon/sound/weapons/guns/rifle/msafety.wav'
	fold_open_sound = '_horizon/sound/weapons/guns/rifle/g36_fold.ogg'
	fold_close_sound = '_horizon/sound/weapons/guns/rifle/g36_unfold.ogg'
	force = 18
	fire_delay = 1.5
	burst_size = 3
	can_suppress = TRUE
	gunshot_animation_information = list(
		"pixel_x" = 36, \
		"pixel_y" = 3, \
		"inactive_when_suppressed" = TRUE, \
	)
	recoil_animation_information = list(
		"recoil_angle_upper" = -10, \
		"recoil_angle_lower" = -20, \
	)
	client_recoil_animation_information = list(
		"strength" = 0.18,
		"duration" = 1,
	)
	custom_price = 30000
	w_class = WEIGHT_CLASS_BULKY
	mag_display_ammo = TRUE
	full_auto = TRUE
	foldable = TRUE
	folded = FALSE

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare/m545/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 43, 15)

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare/m545/ak/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 44, 18)

/obj/item/gun/ballistic/automatic/hd_gun/remis/winter/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 43, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 47, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/steyr/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 43, 14)

/obj/item/gun/ballistic/automatic/hd_gun/remis/svd/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 59, 14)

/obj/item/gun/ballistic/automatic/hd_gun/remis/g36/add_attachment_slots()
	..()
	set_attachment_slot(ATTACHMENT_SLOT_MUZZLE, 49, 14)
