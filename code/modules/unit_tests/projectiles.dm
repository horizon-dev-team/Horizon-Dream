///Tests all projectiles that none of them are phasing.
/datum/unit_test/projectile_movetypes

/datum/unit_test/projectile_movetypes/Run()
	for(var/obj/projectile/projectile as anything in typesof(/obj/projectile))
		if(initial(projectile.movement_type) & PHASING)
			TEST_FAIL("[projectile] has default movement type PHASING. Piercing projectiles should be done using the projectile piercing system, not movement_types!")

///Shoots a victim with a gun to ensure the gun properly loads and the victim take the correct amount of damage.
/datum/unit_test/gun_go_bang

/datum/unit_test/gun_go_bang/Run()
	// test is for a ballistic gun that starts loaded + chambered
	var/obj/item/gun/ballistic/test_gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/gunner = allocate(/mob/living/carbon/human/consistent)
	ADD_TRAIT(victim, TRAIT_PIERCEIMMUNE, INNATE_TRAIT) // So the human isn't randomly affected by shrapnel
	test_gun.never_misfire = TRUE //just in case

	var/obj/item/ammo_casing/loaded_casing = test_gun.chambered
	TEST_ASSERT(loaded_casing, "Gun started without round chambered, should be loaded")
	var/obj/projectile/loaded_bullet = loaded_casing.loaded_projectile
	TEST_ASSERT(loaded_bullet, "Ammo casing has no loaded bullet")

	gunner.put_in_hands(test_gun, forced=TRUE)
	gunner.set_combat_mode(FALSE) // just to make sure we know we're not trying to pistol-whip them
	var/expected_damage = loaded_bullet.damage
	loaded_bullet.def_zone = BODY_ZONE_CHEST
	var/did_we_shoot = test_gun.melee_attack_chain(gunner, victim)
	TEST_ASSERT(did_we_shoot, "Gun does not appeared to have successfully fired.")
	TEST_ASSERT_EQUAL(victim.get_brute_loss(), expected_damage, "Victim took incorrect amount of damage, expected [expected_damage], got [victim.get_brute_loss()].")

	var/obj/item/bodypart/expected_part = victim.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(expected_part.brute_dam, expected_damage, "Intended bodypart took incorrect amount of damage, either it hit another bodypart or armor was incorrectly applied. Expected [expected_damage], got [expected_part.brute_dam].")

// [HORIZON-ADD] GunRework
/datum/unit_test/gun_attachment_lifecycle/Run()
	var/obj/item/gun/ballistic/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/attachment/silencer/silencer = allocate(/obj/item/attachment/silencer)
	var/datum/component/attachment_mount/mount = gun.GetComponent(/datum/component/attachment_mount)
	var/original_weight = gun.w_class
	user.put_in_hands(silencer, forced = TRUE)
	TEST_ASSERT_EQUAL(gun.item_interaction(user, silencer, list()), ITEM_INTERACT_SUCCESS, "Silencer was not installed through item_interaction")
	TEST_ASSERT_EQUAL(silencer.loc, gun, "Installed silencer is not inside the gun")
	TEST_ASSERT(gun.suppressed, "Installed silencer did not suppress the gun")
	TEST_ASSERT(!gun.can_muzzle_flash, "Installed silencer left muzzle flash enabled")
	TEST_ASSERT_EQUAL(gun.w_class, original_weight + silencer.w_class, "Silencer size cost was not applied")
	TEST_ASSERT(mount.try_detach(silencer.get_attachment_component(), user), "Silencer could not be detached")
	TEST_ASSERT_EQUAL(gun.suppressed, SUPPRESSED_NONE, "Removed silencer left suppression enabled")
	TEST_ASSERT(gun.can_muzzle_flash, "Removed silencer did not restore muzzle flash")
	TEST_ASSERT_EQUAL(gun.w_class, original_weight, "Removed silencer left a size modifier")

	// A gun whose flash was already disabled must stay that way after removal.
	gun.can_muzzle_flash = FALSE
	TEST_ASSERT(mount.try_attach(silencer), "Silencer could not be reattached")
	silencer.forceMove(user.loc)
	TEST_ASSERT_NULL(silencer.get_attachment_component().mount, "Moved silencer kept its mount")
	TEST_ASSERT_EQUAL(length(mount.installed), 0, "Moved silencer left the muzzle slot occupied")
	TEST_ASSERT_EQUAL(gun.suppressed, SUPPRESSED_NONE, "Moved silencer left suppression enabled")
	TEST_ASSERT(!gun.can_muzzle_flash, "Removed silencer overwrote the pre-install flash setting")
	TEST_ASSERT_EQUAL(gun.w_class, original_weight, "Moved silencer left a size modifier")
	gun.sawn_off = TRUE
	TEST_ASSERT(!mount.try_attach(silencer), "A shortened muzzle accepted a silencer")

