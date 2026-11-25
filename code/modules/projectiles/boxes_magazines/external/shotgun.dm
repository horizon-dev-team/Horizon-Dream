/obj/item/ammo_box/magazine/m12g
	name = "shotgun magazine (12g buckshot shells)"
	desc = "A drum magazine of shotgun shells, suitable for the Bulldog combat shotgun."
	// [HORIZON-EDIT] GunRework
	icon = '_horizon/icons/obj/items/ammo/shotgun.dmi'
	icon_state = "m12"
	base_icon_state = "m12"
	// [/HORIZON-EDIT]
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
	caliber = CALIBER_SHOTGUN
	max_ammo = 8
	casing_phrasing = "shell"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2) // [HORIZON-ADD] GunRework

/obj/item/ammo_box/magazine/m12g/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ceil(ammo_count(FALSE)/8)*8]"

/obj/item/ammo_box/magazine/m12g/stun
	name = "shotgun magazine (12g taser slugs)"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/slug
	name = "shotgun magazine (12g slugs)"
	ammo_type = /obj/item/ammo_casing/shotgun/milspec

/obj/item/ammo_box/magazine/m12g/dragon
	name = "shotgun magazine (12g dragon's breath)"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "shotgun magazine (12g bioterror)"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bioterror

/obj/item/ammo_box/magazine/m12g/meteor
	name = "shotgun magazine (12g meteor slugs)"
	ammo_type = /obj/item/ammo_casing/shotgun/meteorslug

/obj/item/ammo_box/magazine/m12g/flechette
	name = "shotgun magazine (12g flechette)"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_box/magazine/m12g/donk
	name = "shotgun magazine (12g Donk Co. 'Donk Spike' flechette)"
	desc = "A drum magazine of shotgun shells, suitable for the Bulldog combat shotgun. It is covered in Donk Co. scratch-and-sniff \
		stickers. You're not sure you want to try and get a whiff..."
	ammo_type = /obj/item/ammo_casing/shotgun/flechette/donk

/obj/item/ammo_box/magazine/m12g/donk/examine_more(mob/user)
	. = ..()
	if(ishuman(user))
		return

	var/mob/living/carbon/human/human_sniffer = user
	if(!HAS_TRAIT(human_sniffer, TRAIT_ANOSMIA) && human_sniffer.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING|FORBID_TELEKINESIS_REACH))
		. += span_notice("You scratch and sniff the stickers.")
		. += span_warning("<i>Oh god, where did they pull this from, a landfill?</i>")
		human_sniffer.add_mood_event("stink-pocket", /datum/mood_event/disgusted)

// [HORIZON-ADD] GunRework
/obj/item/ammo_box/magazine/abyss_shotgun_drum
	name = "\improper Abyss Shotgun magazine"
	desc = "A 20-shell capacity magazine for the AN-12 shotgun."
	icon = '_horizon/icons/obj/items/ammo/shotgun.dmi'
	icon_state = "saiga_drum"
	base_icon_state = "saiga_drum"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = CALIBER_SHOTGUN
	max_ammo = 20
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/abyss_shotgun_drum/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? max_ammo : 0]"
// [/HORIZON-ADD]
