// MARK: Portable Recharger Item
/obj/item/recharger_item
	name = "portable recharging station"
	desc = "A portable dual-port weapon recharger. It draws power from the station grid, with a built-in battery serving as a backup. To begin operation, deploy it in any suitable location."
	icon = '_horizon/icons/obj/sec_recharger_portable.dmi'
	icon_state = "case"
	inhand_icon_state = "toolbox_default"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	force = 15
	throwforce = 12
	throw_speed = 2
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = 500)
	attack_verb_continuous = list("robusts")
	attack_verb_simple = list("robust")
	hitsound = 'sound/items/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox/toolbox_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbox/toolbox_pickup.ogg'
	max_integrity = 200
	//armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 100, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	wound_bonus = 5
	var/cell_charge = 10000
	var/cell_maxcharge = 10000
	var/cond_tier = 1

//	Разворачивание станции
/obj/item/recharger_item/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isopenturf(interacting_with))
		return NONE

	var/turf/target_turf = interacting_with
	if(!user.Adjacent(target_turf))
		return NONE
	if(target_turf.is_blocked_turf(source_atom = src))
		balloon_alert(user, "no space to deploy here.")
		return ITEM_INTERACT_BLOCKING

	if(locate(/obj/machinery/recharger) in target_turf)
		balloon_alert(user, "the area is occupied by machinery.")
		return ITEM_INTERACT_BLOCKING

	deploy_recharger(user, target_turf)
	return ITEM_INTERACT_SUCCESS

/obj/item/recharger_item/proc/deploy_recharger(mob/user, atom/location)
	var/obj/machinery/recharger/portable/station_machine = new /obj/machinery/recharger/portable(location)
	var/obj/item/stock_parts/power_store/cell/port_cell = locate(/obj/item/stock_parts/power_store/cell) in station_machine.component_parts
	if(port_cell)
		port_cell.maxcharge = cell_maxcharge
		port_cell.charge = cell_charge
	station_machine.recharge_coeff = cond_tier
	station_machine.add_fingerprint(user)
	station_machine.deploying = TRUE
	station_machine.update_appearance(UPDATE_OVERLAYS)
	flick("sec-deploy", station_machine)
	addtimer(CALLBACK(station_machine, TYPE_PROC_REF(/obj/machinery/recharger/portable, finish_deployment)), 35) // Animation time
	user.visible_message(span_notice("[user] deploys the recharging station."), span_notice("You deploy the recharging station."))
	playsoundtoken(station_machine, '_horizon/sound/recharger_deploy.ogg', 40, SOUND_RANGE)
	qdel(src)

/obj/machinery/recharger/portable/proc/finish_deployment()
	if(QDELETED(src))
		return
	deploying = FALSE
	update_appearance(UPDATE_OVERLAYS)

/obj/item/recharger_item/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += "<hr><span class='warning'>Too far away to make out the recharging station's display!</span>"
		return
	. += "<span class='notice'>Display:</span>"
	. += "<span class='notice'>- Battery level: <b>[cell_charge*100/cell_maxcharge]%</b>.</span>"

/obj/item/circuitboard/machine/portable_recharger
	name = "portable recharging station"
	desc = "A portable dual-port weapon recharger. It draws power from the station grid, with a built-in battery serving as a backup. To begin operation, deploy it in any suitable location."
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/recharger/portable
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/power_store/cell = 1,
		)
	def_components = list(/obj/item/stock_parts/power_store/cell = /obj/item/stock_parts/power_store/cell/high)
	needs_anchored = FALSE

// MARK: Portable Recharger Machine
/obj/machinery/recharger/portable
	name = "portable recharging station"
	desc = "A portable dual-port weapon recharger. It draws power from the station grid, with a built-in battery serving as a backup. It can be folded up for transport when needed."
	icon = '_horizon/icons/obj/sec_recharger_portable.dmi'
	icon_state = "sec"
	base_icon_state = "sec"
	circuit = /obj/item/circuitboard/machine/portable_recharger
	use_power = NO_POWER_USE
	anchored = TRUE
	var/obj/item/charging2 = null
	var/using_power2 = FALSE
	var/deploying = FALSE