/datum/unit_test/gun_drag_unload/Run()
	var/obj/item/gun/ballistic/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/ammo_box/magazine/magazine = gun.magazine
	gun.forceMove(user.loc)
	// Invoke the protected drag handler without requiring a connected client.
	call(gun, TYPE_PROC_REF(/obj/item/gun/ballistic, mouse_drop_dragged))(user, user)
	TEST_ASSERT_NULL(gun.magazine, "Dragging a floor gun onto the user did not unload it")
	TEST_ASSERT(user.is_holding(magazine), "Floor gun's magazine did not reach the user's hands")

/datum/unit_test/gun_attachment_offsets/Run()
	var/obj/item/gun/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	var/datum/component/attachment_mount/mount = gun.GetComponent(/datum/component/attachment_mount)
	TEST_ASSERT(mount.slot_offsets != gun.slot_offsets, "Mount shares the gun's slot offset list")
	TEST_ASSERT_EQUAL(mount.slot_offsets[ATTACHMENT_SLOT_RAIL], gun.slot_offsets[ATTACHMENT_SLOT_RAIL], "Muzzle anchor replaced the rail anchor")
	var/list/muzzle_offset = mount.slot_offsets[ATTACHMENT_SLOT_MUZZLE]
	TEST_ASSERT_EQUAL(muzzle_offset["x"], 25, "Pistol muzzle X anchor is incorrect")
	TEST_ASSERT_EQUAL(muzzle_offset["y"], 19, "Pistol muzzle Y anchor is incorrect")
	var/obj/item/gun/other_gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	mount.slot_offsets[ATTACHMENT_SLOT_MUZZLE] = list("x" = 0, "y" = 0)
	var/datum/component/attachment_mount/other_mount = other_gun.GetComponent(/datum/component/attachment_mount)
	TEST_ASSERT_EQUAL(other_mount.slot_offsets[ATTACHMENT_SLOT_MUZZLE]["x"], 25, "Changing one mount changed another gun")

/// Incremental configuration retains inherited slots, disabled capacities and whitelists.
/datum/unit_test/gun_attachment_slot_configuration/Run()
	var/obj/item/gun/gun = allocate(/obj/item/gun/ballistic/automatic/c20r)
	var/datum/component/attachment_mount/mount = gun.GetComponent(/datum/component/attachment_mount)
	TEST_ASSERT_EQUAL(mount.slot_offsets[ATTACHMENT_SLOT_RAIL]["x"], 17, "Muzzle configuration replaced the inherited rail")
	TEST_ASSERT_EQUAL(mount.slot_offsets[ATTACHMENT_SLOT_MUZZLE]["x"], 25, "C20r lost its muzzle anchor")
	TEST_ASSERT_EQUAL(mount.slot_offsets[ATTACHMENT_SLOT_BAYONET]["x"], 26, "Muzzle configuration replaced the bayonet anchor")
	TEST_ASSERT_EQUAL(mount.slot_capacity[ATTACHMENT_SLOT_BAYONET], 1, "Bayonet slot lost its capacity")
	TEST_ASSERT(/obj/item/knife/combat in mount.valid_type_list, "Bayonet configuration lost knife compatibility")
	gun.slot_available[ATTACHMENT_SLOT_SCOPE] = 0
	gun.set_attachment_slot(ATTACHMENT_SLOT_SCOPE, 0, 0)
	TEST_ASSERT_EQUAL(gun.slot_available[ATTACHMENT_SLOT_SCOPE], 0, "Setting an anchor enabled a disabled slot")
	TEST_ASSERT_EQUAL(gun.slot_offsets[ATTACHMENT_SLOT_SCOPE]["x"], 0, "Zero coordinate was discarded")
	gun.set_attachment_slot(ATTACHMENT_SLOT_GRIP, 3, 4, capacity = 2)
	TEST_ASSERT_EQUAL(gun.slot_available[ATTACHMENT_SLOT_GRIP], 2, "Explicit slot capacity was not applied")
	TEST_ASSERT_NULL(mount.slot_offsets[ATTACHMENT_SLOT_SCOPE], "Startup configuration mutated an existing mount snapshot")
	var/obj/item/gun/child = allocate(/obj/item/gun/ballistic/automatic/pistol/clandestine)
	var/datum/component/attachment_mount/child_mount = child.GetComponent(/datum/component/attachment_mount)
	TEST_ASSERT_EQUAL(child_mount.slot_offsets[ATTACHMENT_SLOT_MUZZLE]["x"], 26, "Child did not override its parent's muzzle anchor")
	TEST_ASSERT_EQUAL(child_mount.slot_offsets[ATTACHMENT_SLOT_RAIL]["x"], 17, "Child lost an unrelated inherited slot")

