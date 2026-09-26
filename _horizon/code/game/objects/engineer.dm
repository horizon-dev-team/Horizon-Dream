
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

// MARK: Bluespace-RPD
/*
#define BSRPD_CAPAC_MAX 50
#define BSRPD_CAPAC_USE 1
#define BSRPD_CAPAC_NEW 5

/obj/item/pipe_dispenser/bluespace
	name = "Bluespace-RPD"
	desc = "A breakthrough in pipe-laying technology prevents you from being burned to a crisp while building yet another engine."
	icon_state = "rpd_ranged"
	icon = '_horizon/icons/obj/tools.dmi'
	lefthand_file = '_horizon/icons/obj/in_hands/tools_lefthand.dmi'
	righthand_file = '_horizon/icons/obj/in_hands/tools_righthand.dmi'
	var/bs_capac = BSRPD_CAPAC_MAX
	var/bs_use = BSRPD_CAPAC_USE
	var/bs_prog = 0
	bluespace = TRUE

/obj/item/pipe_dispenser/bluespace/attackby(obj/item/item, mob/user, param)
	if(istype(item, /obj/item/stack/sheet/bluespace_crystal) || istype(item, /obj/item/stack/ore/bluespace_crystal))
		if(BSRPD_CAPAC_NEW > (BSRPD_CAPAC_MAX - bs_capac) || bs_use == 0)
			to_chat(user, span_warning("[src] is at maximum charge capacity!"))
			return
		item.use(1)
		to_chat(user, span_notice("Recharging the bluespace capacitor inside [src]"))
		bs_capac += BSRPD_CAPAC_NEW
		return
	if(istype(item, /obj/item/assembly/signaler/anomaly/bluespace))
		if(bs_use)
			to_chat(user, span_notice("Installing [item] into [src]; now this thing will work much forever!"))
			bs_use = 0
			qdel(item)
		else
			to_chat(user, span_warning("Where to charge [src] more then!"))
		return
	return ..()

/obj/item/pipe_dispenser/bluespace/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		. += span_notice("Currently it has [bs_use == 0 ? "INFINITY" : bs_capac / bs_use] of charges.")
		if(bs_use != 0)
			. += span_notice("\nThe bluespace core is not installed.")
	else
		. += "I can't see charge from here."

/obj/item/pipe_dispenser/bluespace/afterattack(atom/A, mob/user, proximity_flag)
	if(!range_check(A, user))
		return FALSE

	if(proximity_flag)
		return ..()

	if(bs_capac < bs_use)
		to_chat(user, span_warning("[src] has no charge."))
		return FALSE
//	user.changeNext_move(CLICK_CD_RANGE)
	user.Beam(A, icon_state = "rped_upgrade", time = 1 SECONDS)

	if(pre_attack(target, user))
		bs_capac -= bs_use
		return TRUE

	return FALSE

/obj/item/pipe_dispenser/bluespace/proc/range_check(atom/A, mob/user)
	if(!(A in view(7, get_turf(user))))
		to_chat(user, span_warning("The \'Out of Range\' light on [src] blinks red."))
		return FALSE
	else
		return TRUE

#undef BSRPD_CAPAC_MAX
#undef BSRPD_CAPAC_USE
#undef BSRPD_CAPAC_NEW
*/
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

// /obj/item/storage/belt/medical/surgery_belt_adv
