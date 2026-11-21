// Debug armory: a free supply console that drops horizon guns (inside gun cases), magazines
// and ammo in a supply pod next to itself. Meant for debugging / testing, so nothing costs money.
//
// It reuses the stock "Cargo" tgui interface (catalogue + cart), so no new frontend is needed.
// The catalogue is generated from the type tree: every gun with `/hd_gun` in its path gets a case
// pack, every magazine those guns spawn with gets a pack, plus the loaded ammo stacks and ammo boxes.
// New horizon guns show up on their own.

/// How many items fit in the cart of the debug armory console, in total.
#define HORIZON_ARMORY_MAX_CART 10

// MARK: Gun case
/datum/storage/toolbox/guncase/horizon_debug
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = WEIGHT_CLASS_GIGANTIC + 2

/// A gun case that holds exactly the gun it was told to load, without the stock magazines.
/obj/item/storage/toolbox/guncase/horizon_debug
	name = "debug gun case"
	desc = "A weapon's case from the debug armory."
	storage_type = /datum/storage/toolbox/guncase/horizon_debug
	weapon_to_spawn = null
	extra_to_spawn = null

/// Puts a new gun of the given type into the case and names the case after it.
/obj/item/storage/toolbox/guncase/horizon_debug/proc/load_gun(gun_type)
	var/obj/item/gun/new_gun = new gun_type(src)
	name = "[new_gun.name] case"

// MARK: Supply packs
/// Base for the debug armory packs. ORDER_SPECIAL keeps them out of every regular cargo console,
/// the debug armory console picks them out by type.
/datum/supply_pack/horizon_debug
	name = "Debug Armory Pack"
	cost = 0
	order_flags = ORDER_SPECIAL
	test_ignored = TRUE
	crate_name = "debug armory crate"
	/// Names already given to generated packs. The cart is keyed by pack name, so they have to be unique.
	var/static/list/used_names = list()

/// Returns the name unchanged, or with a number added if another debug pack already took it.
/datum/supply_pack/horizon_debug/proc/unique_name(base_name)
	var/new_name = base_name
	var/suffix = 2
	while(new_name in used_names)
		new_name = "[base_name] ([suffix++])"
	used_names += new_name
	return new_name

/// A gun delivered inside a gun case.
/datum/supply_pack/horizon_debug/gun_case
	group = "Debug: Weapons"
	/// The gun this pack delivers.
	var/gun_type

/datum/supply_pack/horizon_debug/gun_case/fill(obj/container)
	var/obj/item/storage/toolbox/guncase/horizon_debug/gun_case = new(container)
	gun_case.load_gun(gun_type)

/// Magazines, loaded ammo stacks and ammo boxes. Spawned loose in the crate.
/datum/supply_pack/horizon_debug/ammo
	group = "Debug: Ammo"

// MARK: Generators
// SSshuttle calls generate_supply_packs() on every pack type and registers what it returns
// instead of the generator itself (generators have no `contains`).

/datum/supply_pack/horizon_debug/gun_generator/generate_supply_packs()
	var/list/packs = list()
	for(var/obj/item/gun/gun_type as anything in subtypesof(/obj/item/gun))
		if(!findtext("[gun_type]", "/hd_gun") || initial(gun_type.abstract_type) == gun_type)
			continue
		var/datum/supply_pack/horizon_debug/gun_case/pack = new
		pack.id = "horizon_debug_gun_[gun_type]"
		pack.name = unique_name("[initial(gun_type.name)] case")
		pack.desc = "A case with the [initial(gun_type.name)]. Magazines are ordered separately."
		pack.gun_type = gun_type
		// only for the catalogue preview, fill() builds the case itself
		pack.contains = list()
		pack.contains[gun_type] = 1
		packs += pack
	return packs

/datum/supply_pack/horizon_debug/magazine_generator/generate_supply_packs()
	var/list/packs = list()
	var/list/seen_types = list()
	for(var/obj/item/gun/ballistic/gun_type as anything in subtypesof(/obj/item/gun/ballistic))
		if(!findtext("[gun_type]", "/hd_gun"))
			continue
		var/obj/item/ammo_box/magazine/mag_type = initial(gun_type.spawn_magazine_type)
		if(!mag_type || ispath(mag_type, /obj/item/ammo_box/magazine/internal) || (mag_type in seen_types))
			continue
		seen_types += mag_type
		var/datum/supply_pack/horizon_debug/ammo/pack = new
		pack.id = "horizon_debug_mag_[mag_type]"
		pack.name = unique_name("[initial(mag_type.name)] x3")
		pack.desc = "Three loaded [initial(mag_type.name)]s."
		pack.contains = list()
		pack.contains[mag_type] = 3
		packs += pack
	return packs