/// Test-only gun starts without any attachment configuration.
/obj/item/gun/attachment_null_test
	pinless = TRUE
	pin = null
	slot_offsets = null
	slot_available = null
	valid_attachments = null

/// Absent gun configuration produces empty lists rather than accepting arbitrary types.
/datum/unit_test/gun_attachment_null_configuration/Run()
	var/obj/item/gun/gun = allocate(/obj/item/gun/attachment_null_test)
	TEST_ASSERT(islist(gun.slot_offsets) && !length(gun.slot_offsets), "Missing gun offsets did not create an empty list")
	TEST_ASSERT(islist(gun.slot_available) && !length(gun.slot_available), "Missing gun capacities did not create an empty list")
	TEST_ASSERT(islist(gun.valid_attachments) && !length(gun.valid_attachments), "Missing gun whitelist did not create an empty list")
	var/datum/component/attachment_mount/mount = gun.GetComponent(/datum/component/attachment_mount)
	TEST_ASSERT(islist(mount.slot_capacity) && !length(mount.slot_capacity), "Missing capacities did not create an empty list")
	TEST_ASSERT(islist(mount.slot_offsets) && !length(mount.slot_offsets), "Missing offsets did not create an empty list")
	TEST_ASSERT(islist(mount.valid_type_list) && !length(mount.valid_type_list), "Missing whitelist did not create an empty list")
	TEST_ASSERT(islist(mount.valid_types) && !length(mount.valid_types), "Missing whitelist did not create an empty typecache")
	var/obj/item/attachment/silencer/silencer = allocate(/obj/item/attachment/silencer)
	TEST_ASSERT(!mount.try_attach(silencer), "An unconfigured mount accepted an attachment")

/// A full cylinder must report exactly its capacity, not capacity + the chambered round.
/datum/unit_test/revolver_ammo_count/Run()
	for(var/gun_type in list(/obj/item/gun/ballistic/revolver, /obj/item/gun/ballistic/revolver/hd_gun/gado))
		var/obj/item/gun/ballistic/revolver/revolver = allocate(gun_type)
		var/obj/item/ammo_box/magazine/internal/cylinder/cylinder = revolver.magazine
		TEST_ASSERT_EQUAL(revolver.get_ammo(TRUE, TRUE), cylinder.max_ammo, "[gun_type] reported more rounds than its [revolver.cylinder_wording] holds")

/// The b2021's quiet report must come from its attachment, not from a hardcoded gun var.
/datum/unit_test/integrated_silencer/Run()
	var/obj/item/gun/ballistic/gun = allocate(/obj/item/gun/ballistic/shotgun/automatic/hd_gun/b2021)
	var/datum/component/attachment_mount/mount = gun.GetComponent(/datum/component/attachment_mount)
	var/original_weight = gun.w_class
	var/list/muzzle_attachments = mount.get_attachments_in_slot(ATTACHMENT_SLOT_MUZZLE)
	TEST_ASSERT_EQUAL(length(muzzle_attachments), 1, "The b2021 did not spawn with its integrated silencer")
	TEST_ASSERT(gun.suppressed, "The integrated silencer did not suppress the gun")
	TEST_ASSERT_EQUAL(gun.w_class, original_weight, "The integrated silencer changed the gun's size")
	TEST_ASSERT(!mount.has_removable_attachment(ATTACH_REMOVABLE_HAND), "The integrated silencer can be pulled off by hand")
	TEST_ASSERT(!mount.has_removable_attachment(ATTACH_REMOVABLE_TOOL), "The integrated silencer can be pried off")
	var/datum/component/gun_attachment/silencer = muzzle_attachments[1]
	mount.try_detach(silencer, null)
	TEST_ASSERT_EQUAL(gun.suppressed, SUPPRESSED_NONE, "Removing the integrated silencer left the gun suppressed")