/obj/machinery/recharger/portable/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	if(charging2)
		var/obj/item/stock_parts/power_store/charging_cell2 = charging2.get_cell()
		if(charging_cell2)
			. += span_notice("- \The [charging2]'s cell is at <b>[charging_cell2.percent()]%</b>.")
			return
		if(istype(charging2, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/power_pack2 = charging2
			. += span_notice("- \The [charging2]'s cell is at <b>[PERCENT(power_pack2.stored_ammo.len/power_pack2.max_ammo)]%</b>.")
			return
		if(istype(charging2, /obj/item/gun/ballistic/automatic/battle_rifle))
			var/obj/item/gun/ballistic/automatic/battle_rifle/recalibrating_gun2 = charging2
			. += span_notice("- \The [charging2]'s system degradation is at stage [recalibrating_gun2.degradation_stage] of [recalibrating_gun2.degradation_stage_max].")
			. += span_notice("- \The [charging2]'s degradation buffer is at <b>[PERCENT(recalibrating_gun2.shots_before_degradation/recalibrating_gun2.max_shots_before_degradation)]%</b>.")
			return
		. += span_notice("- \The [charging2] is not reporting a power level.")

/obj/machinery/recharger/portable/process(seconds_per_tick)
	if(machine_stat & BROKEN || !anchored)
		return PROCESS_KILL

	using_power = FALSE
	using_power2 = FALSE

	var/area/a = get_area(src)
	var/has_grid_power = isarea(a) && a.power_equip != 0

	// Встроенная батарея станции. // Подзарядка встроенной батареи от сети.
	var/obj/item/stock_parts/power_store/cell/port_cell = locate(/obj/item/stock_parts/power_store/cell) in component_parts
	if(port_cell && port_cell.charge < port_cell.maxcharge && has_grid_power)
		port_cell.give(port_cell.chargerate * recharge_coeff * seconds_per_tick / 12)

	if(charging) // Charging Port 1
		using_power = process_charging_port(charging, seconds_per_tick, port_cell, has_grid_power)

	if(charging2) // Charging Port 2
		using_power2 = process_charging_port(charging2, seconds_per_tick, port_cell, has_grid_power)

	update_appearance()

	if(!charging && !charging2)
		return PROCESS_KILL

/obj/machinery/recharger/portable/proc/process_charging_port(obj/item/charging_item, seconds_per_tick, obj/item/stock_parts/power_store/cell/port_cell, has_grid_power)
	if(!charging_item)
		return FALSE

	var/obj/item/stock_parts/power_store/cell/charging_cell = charging_item.get_cell()
	if(charging_cell)
		if(charging_cell.charge >= charging_cell.maxcharge)
			return FALSE

		var/charge_amount = charging_cell.chargerate * recharge_coeff * seconds_per_tick

		if(has_grid_power)
			use_energy(active_power_usage * recharge_coeff * seconds_per_tick)
			charging_cell.give(charge_amount)
		else
			if(!port_cell || port_cell.charge <= 0)
				return FALSE

			var/backup_charge = min(charge_amount, port_cell.charge)
			port_cell.use(backup_charge)
			charging_cell.give(backup_charge)

		if(charging_cell.charge >= charging_cell.maxcharge)
			playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
			say("[charging_item] has finished recharging!")
			charging_item.update_appearance(UPDATE_OVERLAYS)
			return FALSE

		charging_item.update_appearance(UPDATE_OVERLAYS)
		return TRUE

	if(istype(charging_item, /obj/item/ammo_box/magazine/recharge))
		var/obj/item/ammo_box/magazine/recharge/power_pack = charging_item
		for(var/charge_iterations in 1 to recharge_coeff)
			if(power_pack.stored_ammo.len >= power_pack.max_ammo)
				break
			if(has_grid_power)
				power_pack.stored_ammo += new power_pack.ammo_type(power_pack)
				use_energy(active_power_usage * seconds_per_tick)
			else
				if(!port_cell || port_cell.charge <= 0)
					break
				var/ammo_charge_cost = active_power_usage * seconds_per_tick
				if(port_cell.charge < ammo_charge_cost)
					break
				port_cell.use(ammo_charge_cost)
				power_pack.stored_ammo += new power_pack.ammo_type(power_pack)

		if(power_pack.stored_ammo.len >= power_pack.max_ammo)
			playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
			say("[charging_item] has finished recharging!")
			charging_item.update_appearance(UPDATE_OVERLAYS)
			return FALSE

		charging_item.update_appearance(UPDATE_OVERLAYS)
		return power_pack.stored_ammo.len < power_pack.max_ammo

	if(istype(charging_item, /obj/item/gun/ballistic/automatic/battle_rifle))
		var/obj/item/gun/ballistic/automatic/battle_rifle/recalibrating_gun = charging_item

		if(recalibrating_gun.degradation_stage)
			if(has_grid_power)
				recalibrating_gun.attempt_recalibration(FALSE)
				use_energy(active_power_usage * recharge_coeff * seconds_per_tick)
			else
				if(!port_cell || port_cell.charge <= 0)
					return FALSE

				var/recalibration_cost = active_power_usage * recharge_coeff * seconds_per_tick
				if(port_cell.charge < recalibration_cost)
					return FALSE

				port_cell.use(recalibration_cost)
				recalibrating_gun.attempt_recalibration(FALSE)

			charging_item.update_appearance(UPDATE_OVERLAYS)
			return TRUE

		if(recalibrating_gun.shots_before_degradation < recalibrating_gun.max_shots_before_degradation)
			if(has_grid_power)
				recalibrating_gun.attempt_recalibration(TRUE, recharge_coeff)
				use_energy(active_power_usage * recharge_coeff * seconds_per_tick)
			else
				if(!port_cell || port_cell.charge <= 0)
					return FALSE

				var/recalibration_cost = active_power_usage * recharge_coeff * seconds_per_tick
				if(port_cell.charge < recalibration_cost)
					return FALSE

				port_cell.use(recalibration_cost)
				recalibrating_gun.attempt_recalibration(TRUE, recharge_coeff)

			if(recalibrating_gun.shots_before_degradation >= recalibrating_gun.max_shots_before_degradation)
				playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
				say("[charging_item] has finished recalibrating!")
				charging_item.update_appearance(UPDATE_OVERLAYS)
				return FALSE

			charging_item.update_appearance(UPDATE_OVERLAYS)
			return TRUE

		return FALSE

	return FALSE

/obj/machinery/recharger/portable/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!is_type_in_typecache(arrived, allowed_devices))
		return

	if(isnull(charging)) // Charging Port 1
		charging = arrived
		START_PROCESSING(SSmachines, src)
		update_use_power(ACTIVE_POWER_USE)
		using_power = TRUE
		update_appearance(UPDATE_OVERLAYS)
		return

	if(isnull(charging2)) // Charging Port 2
		charging2 = arrived
		START_PROCESSING(SSmachines, src)
		update_use_power(ACTIVE_POWER_USE)
		using_power2 = TRUE
		update_appearance(UPDATE_OVERLAYS)
		return

/obj/machinery/recharger/portable/Exited(atom/movable/gone, direction)
	if(gone == charging) // Charging Port 1
		if(!QDELING(gone))
			gone.update_appearance(UPDATE_OVERLAYS)

		charging = null
		using_power = FALSE
		update_use_power(charging2 ? ACTIVE_POWER_USE : IDLE_POWER_USE)
		update_appearance(UPDATE_OVERLAYS)
		return

	if(gone == charging2) // Charging Port 2
		if(!QDELING(gone))
			gone.update_appearance(UPDATE_OVERLAYS)

		charging2 = null
		using_power2 = FALSE
		update_use_power(charging ? ACTIVE_POWER_USE : IDLE_POWER_USE)
		update_appearance(UPDATE_OVERLAYS)
		return

/obj/machinery/recharger/portable/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_type_in_typecache(tool, allowed_devices))
		return NONE

	if(!anchored)
		to_chat(user, span_notice("[src] isn't connected to anything!"))
		return ITEM_INTERACT_BLOCKING

	if(panel_open)
		return ITEM_INTERACT_BLOCKING

	if(deploying)
		to_chat(user, span_notice("[src] is still deploying!"))
		return ITEM_INTERACT_BLOCKING

	if(charging && charging2)
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = tool

		if(!energy_gun.can_charge)
			to_chat(user, span_notice("Your gun has no external power connector."))
			return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING

	return ITEM_INTERACT_SUCCESS

