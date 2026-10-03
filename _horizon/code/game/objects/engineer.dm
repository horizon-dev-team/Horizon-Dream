/obj/item/construction/rcd/arcd/debug
	max_matter = INFINITY
	matter = INFINITY
	construction_upgrades = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS
	delay_mod = 0.3

/obj/item/inducer/adv
	icon_state = "inducer-adv"
	desc = "A tool for inductively charging internal power cells. This one has a white-bluespace color scheme, and seems to be rigged to transfer charge at a much faster rate."
	power_transfer_multiplier = 5
	powerdevice = /obj/item/stock_parts/power_store/battery/bluespace

/obj/item/storage/belt/utility/full/powertools/holding
	name = "belt of holding"
	desc = "The greatest in pants-supporting bluespace technology."
	icon = '_horizon/icons/obj/belt.dmi'
	worn_icon = '_horizon/icons/obj/in_mob/belt_mob.dmi'
	icon_state = "holdingbelt"
	worn_icon_state = "holdingbelt"
	content_overlays = FALSE
	storage_type = /datum/storage/utility_belt/holding

/obj/item/storage/belt/utility/full/powertools/holding/PopulateContents()
	new /obj/item/screwdriver/power(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/weldingtool/experimental(src)
	new /obj/item/multitool(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/extinguisher/mini(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/analyzer/ranged(src)
	new /obj/item/geiger_counter(src)
	new /obj/item/pipe_dispenser(src)
	new /obj/item/construction/rcd/arcd/debug(src)
	new /obj/item/inducer(src)