/datum/unit_test/revolver_open_cylinder/Run()
	var/obj/item/gun/ballistic/revolver/gun = allocate(/obj/item/gun/ballistic/revolver)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	user.put_in_hands(gun, forced = TRUE)
	TEST_ASSERT_EQUAL(gun.bolt_type, BOLT_TYPE_BREAK_ACTION, "Ordinary revolver has no opening cylinder")
	gun.attack_self(user)
	TEST_ASSERT(gun.cylinder_open, "Self-use did not open cylinder")
	TEST_ASSERT_NULL(gun.chambered, "Open cylinder kept a chambered round")
	TEST_ASSERT(!gun.can_shoot(), "Open cylinder can fire")
	gun.do_spin()
	TEST_ASSERT_NULL(gun.chambered, "Spinning an open cylinder readied a round")
	// Direct/delayed calls must handle an absent chamber without reading null.casing_pressure.
	TEST_ASSERT(!gun.process_fire(user, user), "Open cylinder fired through process_fire")
	gun.attack_hand(user)
	TEST_ASSERT_EQUAL(gun.get_ammo(TRUE, TRUE), gun.magazine.max_ammo - 1, "Pulling a round did not empty a cylinder position")
	gun.attack_self(user)
	TEST_ASSERT(!gun.cylinder_open, "Self-use did not close cylinder")
	for(var/i in 1 to gun.magazine.max_ammo)
		gun.chamber_round()
		if(gun.chambered)
			break
	TEST_ASSERT(gun.chambered, "Closing/rotating cylinder did not ready remaining rounds")
	var/obj/item/ammo_casing/casing = gun.chambered
	QDEL_NULL(casing.loaded_projectile)
	gun.attack_self(user)
	gun.attack_self(user)
	TEST_ASSERT_EQUAL(gun.get_ammo(TRUE, TRUE), gun.magazine.max_ammo - 2, "Open cylinder did not eject its spent casing")
	TEST_ASSERT(gun.cylinder_open, "Ejecting spent casings unexpectedly closed cylinder")

/// Cylinder selection and HUD stay synchronized without rotating on close.
/datum/unit_test/revolver_hud_selection/Run()
	var/obj/item/gun/ballistic/revolver/gun = allocate(/obj/item/gun/ballistic/revolver)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/atom/movable/screen/ammo_counter/counter = allocate(/atom/movable/screen/ammo_counter)
	var/datum/component/ammo_hud/ammo_hud = gun.AddComponent(/datum/component/ammo_hud)
	user.put_in_hands(gun, forced = TRUE)
	ammo_hud.hud = counter
	ammo_hud.turn_on()
	gun.never_misfire = TRUE
	var/obj/item/ammo_casing/selected = gun.chambered
	TEST_ASSERT(gun.process_fire(victim, user), "Revolver failed to fire its initial round")
	TEST_ASSERT_EQUAL(gun.magazine.stored_ammo[gun.magazine.max_ammo], selected, "Initial shot did not advance the cylinder")
	var/list/fired_chamber = counter.revolver_chambers[gun.magazine.max_ammo]
	TEST_ASSERT_EQUAL(fired_chamber[1], "revolver_casing", "Initial shot did not shift the spent casing in the HUD")
	TEST_ASSERT_EQUAL(length(counter.overlays), gun.magazine.max_ammo, "Initial shot did not render the casing overlays")
	gun.postfire_empty_checks(TRUE)
	var/obj/item/ammo_casing/next_round = gun.chambered
	gun.before_can_shoot_checks(user)
	TEST_ASSERT_EQUAL(gun.chambered, next_round, "Next trigger advanced the cylinder twice")
	gun.toggle_cylinder_open()
	gun.toggle_cylinder_open()
	TEST_ASSERT_EQUAL(gun.chambered, next_round, "Opening and closing rotated the cylinder")
	gun.bolt_locked = TRUE
	gun.rack(user)
	TEST_ASSERT(gun.chambered != next_round, "Manual cocking did not advance the cylinder")
	var/list/previous_chamber = counter.revolver_chambers[gun.magazine.max_ammo - 1]
	TEST_ASSERT_EQUAL(previous_chamber[1], "revolver_casing", "Manual cocking left the HUD in its old position")
	gun.toggle_cylinder_open()
	gun.eject_spent_casings(user)
	var/obj/item/ammo_casing/refill = allocate(/obj/item/ammo_casing/c357)
	TEST_ASSERT(gun.load_gun(refill, user), "Open cylinder could not be reloaded")
	gun.toggle_cylinder_open()
	TEST_ASSERT_EQUAL(length(counter.revolver_chambers), gun.magazine.max_ammo, "Closing a reloaded cylinder hid its casings")
	TEST_ASSERT_EQUAL(counter.icon_state, "revolver_backing_[gun.magazine.max_ammo]", "Reload changed cylinder HUD capacity")
	TEST_ASSERT_EQUAL(length(counter.overlays), gun.magazine.max_ammo, "Closing a reloaded cylinder cleared the rendered casings")
	ammo_hud.update_hud()
	TEST_ASSERT_EQUAL(length(counter.overlays), gun.magazine.max_ammo, "Unchanged refresh cleared the rendered casings")
	ammo_hud.turn_off()