/obj/machinery/recharger/portable/attack_hand(mob/user, list/modifiers)
	if(!charging)
		return ..()

	add_fingerprint(user)

	if(user.put_in_hands(charging))
		return

	charging.forceMove(drop_location())

/obj/machinery/recharger/portable/attack_hand_secondary(mob/user, list/modifiers)
	if(charging2)
		add_fingerprint(user)

		if(user.put_in_hands(charging2))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		charging2.forceMove(drop_location())
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/machinery/recharger/portable/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(!ishuman(user) || !user.can_perform_action(src) || deploying)
		return
	if(charging || charging2)
		to_chat(user, span_warning("Remove the charging items first!"))
		return
	user.visible_message(span_notice("[user] folds up the recharging station."), span_notice("You fold up the recharging station."))
	var/obj/item/recharger_item/station_case = new /obj/item/recharger_item(src.drop_location())
	station_case.anchored = TRUE
	addtimer(CALLBACK(station_case, TYPE_PROC_REF(/obj/item/recharger_item, finish_undeployment)), 35) // Animation time
	flick("sec-move", station_case)
	playsoundtoken(station_case, '_horizon/sound/recharger_go.ogg', 40, SOUND_RANGE)
	var/obj/item/stock_parts/power_store/cell/port_cell = locate(/obj/item/stock_parts/power_store/cell) in component_parts
	if(port_cell)
		station_case.cell_maxcharge = port_cell.maxcharge
		station_case.cell_charge = port_cell.charge
	station_case.cond_tier = recharge_coeff
	qdel(src)

