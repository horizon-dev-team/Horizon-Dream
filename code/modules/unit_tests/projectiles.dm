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
	TEST_ASSERT_EQUAL(muzzle_offset["x"], gun.muzzle_attachment_offset["x"], "Muzzle X anchor was not merged")
	TEST_ASSERT_EQUAL(muzzle_offset["y"], gun.muzzle_attachment_offset["y"], "Muzzle Y anchor was not merged")

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
	var/datum/component/gun_attachment/silencer = muzzle_attachments[1]
	mount.try_detach(silencer, null)
	TEST_ASSERT_EQUAL(gun.suppressed, SUPPRESSED_NONE, "Removing the integrated silencer left the gun suppressed")
// [/HORIZON-ADD]