/// Identical refreshes must retain actual appearances, not just the chamber data cache.
/datum/unit_test/ammo_counter_repeated_refresh/Run()
	var/atom/movable/screen/ammo_counter/counter = allocate(/atom/movable/screen/ammo_counter)
	for(var/count in list(1, 6))
		var/list/chambers = list()
		for(var/index in 1 to count)
			chambers.len++
			chambers[index] = list("revolver_casing_live", index, 2)
		for(var/refresh in 1 to 3)
			counter.set_revolver_hud("revolver_backing_6", chambers)
			TEST_ASSERT_EQUAL(length(counter.overlays), count, "Repeated refresh lost rendered cylinder overlays")
			var/image/casing = counter.overlays[1]
			TEST_ASSERT_EQUAL(casing.icon_state, "revolver_casing_live", "Refresh changed casing state")
			TEST_ASSERT_EQUAL(casing.pixel_x, 1, "Refresh changed casing position")
	for(var/refresh in 1 to 3)
		counter.set_hud("#ff0000ff", "o1", "", "", "bullet")
		TEST_ASSERT_EQUAL(length(counter.overlays), 2, "Repeated refresh lost numeric counter overlays")

/// Single-action revolvers must still wait for a manual hammer cock.
/datum/unit_test/revolver_manual_hammer/Run()
	var/obj/item/gun/ballistic/revolver/gun = allocate(/obj/item/gun/ballistic/revolver/hd_gun/nova)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	user.put_in_hands(gun, forced = TRUE)
	gun.never_misfire = TRUE
	var/obj/item/ammo_casing/selected = gun.chambered
	TEST_ASSERT(gun.process_fire(victim, user), "Manual revolver failed to fire")
	gun.postfire_empty_checks(TRUE)
	TEST_ASSERT_EQUAL(gun.chambered, selected, "Manual revolver advanced without cocking")
	TEST_ASSERT(gun.bolt_locked, "Manual hammer did not lower after firing")
	gun.rack(user)
	TEST_ASSERT(gun.chambered != selected, "Manual cocking did not select the next chamber")

/// Racking an open cylinder ejects only spent casings without cocking or rotating it.
/datum/unit_test/revolver_open_cylinder_rack/Run()
	var/obj/item/gun/ballistic/revolver/gun = allocate(/obj/item/gun/ballistic/revolver)
	var/obj/item/ammo_casing/spent = gun.chambered
	QDEL_NULL(spent.loaded_projectile)
	var/original_capacity = gun.magazine.max_ammo
	gun.rack()
	TEST_ASSERT_EQUAL(spent.loc, gun.magazine, "Racking a closed cylinder ejected a casing")
	gun.toggle_cylinder_open()
	var/hammer_locked = gun.bolt_locked
	gun.rack()
	TEST_ASSERT(gun.cylinder_open, "Ejecting casings closed the cylinder")
	TEST_ASSERT_NULL(gun.chambered, "Ejecting casings readied a round")
	TEST_ASSERT_EQUAL(gun.bolt_locked, hammer_locked, "Ejecting casings changed the hammer state")
	TEST_ASSERT_EQUAL(spent.loc, gun.drop_location(), "Spent casing remained inside the cylinder")
	TEST_ASSERT_EQUAL(gun.get_ammo(TRUE, TRUE), original_capacity - 1, "Ejection removed the wrong number of casings")
	TEST_ASSERT_EQUAL(gun.get_ammo(FALSE, FALSE), original_capacity - 1, "Ejection removed a live round")
	gun.rack()
	TEST_ASSERT_EQUAL(gun.get_ammo(TRUE, TRUE), original_capacity - 1, "Repeated ejection removed live rounds")

