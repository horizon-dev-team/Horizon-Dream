//The ammo stack object itself
/obj/item/ammo_box/magazine/ammo_stack
	name = "ammo stack"
	desc = "A stack of ammo."
	icon = '_horizon/icons/obj/items/ammo/ammo_stacks.dmi'
	icon_state = "c9mm"
	base_icon_state = "c9mm"
	item_flags = NO_PIXEL_RANDOM_DROP | NO_ANGLE_RANDOM_DROP
	appearance_flags = TILE_BOUND|LONG_GLIDE|PIXEL_SCALE
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	ammo_box_multiload = AMMO_BOX_MULTILOAD_NONE
	start_empty = TRUE
	custom_materials = null
	max_ammo = 12
	carry_weight = 0
	var/world_icon = '_horizon/icons/obj/items/ammo/casings_world.dmi'
	var/world_icon_state = "s-casing"

/obj/item/ammo_box/magazine/ammo_stack/Initialize(mapload)
	. = ..()
	if(world_icon)
		AddElement(/datum/element/world_icon, PROC_REF(update_icon_world))

/obj/item/ammo_box/magazine/ammo_stack/update_icon(updates)
	// Keep the inventory sprite while carried or stored; the world sprite comes back when the stack lands on a turf.
	if(world_icon_in_inventory(src))
		icon = initial(icon)
		cut_overlays()
	return ..()

/obj/item/ammo_box/magazine/ammo_stack/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count(TRUE)]"

/obj/item/ammo_box/magazine/ammo_stack/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	var/loc_before_del = loc
	while(LAZYLEN(stored_ammo))
		var/obj/item/ammo = get_round(FALSE)
		ammo.forceMove(loc_before_del)
		ammo.undo_messy()
		ammo.do_messy(duration = 2)
	check_for_del()

/obj/item/ammo_box/magazine/ammo_stack/attack_self(mob/user)
	. = ..()
	check_for_del()

/// Loaded stacks use actual casings, so their material totals are known from the start.
/obj/item/ammo_box/magazine/ammo_stack/top_off(load_type, starting = FALSE)
	if(!load_type)
		load_type = ammo_type
	while(length(stored_ammo) < max_ammo)
		var/obj/item/ammo_casing/casing = new load_type(src)
		if(!give_round(casing))
			qdel(casing)
			break
	update_appearance()

/obj/item/ammo_box/magazine/ammo_stack/is_compatible_round(obj/item/ammo_casing/new_round)
	if(!..())
		return FALSE
	var/obj/item/ammo_casing/stack_round = ammo_type
	return new_round.stack_type == initial(stack_round.stack_type)

/obj/item/ammo_box/magazine/ammo_stack/remove_from_stored_ammo(atom/movable/gone)
	stored_ammo -= gone
	// Rebuild instead of subtracting: removing the last casing must clear materials,
	// not pass zero-valued entries to set_custom_materials().
	var/list/materials = list()
	for(var/obj/item/ammo_casing/casing as anything in stored_ammo)
		for(var/material in casing.custom_materials)
			materials[material] += casing.custom_materials[material]
	set_custom_materials(materials)
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(check_for_del)), 0)

/obj/item/ammo_box/magazine/ammo_stack/Destroy(force)
	var/atom/dump_loc = drop_location()
	if(dump_loc)
		for(var/atom/movable/stray as anything in contents.Copy())
			stray.forceMove(dump_loc)
	return ..()

/obj/item/ammo_box/magazine/ammo_stack/proc/check_for_del()
	. = FALSE
	if((ammo_count(TRUE) <= 0) && !QDELETED(src))
		qdel(src)
		return TRUE

/obj/item/ammo_box/magazine/ammo_stack/proc/update_icon_world()
	cut_overlays()
	icon_state = ""
	for(var/casing in stored_ammo)
		var/obj/item/ammo_casing/casing_ref = casing
		var/state = "[world_icon_state][(ispath(casing) || casing_ref.loaded_projectile) ? "-live" : ""]"
		var/image/bullet = image(world_icon, src, state)
		bullet.appearance_flags ^= PIXEL_SCALE
		bullet.pixel_x = rand(-12, 12)
		bullet.pixel_y = rand(-12, 12)
		bullet.transform = bullet.transform.Turn(round(45 * rand(0, 32) / 2))
		add_overlay(bullet)
	return UPDATE_ICON_STATE | UPDATE_OVERLAYS