/obj/item/recharger_item/proc/finish_undeployment()
	if(QDELETED(src))
		return
	anchored = FALSE

/obj/machinery/recharger/portable/screwdriver_act(mob/living/user, obj/item/tool)
	if(charging || charging2)
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/machinery/recharger/portable/can_crowbar_deconstruct()
	return ..() && !charging && !charging2

/obj/machinery/recharger/portable/update_overlays()
	. = ..()
	if(machine_stat & BROKEN || !anchored || deploying)
		return

	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]-open")
		return

	var/area/a = get_area(src)
	var/obj/item/stock_parts/power_store/cell/port_cell = locate(/obj/item/stock_parts/power_store/cell) in component_parts
	if(port_cell)
		var/cell_state
		switch(round(port_cell.percent()))
			if(0 to 14)
				cell_state = "1"
			if(15 to 28)
				cell_state = "2"
			if(29 to 42)
				cell_state = "3"
			if(43 to 56)
				cell_state = "4"
			if(57 to 70)
				cell_state = "5"
			if(71 to 84)
				cell_state = "6"
			if(85 to 100)
				cell_state = "7"

		. += mutable_appearance(icon, "[base_icon_state]-charge-[cell_state]")
		. += emissive_appearance(icon, "[base_icon_state]-charge-[cell_state]", src, alpha = src.alpha)

		var/power_net
		if(port_cell.percent() != 0)
			if(!isarea(a) || a.power_equip == 0)
				power_net = "cell"
			else
				if(port_cell.percent() < 100)
					power_net = "rech"
				else
					power_net = "net"
		else
			power_net = "dead"
		. += mutable_appearance(icon, "[base_icon_state]-power-[power_net]")
		. += emissive_appearance(icon, "[base_icon_state]-power-[power_net]", src, alpha = src.alpha)

	if(charging)
		if(port_cell && port_cell.percent() != 0)
			var/port_1_cell_percent
			var/port_1_cell_percent_num
			var/obj/item/stock_parts/power_store/cell/charging_port1 = charging.get_cell()	// запрос к реальной батарее
			port_1_cell_percent_num = charging_port1 ? charging_port1.percent() : 0
			switch(round(port_1_cell_percent_num))
				if(0 to 14)
					port_1_cell_percent = "1"
				if(15 to 28)
					port_1_cell_percent = "2"
				if(29 to 42)
					port_1_cell_percent = "3"
				if(43 to 56)
					port_1_cell_percent = "4"
				if(57 to 70)
					port_1_cell_percent = "5"
				if(71 to 84)
					port_1_cell_percent = "6"
				if(85 to 100)
					port_1_cell_percent = "7"
			. += mutable_appearance(icon, "[base_icon_state]-p1-cell-[port_1_cell_percent]")
			. += emissive_appearance(icon, "[base_icon_state]-p1-cell-[port_1_cell_percent]", src, alpha = src.alpha)

			var/icon_to_use = "[base_icon_state]-p1-[using_power ? "charging" : "full"]"
			. += mutable_appearance(icon, icon_to_use)
			. += emissive_appearance(icon, icon_to_use, src, alpha = src.alpha)
		else
			if(!isarea(a) || a.power_equip == 0)
				. += mutable_appearance(icon, "[base_icon_state]-p1-cell-fail")
				. += emissive_appearance(icon, "[base_icon_state]-p1-cell-fail", src, alpha = src.alpha)

	if(charging2)
		if(port_cell && port_cell.percent() != 0)
			var/port_2_cell_percent
			var/port_2_cell_percent_num
			var/obj/item/stock_parts/power_store/cell/charging_port2 = charging2.get_cell()
			port_2_cell_percent_num = charging_port2 ? charging_port2.percent() : 0
			switch(round(port_2_cell_percent_num))
				if(0 to 14)
					port_2_cell_percent = "1"
				if(15 to 28)
					port_2_cell_percent = "2"
				if(29 to 42)
					port_2_cell_percent = "3"
				if(43 to 56)
					port_2_cell_percent = "4"
				if(57 to 70)
					port_2_cell_percent = "5"
				if(71 to 84)
					port_2_cell_percent = "6"
				if(85 to 100)
					port_2_cell_percent = "7"
			. += mutable_appearance(icon, "[base_icon_state]-p2-cell-[port_2_cell_percent]")
			. += emissive_appearance(icon, "[base_icon_state]-p2-cell-[port_2_cell_percent]", src, alpha = src.alpha)

			var/icon_to_use2 = "[base_icon_state]-p2-[using_power2 ? "charging" : "full"]"
			. += mutable_appearance(icon, icon_to_use2)
			. += emissive_appearance(icon, icon_to_use2, src, alpha = src.alpha)
		else
			if(!isarea(a) || a.power_equip == 0)
				. += mutable_appearance(icon, "[base_icon_state]-p2-cell-fail")
				. += emissive_appearance(icon, "[base_icon_state]-p2-cell-fail", src, alpha = src.alpha)