/datum/unit_test/revolver_dry_fire_rotation/Run()
	var/obj/item/gun/ballistic/revolver/gun = allocate(/obj/item/gun/ballistic/revolver)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	gun.chamber_round(spin_cylinder = FALSE)
	var/obj/item/ammo_casing/empty_position = gun.chambered
	var/obj/item/ammo_casing/next_round = gun.magazine.stored_ammo[2]
	if(ispath(next_round))
		next_round = new next_round(gun.magazine)
		gun.magazine.stored_ammo[2] = next_round
	empty_position.forceMove(user.loc)
	user.put_in_hands(gun, forced = TRUE)
	user.set_combat_mode(FALSE)
	gun.fire_gun(user, user, FALSE)
	TEST_ASSERT(gun.bolt_locked, "Dry-click interaction result incorrectly readied the hammer")
	TEST_ASSERT_NULL(gun.chambered, "Dry click advanced the cylinder before cocking")
	gun.before_can_shoot_checks(user)
	TEST_ASSERT_EQUAL(gun.chambered, next_round, "Trigger after a dry click skipped the next live round")
	gun.postfire_empty_checks(FALSE)
	TEST_ASSERT(!gun.bolt_locked, "Rejected/cooldown attempt lowered the hammer")

/datum/unit_test/russian_revolver_spin_selection/Run()
	var/obj/item/gun/ballistic/revolver/russian/gun = allocate(/obj/item/gun/ballistic/revolver/russian)
	gun.bolt_locked = TRUE
	gun.do_spin()
	var/obj/item/ammo_casing/selected_round = gun.chambered
	gun.before_can_shoot_checks(null)
	TEST_ASSERT_EQUAL(gun.chambered, selected_round, "Roulette trigger changed the chamber selected by spinning")
	TEST_ASSERT(!gun.bolt_locked, "Spun roulette cylinder kept its hammer down")

/datum/unit_test/flechette_stacking/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/ammo_casing/shotgun/flechette/first = allocate(/obj/item/ammo_casing/shotgun/flechette)
	var/obj/item/ammo_casing/shotgun/flechette/second = allocate(/obj/item/ammo_casing/shotgun/flechette)
	var/obj/item/ammo_casing/shotgun/buckshot/buckshot = allocate(/obj/item/ammo_casing/shotgun/buckshot)
	user.put_in_hands(second, forced = TRUE)
	first.attackby(second, user, list())
	var/obj/item/ammo_box/magazine/ammo_stack/shotgun/flechette/stack = first.loc
	TEST_ASSERT(istype(stack), "Flechettes merged into the wrong stack type")
	TEST_ASSERT_EQUAL(second.loc, stack, "Second original flechette was lost")
	TEST_ASSERT_EQUAL(stack.ammo_count(), 2, "Flechette stack has wrong count")
	TEST_ASSERT(!stack.give_round(buckshot), "Flechette stack accepted buckshot")
	var/datum/material/iron = SSmaterials.get_material(/datum/material/iron)
	var/datum/material/glass = SSmaterials.get_material(/datum/material/glass)
	TEST_ASSERT_EQUAL(stack.custom_materials[iron], SMALL_MATERIAL_AMOUNT * 6, "Stack iron is not the sum of its flechettes")
	TEST_ASSERT_EQUAL(stack.custom_materials[glass], SMALL_MATERIAL_AMOUNT * 4, "Stack glass is not the sum of its flechettes")
	first.forceMove(user.loc)
	TEST_ASSERT_EQUAL(stack.custom_materials[iron], SMALL_MATERIAL_AMOUNT * 3, "Removing a flechette did not update materials")
	second.forceMove(user.loc)
	TEST_ASSERT(!length(stack.custom_materials), "Empty stack kept materials")