/// Clicking two matching casings together merges them into an ammo stack.
/obj/item/ammo_casing/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	. = ..()
	if(!istype(attacking_item, /obj/item/ammo_casing))
		return
	var/obj/item/ammo_casing/ammo_casing = attacking_item
	if(!ammo_casing.stack_type)
		to_chat(user, span_warning("[ammo_casing] can't be stacked."))
		return
	if(!stack_type)
		to_chat(user, span_warning("[src] can't be stacked."))
		return
	if(caliber != ammo_casing.caliber)
		to_chat(user, span_warning("I can't stack different calibers."))
		return
	if(stack_type != ammo_casing.stack_type)
		to_chat(user, span_warning("I can't stack [ammo_casing] with [src]."))
		return
	if(!loaded_projectile || !ammo_casing.loaded_projectile)
		to_chat(user, span_warning("I can't stack empty casings."))
		return
	var/obj/item/ammo_box/magazine/new_stack = new stack_type(drop_location())
	user.transferItemToLoc(src, new_stack, silent = TRUE)
	new_stack.give_round(src)
	user.transferItemToLoc(ammo_casing, new_stack, silent = TRUE)
	new_stack.give_round(ammo_casing)
	user.put_in_hands(new_stack)
	new_stack.update_appearance()
	to_chat(user, span_notice("[src] has been stacked with [ammo_casing]."))

// MARK: stack types
/obj/item/ammo_box/magazine/ammo_stack/c38
	name = "38 rounds"
	icon_state = "c38-1"
	base_icon_state = "c38"
	world_icon_state = "s-casing"
	caliber = CALIBER_38
	ammo_type = /obj/item/ammo_casing/c38

/obj/item/ammo_box/magazine/ammo_stack/c38/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c38/pluspee
	name = "38 +P rounds"
	icon_state = "c38-1"
	base_icon_state = "c38"
	world_icon_state = "s-casing"
	caliber = CALIBER_38
	ammo_type = /obj/item/ammo_casing/c38/pluspee

/obj/item/ammo_box/magazine/ammo_stack/c38/pluspee/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c357
	name = ".357 rounds"
	icon_state = "c357-1"
	base_icon_state = "c357"
	world_icon_state = "sb-casing"
	caliber = CALIBER_357_38
	ammo_type = /obj/item/ammo_casing/c357

/obj/item/ammo_box/magazine/ammo_stack/a357
	name = ".357 magnum rounds"
	icon_state = "c357-1"
	base_icon_state = "c357"
	world_icon_state = "sb-casing"
	caliber = CALIBER_357
	ammo_type = /obj/item/ammo_casing/a357

/obj/item/ammo_box/magazine/ammo_stack/a357/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/a500
	name = ".500 magnum rounds"
	icon_state = "c44-1"
	base_icon_state = "c44"
	world_icon_state = "sb-casing"
	caliber = CALIBER_500
	ammo_type = /obj/item/ammo_casing/a500

/obj/item/ammo_box/magazine/ammo_stack/a500/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c22lr
	name = "22lr rounds"
	icon_state = "c22lr-1"
	base_icon_state = "c22lr"
	world_icon_state = "s-casing"
	caliber = CALIBER_22LR
	ammo_type = /obj/item/ammo_casing/c22lr

/obj/item/ammo_box/magazine/ammo_stack/c22lr/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c380
	name = "380 ACP rounds"
	icon_state = "c22lr-1"
	base_icon_state = "c22lr"
	world_icon_state = "s-casing"
	caliber = CALIBER_380
	ammo_type = /obj/item/ammo_casing/c380

/obj/item/ammo_box/magazine/ammo_stack/c380/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c9mm
	name = "9mm rounds"
	icon_state = "c9mm-1"
	base_icon_state = "c9mm"
	world_icon_state = "s-casing"
	caliber = CALIBER_9MM
	ammo_type = /obj/item/ammo_casing/c9mm

/obj/item/ammo_box/magazine/ammo_stack/c9mm/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/c45
	name = "45 rounds"
	icon_state = "c45-1"
	base_icon_state = "c45"
	world_icon_state = "sb-casing"
	caliber = CALIBER_45
	ammo_type = /obj/item/ammo_casing/c45

/obj/item/ammo_box/magazine/ammo_stack/c45/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/a223
	name = "5.56 rounds"
	icon_state = "c545-1"
	base_icon_state = "c545"
	world_icon_state = "545-casing"
	caliber = CALIBER_A223
	max_ammo = 8
	ammo_type = /obj/item/ammo_casing/a223

/obj/item/ammo_box/magazine/ammo_stack/aniquilador
	name = "50 LE rounds"
	icon_state = "c45-1"
	base_icon_state = "c45"
	world_icon_state = "sb-casing"
	caliber = CALIBER_ANIQUILADOR
	ammo_type = /obj/item/ammo_casing/aniquilador

/obj/item/ammo_box/magazine/ammo_stack/aniquilador/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/a762
	name = "7.62 rounds"
	icon_state = "c762-1"
	base_icon_state = "c762"
	world_icon_state = "762-casing"
	caliber = CALIBER_A762
	max_ammo = 5
	ammo_type = /obj/item/ammo_casing/a762

/obj/item/ammo_box/magazine/ammo_stack/a762/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/a556
	name = "5.56 rounds"
	icon_state = "c545-1"
	base_icon_state = "c545"
	world_icon_state = "545-casing"
	caliber = CALIBER_A556
	max_ammo = 8
	ammo_type = /obj/item/ammo_casing/a556