/datum/supply_pack/horizon_debug/ammo_generator/generate_supply_packs()
	var/list/packs = list()
	// Full ammo stacks (the ones that aren't `start_empty`), used by guns with internal magazines.
	for(var/obj/item/ammo_box/magazine/ammo_stack/stack_type as anything in subtypesof(/obj/item/ammo_box/magazine/ammo_stack))
		if(initial(stack_type.start_empty))
			continue
		var/datum/supply_pack/horizon_debug/ammo/pack = new
		pack.id = "horizon_debug_stack_[stack_type]"
		pack.name = unique_name("[initial(stack_type.name)] (full stack) x2")
		pack.desc = "Two full stacks of loose rounds."
		pack.contains = list()
		pack.contains[stack_type] = 2
		packs += pack
	// Horizon ammo boxes.
	for(var/obj/item/ammo_box/box_type as anything in list(
		/obj/item/ammo_box/a762svd,
		/obj/item/ammo_box/a762svd/ap,
		/obj/item/ammo_box/a54539abyss,
		/obj/item/ammo_box/a54539abyss/ap,
		/obj/item/ammo_box/a556winter,
	))
		var/datum/supply_pack/horizon_debug/ammo/pack = new
		pack.id = "horizon_debug_box_[box_type]"
		pack.name = unique_name(initial(box_type.name))
		pack.desc = "A box of loose rounds."
		pack.contains = list()
		pack.contains[box_type] = 1
		packs += pack
	return packs

// MARK: Console
/obj/machinery/computer/horizon_armory
	name = "debug armory console"
	desc = "A debug supply console. Everything is free: pick up to ten items and a supply pod drops them next to the console."
	icon_state = MAP_SWITCH("computer", "/obj/machinery/computer/horizon_armory")
	icon_screen = "supply_express"
	circuit = null
	light_color = COLOR_BRIGHT_ORANGE
	/// The pod the orders arrive in.
	var/pod_type = /obj/structure/closet/supplypod
	/// Pack -> amount of it in the cart.
	var/list/cart = list()
	/// Short cooldown so the console can't be spammed with pods.
	COOLDOWN_DECLARE(order_cooldown)

/obj/machinery/computer/horizon_armory/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cargo", name)
		ui.open()

/obj/machinery/computer/horizon_armory/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/json/cargo_catalogue))

/obj/machinery/computer/horizon_armory/ui_static_data(mob/user)
	var/list/data = list()
	data["max_order"] = HORIZON_ARMORY_MAX_CART
	var/datum/asset/json/cargo_catalogue/catalogue = get_asset_datum(/datum/asset/json/cargo_catalogue)
	var/list/packs_by_group = get_packs_data_by_group(catalogue)
	if(catalogue.needs_build)
		packs_by_group = get_packs_data_by_group(catalogue.ensure_ready())
	var/list/groups
	for(var/group in packs_by_group)
		var/list/available_packs = packs_by_group[group]
		if(!length(available_packs))
			continue
		LAZYSET(groups, group, available_packs)
	data["catalogue"] = catalogue.get_window_data(user, groups, show_contraband = TRUE)
	data["displayed_currency_full_name"] = " [MONEY_NAME]"
	data["displayed_currency_name"] = " [MONEY_SYMBOL]"
	return data

/// Returns the debug packs by group, as index/price pairs into the catalogue (same format as the cargo console).
/obj/machinery/computer/horizon_armory/proc/get_packs_data_by_group(datum/asset/json/cargo_catalogue/catalogue)
	var/list/packs_by_group = list()
	for(var/pack_id, pack_data in SSshuttle.supply_packs)
		if(!istype(pack_data, /datum/supply_pack/horizon_debug))
			continue
		var/datum/supply_pack/pack = pack_data
		var/index = catalogue.pack_indices[pack]
		if(isnull(index))
			catalogue.needs_build = TRUE
			continue
		var/list/packs = packs_by_group[pack.group]
		if(isnull(packs))
			packs = list()
			packs_by_group[pack.group] = packs
		packs += list(index, 0)
	return packs_by_group