/datum/unit_test/ammo_stack_loaded_materials/Run()
	var/datum/material/iron = SSmaterials.get_material(/datum/material/iron)
	var/obj/item/ammo_box/magazine/ammo_stack/shotgun/empty_stack = allocate(/obj/item/ammo_box/magazine/ammo_stack/shotgun)
	TEST_ASSERT(!length(empty_stack.custom_materials), "Empty stack inherited box materials")
	var/obj/item/ammo_box/magazine/ammo_stack/shotgun/loaded/loaded_stack = allocate(/obj/item/ammo_box/magazine/ammo_stack/shotgun/loaded)
	TEST_ASSERT_EQUAL(loaded_stack.ammo_count(), loaded_stack.max_ammo, "Loaded stack is not full")
	TEST_ASSERT_EQUAL(loaded_stack.custom_materials[iron], loaded_stack.max_ammo * SHEET_MATERIAL_AMOUNT * 2, "Loaded stack materials are incorrect")
	var/obj/item/ammo_casing/casing = loaded_stack.get_round()
	casing.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(loaded_stack.custom_materials[iron], (loaded_stack.max_ammo - 1) * SHEET_MATERIAL_AMOUNT * 2, "Loaded stack lost material accounting after extraction")

/datum/unit_test/seclite_attachment_lifecycle/Run()
	var/obj/item/gun/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	var/obj/item/flashlight/seclite/light = allocate(/obj/item/flashlight/seclite)
	var/datum/component/attachment_mount/mount = gun.GetComponent(/datum/component/attachment_mount)
	var/datum/component/gun_attachment/attachment = light.GetComponent(/datum/component/gun_attachment)
	TEST_ASSERT(attachment, "Ordinary seclite has no attachment component")
	light.set_light_on(TRUE)
	TEST_ASSERT(mount.try_attach(light), "Ordinary seclite did not fit the rail")
	TEST_ASSERT(attachment.active, "Installation lost the flashlight's on state")
	TEST_ASSERT(light.light_flags & LIGHT_ATTACHED, "Installed light is not attached")
	light.on_saboteur(light, 10 SECONDS)
	TEST_ASSERT(!attachment.active, "Disruption left attachment active")
	TEST_ASSERT(!attachment.set_active(TRUE), "Attachment bypassed disruption")
	TEST_ASSERT(mount.try_detach(attachment), "Seclite could not be detached")
	TEST_ASSERT(!(light.light_flags & LIGHT_ATTACHED), "Detached seclite kept attached lighting")
	TEST_ASSERT(!mount.has_attachment_in_slot(ATTACHMENT_SLOT_RAIL), "Detached seclite kept the rail occupied")

/datum/unit_test/bayonet_attachment_lifecycle/Run()
	var/obj/item/gun/ballistic/gun = allocate(/obj/item/gun/ballistic/automatic/c20r)
	var/obj/item/knife/combat/knife = allocate(/obj/item/knife/combat)
	var/obj/item/attachment/silencer/silencer = allocate(/obj/item/attachment/silencer)
	var/datum/component/attachment_mount/mount = gun.GetComponent(/datum/component/attachment_mount)
	TEST_ASSERT(mount.try_attach(knife), "Bayonet was not installed through attachment mount")
	TEST_ASSERT(mount.has_attachment_in_slot(ATTACHMENT_SLOT_BAYONET), "Bayonet slot is not occupied")
	TEST_ASSERT(!mount.try_attach(silencer), "Silencer overlapped a bayonet")
	knife.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!mount.has_attachment_in_slot(ATTACHMENT_SLOT_BAYONET), "Moved bayonet kept its slot")
	TEST_ASSERT_EQUAL(mount.registered_hooks, NONE, "Moved bayonet left attack hooks registered")
	TEST_ASSERT(mount.try_attach(silencer), "Removing bayonet did not free muzzle")
	TEST_ASSERT(!mount.try_attach(knife), "Bayonet overlapped a silencer")
	var/obj/item/gun/ballistic/other_gun = allocate(/obj/item/gun/ballistic/automatic/c20r)
	var/datum/component/attachment_mount/other_mount = other_gun.GetComponent(/datum/component/attachment_mount)
	TEST_ASSERT_EQUAL(other_mount.slot_offsets[ATTACHMENT_SLOT_BAYONET]["x"], 26, "Bayonet configuration lost its original anchor")