/obj/item/ammo_box/magazine/ammo_stack/a556/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/a545
	name = "5.45 rounds"
	icon_state = "c545-1"
	base_icon_state = "c545"
	world_icon_state = "545-casing"
	caliber = CALIBER_545
	max_ammo = 8
	ammo_type = /obj/item/ammo_casing/a545

/obj/item/ammo_box/magazine/ammo_stack/a545/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/a49234g11
	name = "4.92x34 rounds"
	icon_state = "c9mm-1"
	base_icon_state = "c9mm"
	world_icon_state = "s-casing"
	caliber = CALIBER_UNCONVENTIONAL
	ammo_type = /obj/item/ammo_casing/a49234g11

/obj/item/ammo_box/magazine/ammo_stack/a49234g11/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/a556steyr
	name = "5.56x45mm SCF rounds"
	icon_state = "flechette-1"
	base_icon_state = "flechette"
	world_icon_state = "flechette"
	caliber = CALIBER_FLECHETTE
	max_ammo = 5
	ammo_type = /obj/item/ammo_casing/a556steyr

/obj/item/ammo_box/magazine/ammo_stack/a556steyr/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/a762svd
	name = "7.62x54R rounds"
	icon_state = "c762-1"
	base_icon_state = "c762"
	world_icon_state = "762-casing"
	caliber = CALIBER_54R
	max_ammo = 8
	ammo_type = /obj/item/ammo_casing/a762svd

/obj/item/ammo_box/magazine/ammo_stack/a762svd/loaded
	start_empty = FALSE

/* [DISABLED] no gun uses the 7.62x51 / Arma marksman rifle set yet; re-enable together with the gun.
/obj/item/ammo_box/magazine/ammo_stack/a762x51
	name = "7.62x51 rounds"
	icon_state = "c762-1"
	base_icon_state = "c762"
	world_icon_state = "762-casing"
	caliber = CALIBER_51
	max_ammo = 8
	ammo_type = /obj/item/ammo_casing/a762x51

/obj/item/ammo_box/magazine/ammo_stack/a762x51/loaded
	start_empty = FALSE
*/

/obj/item/ammo_box/magazine/ammo_stack/a276
	name = "276 Federson rounds"
	icon_state = "c762-1"
	base_icon_state = "c762"
	world_icon_state = "762-casing"
	caliber = CALIBER_276
	max_ammo = 8
	ammo_type = /obj/item/ammo_casing/a276

/obj/item/ammo_box/magazine/ammo_stack/a276/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/shotgun
	name = "12 gauge buckshot"
	icon_state = "12gauge-1"
	base_icon_state = "12gauge"
	world_icon_state = "12gauge"
	max_ammo = 5
	caliber = CALIBER_SHOTGUN
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/ammo_stack/shotgun/loaded
	start_empty = FALSE

/*
/obj/item/ammo_box/magazine/ammo_stack/shotgun/
	name = "10 gauge buckshot"
	icon_state = "10gauge-1"
	base_icon_state = "10gauge"
	world_icon_state = "10gshell"

/obj/item/ammo_box/magazine/ammo_stack/shotgun/bolas/loaded
	start_empty = FALSE
*/


/obj/item/ammo_box/magazine/ammo_stack/shotgun/flechette
	name = "12 gauge flechette shells"
	desc = "A stack of 12 gauge flechette shells."
	icon_state = "flechette-1"
	base_icon_state = "flechette"
	world_icon_state = "flechette"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/ammo_stack/shotgun/pulverizer
	name = "12 gauge buckshot"
	icon_state = "12gauge-stun-1"
	base_icon_state = "12gauge-stun"
	world_icon_state = "12shells-stun"
	ammo_type = /obj/item/ammo_casing/shotgun/pulverizer

/obj/item/ammo_box/magazine/ammo_stack/shotgun/incendiary
	name = "12 gauge buckshot"
	icon_state = "12gauge-hell-1"
	base_icon_state = "12gauge-hell"
	world_icon_state = "12shells-hell"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/magazine/ammo_stack/shotgun/dragonsbreath
	name = "12 gauge dragonsbreath shells"
	icon_state = "12gauge-dragon-1"
	base_icon_state = "12gauge-dragon"
	world_icon_state = "12shells-dragon"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/ammo_stack/shotgun/flechette/loaded
	start_empty = FALSE

/obj/item/ammo_box/magazine/ammo_stack/shotgun/bolas
	name = "4 gauge buckshot"
	icon_state = "8gauge-1"
	base_icon_state = "8gauge"
	world_icon_state = "8gshell"
	caliber = CALIBER_KS23
	ammo_type = /obj/item/ammo_casing/shotgun/bolas/buckshot

/obj/item/ammo_box/magazine/ammo_stack/shotgun/bolas/loaded
	start_empty = FALSE