/obj/machinery/recharger/portable/wrench_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("[src] is permanently deployed and cannot be anchored or moved with a wrench."))
	return ITEM_INTERACT_BLOCKING

// MARK: Tactical Recharger
/obj/item/tactical_recharger
	name = "tactical weapon recharger"
	desc = "An advanced portable recharging station for energy weapons. Its charging rate is slightly lower than that of larger models, but using it still significantly extends the overall potential capacity of any energy weapon."
	icon = '_horizon/icons/obj/tactical_recharger.dmi'
	icon_state = "toz"
	worn_icon = '_horizon/icons/obj/in_mob/tactical_recharger_body.dmi'
	worn_icon_state = "toz"
	force = 15
	dog_fashion = null
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_SUITSTORE
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'

	var/chargerate = 100

	var/obj/item/charging = null
	var/using_power = FALSE
	var/recharge_coeff = 0.5

	var/obj/item/stock_parts/power_store/cell/internal_cell
	var/min_cell_maxcharge = 2500
	var/panel_open = FALSE

	var/overlay_state
	var/mutable_appearance/gun_overlay

/obj/item/tactical_recharger/examine(mob/user)
	. = ..()
	. += "<hr><span class='notice'>Display:</span>"
	if(internal_cell)
		. += "<span class='notice'>- Battery level: <b>[internal_cell.percent()]%</b>.</span>"
	else
		. += "<span class='warning'>- No cell installed! Use a power cell on [src] to install one.</span>"
	if(panel_open)
		. += "<span class='notice'>The service panel is open. Use a crowbar to pry out the cell, or click with a power cell to install one.</span>"
	else
		. += "<span class='notice'>The service panel is closed. Use a screwdriver to open it.</span>"
	if(charging)
		var/obj/item/stock_parts/power_store/cell/weapon_cell = charging.get_cell()
		. += "<span class='notice'>- Weapon charge: <b>[charging]</b> - <b>[weapon_cell.percent()]%</b>.</span>"

