/obj/item/gun/energy/hd_gun/heavy_plasma
	abstract_type = /obj/item/gun/energy/hd_gun/heavy_plasma
	name = "\improper \"Siren\" Heavy Plasma Rifle"
	desc = "An unwieldly and burdenly heavy firearm capable of firing without physical bullets, but instead utilizing chargable plasma batteries."
	icon = '_horizon/icons/obj/items/guns/energy.dmi'
	icon_state = "plasmarifle"
	base_icon_state = "plasmarifle"
	lefthand_file = '_horizon/icons/obj/items/guns/inhands/64x64_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/items/guns/inhands/64x64_righthand.dmi'
	inhand_icon_state = "plasmarifle"
	wielded_inhand_state = TRUE
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	equip_sound = '_horizon/sound/weapons/guns/weap_away.ogg'
	fire_sound = '_horizon/sound/weapons/guns/energy/siren.wav'
	safety_off_sound = '_horizon/sound/weapons/guns/energy/siren_safetyoff.wav'
	safety_on_sound = '_horizon/sound/weapons/guns/energy/siren_safetyon.wav'
	drop_sound = '_horizon/sound/weapons/guns/drop_heavygun.wav'
	vary_fire_sound = FALSE
	cell_type = /obj/item/stock_parts/power_store/cell/high
	charge_delay = 5
	ammo_type = list(/obj/item/ammo_casing/energy/siren)
	custom_materials = list(/datum/material/uranium=10000, \
						/datum/material/titanium=25000, \
						/datum/material/glass=2000)
	modifystate = FALSE
	can_select = FALSE
	automatic_charge_overlays = TRUE
	shaded_charge = TRUE
	charge_sections = 5
	display_empty = TRUE
	selfcharge = TRUE
	custom_price = 100000
	force = 15
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_HEAVY
	burst_size = 2
	carry_weight = 5 KILOGRAMS
	gunshot_animation_information = list("icon_state" = "boltshot", \
						"pixel_x" = 28, \
						"pixel_y" = 13)
	recoil_animation_information = list("recoil_angle_upper" = -15, \
						"recoil_angle_lower" = -25)

/obj/item/gun/energy/hd_gun/heavy_plasma/siren/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 3)