/obj/machinery/computer/horizon_armory/ui_data(mob/user)
	var/list/data = list()
	// The stock Cargo interface expects all of these; most are fixed because there is no shuttle or budget here.
	data["department"] = "Debug Armory"
	data["location"] = "Local railgun"
	data["points"] = 0
	data["grocery"] = 0
	data["away"] = TRUE
	data["self_paid"] = FALSE
	data["goody_order_cost_modifier"] = 1
	data["private_order_cost_modifier"] = 1
	data["docked"] = TRUE
	data["loan"] = FALSE
	data["loan_dispatched"] = FALSE
	data["can_send"] = TRUE
	data["can_approve_requests"] = TRUE
	data["requestonly"] = FALSE
	data["message"] = "Everything is free. Cart: [get_cart_total()]/[HORIZON_ARMORY_MAX_CART]. The pod lands next to the console."
	data["requests"] = list()
	data["cart"] = list()
	var/index = 0
	for(var/datum/supply_pack/pack as anything in cart)
		index++
		data["cart"] += list(list(
			"cost_type" = MONEY_SYMBOL,
			"object" = pack.name,
			"cost" = 0,
			"id" = "[index]",
			"amount" = cart[pack],
			"orderer" = "Debug",
			"paid" = FALSE,
			"dep_order" = FALSE,
			"can_be_cancelled" = TRUE,
		))
	return data

/obj/machinery/computer/horizon_armory/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("add")
			var/datum/supply_pack/pack = SSshuttle.supply_packs[params["id"]]
			if(!istype(pack, /datum/supply_pack/horizon_debug))
				return
			add_to_cart(pack, 1)
			return TRUE
		if("add_by_name")
			var/datum/supply_pack/pack = pack_by_name(params["order_name"])
			if(!pack)
				return
			add_to_cart(pack, 1)
			return TRUE
		if("remove")
			var/datum/supply_pack/pack = pack_by_name(params["order_name"])
			if(!pack || !cart[pack])
				return
			cart[pack]--
			if(cart[pack] <= 0)
				cart -= pack
			return TRUE
		if("modify")
			var/datum/supply_pack/pack = pack_by_name(params["order_name"])
			if(!pack)
				return
			var/amount = text2num(params["amount"])
			if(isnull(amount))
				return
			var/space_left = HORIZON_ARMORY_MAX_CART - (get_cart_total() - (cart[pack] || 0))
			amount = clamp(round(amount), 0, space_left)
			if(amount <= 0)
				cart -= pack
			else
				cart[pack] = amount
			return TRUE
		if("clear")
			cart.Cut()
			return TRUE
		if("send")
			launch_order(ui.user)
			return TRUE

/// How many items are in the cart in total.
/obj/machinery/computer/horizon_armory/proc/get_cart_total()
	. = 0
	for(var/datum/supply_pack/pack as anything in cart)
		. += cart[pack]

/// Finds a debug pack by the name shown in the UI.
/obj/machinery/computer/horizon_armory/proc/pack_by_name(order_name)
	for(var/pack_id, pack_data in SSshuttle.supply_packs)
		if(!istype(pack_data, /datum/supply_pack/horizon_debug))
			continue
		var/datum/supply_pack/pack = pack_data
		if(pack.name == order_name)
			return pack
	return null

/// Adds up to `amount` of the pack to the cart, limited by the cart size. Returns whether anything was added.
/obj/machinery/computer/horizon_armory/proc/add_to_cart(datum/supply_pack/pack, amount = 1)
	amount = min(amount, HORIZON_ARMORY_MAX_CART - get_cart_total())
	if(amount <= 0)
		say("The cart is full (maximum [HORIZON_ARMORY_MAX_CART] items).")
		return FALSE
	cart[pack] += amount
	return TRUE

/// A clear floor tile as close to the console as possible (within three tiles), or null.
/obj/machinery/computer/horizon_armory/proc/find_landing_turf()
	for(var/radius in 1 to 3)
		var/list/candidates = list()
		for(var/turf/open/floor/floor_turf in orange(radius, src))
			if(get_dist(src, floor_turf) != radius || floor_turf.is_blocked_turf())
				continue
			candidates += floor_turf
		if(length(candidates))
			return pick(candidates)
	return null

/// Packs everything in the cart into one supply pod and drops it next to the console.
/obj/machinery/computer/horizon_armory/proc/launch_order(mob/user)
	if(!length(cart))
		say("The cart is empty.")
		return
	if(!COOLDOWN_FINISHED(src, order_cooldown))
		say("Railgun recalibrating. Stand by.")
		return
	var/turf/landing_turf = find_landing_turf()
	if(!landing_turf)
		say("No clear landing zone next to the console.")
		return
	var/obj/structure/closet/supplypod/pod = new pod_type()
	for(var/datum/supply_pack/pack as anything in cart)
		for(var/i in 1 to cart[pack])
			var/datum/supply_order/order = new(pack = pack, orderer = user.real_name, orderer_rank = "Debug", orderer_ckey = user.ckey, manifest_can_fail = FALSE)
			order.generate(pod)
			qdel(order)
	new /obj/effect/pod_landingzone(landing_turf, pod)
	cart.Cut()
	COOLDOWN_START(src, order_cooldown, 5 SECONDS)
	say("Order confirmed. Supply pod inbound.")

#undef HORIZON_ARMORY_MAX_CART
