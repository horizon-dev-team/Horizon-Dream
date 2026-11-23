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
	load_sound = list(
		'_horizon/sound/weapons/guns/shotgun/shell1.wav', \
		'_horizon/sound/weapons/guns/shotgun/shell2.wav', \
		'_horizon/sound/weapons/guns/shotgun/shell3.wav', \
	)
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
	name = "\"Палач рока\""
	desc = "\"Фирменный\" дробовик с двумя стволами. Не в бровь, а в глаз."
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


/obj/item/gun/ballistic/shotgun/hd_gun/hunting
	name = "ОД Папасши \"Охотник\""
	desc = "Охотничный дробовик Папасши. Калибр - 12-ый."
	icon_state = "huntingshot"
	base_icon_state = "huntingshot"
	empty_icon_state = TRUE

// ??? SHOTGUN
/obj/item/gun/ballistic/shotgun/hd_gun/riot
	name = "\improper Riot-S12 \"Downer\""
	desc = "Дробовик компании Riot Solution с фиксированной тактическим прикладом. Был разработан в качестве решения для подавления беспорядков нелетальной силой. \
		Тем не менее летальные боеприпасы без труда можно использовать. \
		Калибр - 12-ый."
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

/obj/item/gun/ballistic/shotgun/automatic/hd_gun
	bolt_type = BOLT_TYPE_LOCKING
	lock_back_sound = '_horizon/sound/weapons/guns/shotgun/semigun_lock_back.wav'
	bolt_drop_sound = '_horizon/sound/weapons/guns/shotgun/semigun_lockin.wav'

// BENELLI M4 SHOTGUN
/obj/item/gun/ballistic/shotgun/automatic/hd_gun/combat
	name = "\improper Shottex CQB shotgun"
	desc = "Полуавтоматический дробовик в обвесе. Имеет магазин в 6(+1) патрон. Калибр - 12-ый."
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
	desc = "Классический помповый дробовик компании Shottex, их слоган: \"Без дробовика - и жизнь худа!\". \
		Вмещает в себя 4(+1) патрона. Калибр - 12-ый."
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
	desc = "Дробовик компании Shottex \"Голубь\" сочетает в себе кастомизацию, грубую отладку и убойную точность. \
		Имеет встроенный глушитель. \
		Вмещает в себя 9(+1) патрон. Калибр - 12-й."
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

/obj/item/gun/ballistic/shotgun/automatic/hd_gun/b2021/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/suppressor = new(src)
	install_suppressor(suppressor)

// AA12 i guess AUTOMATIC SHOTGUN
/obj/item/gun/ballistic/shotgun/hd_gun/bulldog
	name = "\improper Modelo 1337 \"Torturador\""
	desc = "Полуавтоматический дробовик магазинного типа. Производитель - испанцы из Modelo. \
		К его шахте заряжания подходят только барабанные магазины на 8(+1 в стволе) пуль! \
		Калибр - 12-ый. "
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

// SAIGA-12 AUTOMATIC SHOTGUN
/obj/item/gun/ballistic/shotgun/hd_gun/abyss
	name = "\improper АД-12 Папасши"
	desc = "Автоматический дробовик Папасши магазинной системы заряжания. Вмещает в себя 20 патрон. \
		Калибр - 12-ый."
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

// KS23 | TOZ-123 DESTROYER
/obj/item/gun/ballistic/shotgun/hd_gun/bolas
	name = "\improper ДС-4 Папасши"
	desc = "Громоздкий дробовик, вмещающий в себя 4 огромных патрона. \
		Калибр - 4-ый."
	icon = '_horizon/icons/obj/items/guns/48x32.dmi'
	icon_state = "bolas"
	base_icon_state = "bolas"
	inhand_icon_state = "bolas"
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/bolas
	fire_sound = '_horizon/sound/weapons/guns/shotgun/bolas.wav'
	suppressed_sound = '_horizon/sound/weapons/guns/shotgun/bolas_silenced.wav'
	load_sound = list(
		'_horizon/sound/weapons/guns/shotgun/bolas_load1.wav', \
		'_horizon/sound/weapons/guns/shotgun/bolas_load2.wav', \
		'_horizon/sound/weapons/guns/shotgun/bolas_load3.wav', \
	)
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

// SPAS 12
/obj/item/gun/ballistic/shotgun/hd_gun/denominator
	name = "\improper Riot-S12 \"Special\""
	desc = "Автоматический дробовик с помповым заряжанием. Имеет выбор с полуавтоматического режима на автоматический. \
	Нажми на СКМ, когда помпа в закрытом положении и предохранитель отключен."
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

/obj/item/gun/ballistic/shotgun/hd_gun/denominator/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(bolt_locked || (safety_flags & GUN_SAFETY_ENABLED))
		var/wontbudge = span_notice("Флажок переключателя режимов не поддаётся.")
		if(safety_flags & GUN_SAFETY_ENABLED)
			wontbudge += span_warning(" Предохранитель должен быть снят.")
		if(bolt_locked)
			wontbudge += span_danger(" Затвор должен быть передёрнут.")
		to_chat(user, wontbudge)
		return ITEM_INTERACT_BLOCKING
	semi = !semi
	user.visible_message(span_warning("[user] переключает переключатель режимов огня на [semi ? "S" : "F"]."), \
	span_notice("Я переключил переключатель режимов огня на позицию [semi ? "S" : "F"]."))
	if(semi)
		playsound(src, safety_off_sound, safety_sound_volume, safety_sound_vary)
	else
		playsound(src, safety_on_sound, safety_sound_volume, safety_sound_vary)
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/ballistic/shotgun/hd_gun/denominator/shoot_live_shot(mob/living/user)
	. = ..()
	if(semi)
		playsound(src, spas_semi_click, 80, FALSE)
		rack()
