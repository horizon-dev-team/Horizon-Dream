/obj/item/gun/energy/hd_gun/nasr
	name = "Nasr"
	desc = "A handheld, industrial device meant to melt glue at low-voltages. It has been powered wirelessly by the hatred and blatent racism of a certain egyption indevidual with terroristic intentions."
	icon = '_horizon/icons/obj/items/guns/energy.dmi'
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/pistol_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/pistol_righthand.dmi'
	equip_sound = '_horizon/sound/weapons/guns/pistol/pistol_holster.wav'
	pickup_sound = '_horizon/sound/weapons/guns/pistol/pistol_draw.wav'
	fire_sound = '_horizon/sound/weapons/guns/energy/nasr.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/energy/siren_safetyoff.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/energy/siren_safetyon.wav'
	drop_sound = '_horizon/sound/weapons/guns/drop_lightgun.wav'
	dry_fire_sound = '_horizon/sound/weapons/guns/energy/nasr_alarm1.wav'
	vary_fire_sound = FALSE
	slot_flags = ITEM_SLOT_BELT
	weapon_weight = WEAPON_LIGHT
	wielded_inhand_state = FALSE
	empty_icon_state = FALSE
	inhand_icon_state = "nasr"
	icon_state = "nasr"
	base_icon_state = "nasr"
	cell_type = /obj/item/stock_parts/power_store/cell
	charge_delay = 15
	ammo_type = list(/obj/item/ammo_casing/energy/nasr)
	custom_materials = list(/datum/material/uranium=10000, \
						/datum/material/titanium=75000, \
						/datum/material/glass=5000)
	modifystate = FALSE
	automatic_charge_overlays = FALSE
	single_shot_type_overlay = FALSE
	display_empty = TRUE
	can_select = FALSE
	fire_delay = 2 SECONDS
	force = 17
	carry_weight = 5 KILOGRAMS
	w_class = WEIGHT_CLASS_NORMAL
	selfcharge = TRUE
	custom_price = 100000
	gunshot_animation_information = list(
		"icon_state" = "energyshot", \
		"pixel_x" = 16, \
		"pixel_y" = 2,
		)
	recoil_animation_information = list(
		"recoil_angle_upper" = -15, \
		"recoil_angle_lower" = -30
		)

/obj/item/gun/energy/hd_gun/nasr/process(delta_time)
	if(selfcharge && cell && cell.percent() < 100)
		charge_timer += delta_time
		if(charge_timer < charge_delay)
			return
		charge_timer = 0
		cell.give(500)
		if(!chambered)
			recharge_newshot(TRUE)
		flick("nasr_reload", src)
		playsound(src, '_horizon/sound/weapons/guns/energy/nasrcharge.wav', 30, FALSE)