/// Full auto repeats single shots, while burst mode retains the configured length.
/datum/unit_test/automatic_fire_selector/Run()
	var/obj/item/gun/ballistic/automatic/gun = allocate(/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/thump)
	var/datum/component/automatic_fire/autofire = gun.GetComponent(/datum/component/automatic_fire)
	TEST_ASSERT(autofire, "Full-auto gun has no autofire component")
	TEST_ASSERT_EQUAL(gun.burst_size, 1, "Full auto started by repeating whole bursts")
	TEST_ASSERT_EQUAL(autofire.autofire_shot_delay, initial(gun.fire_delay), "Autofire lost the configured shot interval")
	gun.firing_burst = TRUE
	gun.burst_select()
	TEST_ASSERT_EQUAL(gun.select, 3, "Selector changed during an unfinished burst")
	gun.firing_burst = FALSE
	for(var/cycle in 1 to 2)
		gun.burst_select()
		TEST_ASSERT_EQUAL(gun.select, 1, "Selector did not enter semi mode")
		TEST_ASSERT_EQUAL(gun.burst_size, 1, "Semi mode fires a burst")
		TEST_ASSERT(!gun.burst_fire_selection, "Semi selector overlay indicates burst")
		// Re-equipping can wake the component; ordinary clicks must still get through.
		TEST_ASSERT_EQUAL(gun.autofire_bypass_check(), COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS, "Semi mode lets autofire swallow clicks")
		gun.burst_select()
		TEST_ASSERT_EQUAL(gun.select, 2, "Selector skipped burst mode")
		TEST_ASSERT_EQUAL(gun.burst_size, initial(gun.burst_size), "Burst mode lost its configured length")
		TEST_ASSERT_EQUAL(gun.autofire_bypass_check(), COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS, "Burst mode lets autofire swallow clicks")
		gun.burst_select()
		TEST_ASSERT_EQUAL(gun.select, 3, "Selector did not return to auto mode")
		TEST_ASSERT_EQUAL(gun.burst_size, 1, "Returning to auto repeats whole bursts")
	var/obj/item/gun/ballistic/automatic/upstream = allocate(/obj/item/gun/ballistic/automatic/c20r)
	upstream.burst_select()
	TEST_ASSERT_EQUAL(upstream.burst_size, 1, "Upstream semi/burst toggle broke")
	upstream.burst_select()
	TEST_ASSERT_EQUAL(upstream.burst_size, 3, "Upstream burst length was not restored")
	var/obj/item/gun/ballistic/automatic/single = allocate(/obj/item/gun/ballistic/automatic/proto)
	single.burst_select()
	single.burst_select()
	TEST_ASSERT_EQUAL(single.select, 3, "Single-shot automatic gained an unsupported burst mode")

/// Stock guns with no base_icon_state must retain their named magazine/selector overlays.
/datum/unit_test/ballistic_overlay_prefix/Run()
	for(var/gun_type in list(/obj/item/gun/ballistic/automatic/c20r, /obj/item/gun/ballistic/automatic/wt550, /obj/item/gun/ballistic/automatic/m90))
		var/obj/item/gun/ballistic/gun = allocate(gun_type)
		var/list/gun_overlays = gun.update_overlays()
		var/prefix = initial(gun.icon_state)
		TEST_ASSERT("[prefix]_mag" in gun_overlays, "[gun_type] lost its magazine overlay")
		if(gun.selector_switch_icon)
			TEST_ASSERT("[prefix]_burst" in gun_overlays, "[gun_type] lost its selector overlay")
		TEST_ASSERT("[prefix]_mag" in icon_states(gun.icon), "[gun_type] has no matching magazine sprite")

/// Muzzle flashes render above mobs, using the gun's multiz plane offset.
/datum/unit_test/gunshot_overlay_plane/Run()
	var/obj/item/gun/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	gun.gunshot_animation_information = list("duration" = 2)
	gun.cut_overlays()
	INVOKE_ASYNC(gun, TYPE_PROC_REF(/obj/item/gun, gunshot_animation), null)
	TEST_ASSERT_EQUAL(length(gun.overlays), 1, "Gunshot animation did not add its overlay")
	var/image/flash = gun.overlays[1]
	TEST_ASSERT_EQUAL(flash.icon_state, "gunshot", "Gunshot image arguments lost its icon state")
	TEST_ASSERT_EQUAL(PLANE_TO_TRUE(flash.plane), ABOVE_GAME_PLANE, "Gunshot overlay renders below mobs")
	TEST_ASSERT_EQUAL(flash.layer, ABOVE_MOB_LAYER, "Gunshot overlay uses the item's lower layer")
	sleep(3)
	TEST_ASSERT_EQUAL(length(gun.overlays), 0, "Gunshot animation left a permanent overlay")
// [/HORIZON-ADD]