/datum/storage/pockets/tactical_recharger
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_BULKY
	rustle_sound = FALSE
	attack_hand_interact = TRUE

/datum/storage/pockets/tactical_recharger/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(/obj/item/gun/energy))

/obj/item/tactical_recharger/get_cell()
	return internal_cell

/obj/item/tactical_recharger/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/tactical_recharger)
	internal_cell = new /obj/item/stock_parts/power_store/cell/high(null)
	START_PROCESSING(SSmachines, src)
	update_appearance()

/obj/item/tactical_recharger/Destroy()
	STOP_PROCESSING(SSmachines, src)
	QDEL_NULL(internal_cell)
	return ..()

/obj/item/tactical_recharger/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	if(!istype(item, /obj/item/stock_parts/power_store/cell))
		return NONE

	if(!panel_open)
		balloon_alert(user, "panel closed!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/stock_parts/power_store/cell/new_cell = item
	if(new_cell.maxcharge < min_cell_maxcharge)
		to_chat(user, span_notice("[src] requires a higher capacity cell."))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/old_cell = internal_cell
	if(old_cell)
		old_cell.forceMove(get_turf(src))
		to_chat(user, span_notice("You swap [old_cell] out of [src]."))

	if(!user.temporarilyRemoveItemFromInventory(item))
		return NONE
	item.moveToNullspace()
	internal_cell = item
	START_PROCESSING(SSmachines, src)

	if(!old_cell)
		to_chat(user, span_notice("You install [item] in [src]."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/tactical_recharger/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(.)
		return TRUE
	panel_open = !panel_open
	balloon_alert(user, "panel [panel_open ? "open" : "closed"]")
	tool.play_tool_sound(src, 50)
	update_appearance()
	return TRUE

/obj/item/tactical_recharger/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(!panel_open)
		balloon_alert(user, "panel closed!")
		return
	if(!internal_cell)
		balloon_alert(user, "no cell!")
		return
	balloon_alert(user, "prying out cell...")
	tool.play_tool_sound(src, 50)
	if(!tool.use_tool(src, user, 3 SECONDS))
		return
	var/obj/item/cell_to_move = internal_cell
	internal_cell = null
	cell_to_move.forceMove(get_turf(src))
	user.put_in_hands(cell_to_move)
	balloon_alert(user, "cell removed")
	playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	update_appearance()
	return

/obj/item/tactical_recharger/attack_hand(mob/user)
	if(loc != user || user.get_item_by_slot(ITEM_SLOT_SUITSTORE) != src || !user.can_perform_action(src))
		return ..()

	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] draws [I] from the tactical recharger."), span_notice("You draw [I] from the tactical recharger."))
		I.forceMove(get_turf(loc))
		user.put_in_hands(I)
		update_appearance()
		update_icon()
		user.update_suit_storage()

	return ..()

/obj/item/tactical_recharger/update_icon_state()
	icon_state = initial(icon_state)
//	worn_icon_state = initial(worn_icon_state)
	gun_overlay = null
	overlay_state = null
	if(length(contents))
		var/obj/item/I = contents[1]
		charging = I
	else
		charging = null
	return ..()

/obj/item/tactical_recharger/process(seconds_per_tick)
	using_power = FALSE
	if(length(contents))
		charging = contents[1]
	else
		charging = null

	if(!charging || !internal_cell || panel_open)
		return
	var/obj/item/stock_parts/power_store/cell/weapon_cell = charging.get_cell()
	if(!weapon_cell || weapon_cell.charge >= weapon_cell.maxcharge)
		return

	var/backup_charge = min(weapon_cell.chargerate * seconds_per_tick, internal_cell.charge)
	var/actually_drained = internal_cell.use(backup_charge)
	if(!actually_drained)
		return PROCESS_KILL

	using_power = TRUE
	weapon_cell.give(backup_charge * recharge_coeff)
	charging.update_icon()
	update_appearance()

#define ALPHA_OVERLAYS 120

/obj/item/tactical_recharger/update_overlays()
	. = ..()

	if(length(contents))
		var/obj/item/I = contents[1]
		var/mutable_appearance/gun_overlay = mutable_appearance(I.icon, I.icon_state)
		var/matrix/M = matrix()
		M.Turn(-90)
		M.Translate(2, 0)
		gun_overlay.transform = M
		. += gun_overlay

	if(panel_open)
		. += mutable_appearance(icon, internal_cell ? "toz-panel-open" : "toz-panel-empty")
		return
	. += mutable_appearance(icon, "toz-overlay")

	if(charging)
		if(using_power)
			. += mutable_appearance(icon, "toz-charge")
			. += emissive_appearance(icon, "toz-charge", src, alpha = ALPHA_OVERLAYS)
		else
			. += mutable_appearance(icon, "toz-full")
			. += emissive_appearance(icon, "toz-full", src, alpha = ALPHA_OVERLAYS)

		var/weapon_cell_state
		var/obj/item/stock_parts/power_store/cell/weapon_cell = charging.get_cell()
		switch(round(weapon_cell.percent()))
			if(0 to 10)
				weapon_cell_state = "1"
			if(11 to 20)
				weapon_cell_state = "2"
			if(21 to 30)
				weapon_cell_state = "3"
			if(31 to 40)
				weapon_cell_state = "4"
			if(41 to 50)
				weapon_cell_state = "5"
			if(51 to 60)
				weapon_cell_state = "6"
			if(61 to 70)
				weapon_cell_state = "7"
			if(71 to 80)
				weapon_cell_state = "8"
			if(81 to 90)
				weapon_cell_state = "9"
			if(91 to 100)
				weapon_cell_state = "10"

		. += mutable_appearance(icon, "toz-w_lvl-[weapon_cell_state]")
		. += emissive_appearance(icon, "toz-w_lvl-[weapon_cell_state]", src, alpha = ALPHA_OVERLAYS)

	var/cell_state
	if(internal_cell)
		switch(round(internal_cell.percent()))
			if(15 to 28)
				cell_state = "1"
			if(29 to 42)
				cell_state = "2"
			if(43 to 56)
				cell_state = "3"
			if(57 to 70)
				cell_state = "4"
			if(71 to 84)
				cell_state = "5"
			if(85 to 100)
				cell_state = "6"
		. += mutable_appearance(icon, "toz-c_lvl-[cell_state]")
		. += emissive_appearance(icon, "toz-c_lvl-[cell_state]", src, alpha = ALPHA_OVERLAYS)

#undef ALPHA_OVERLAYS

// MARK: Types Rechargers
/obj/item/tactical_recharger/pulse/Initialize(mapload)
	. = ..()
	new /obj/item/gun/energy/pulse(src)
	update_appearance()
