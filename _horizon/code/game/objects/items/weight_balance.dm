// Explicit masses and bag relief. w_class stays the inventory-size system;
// carry_weight is kilograms and wins over weight_class_to_kg().
// Liquid is 100u = 1 kg. See REAGENT_UNIT_KG.

// MARK: Containers
/obj/item/storage/backpack
	carry_weight = 1 KILOGRAMS
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(30)
/obj/item/storage/backpack/satchel
	carry_weight = 700 GRAMS
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(25)
/obj/item/storage/backpack/duffelbag
	carry_weight = 1.3 KILOGRAMS
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(30)
/obj/item/storage/backpack/santabag
	storage_weight_multiplier = 400 GRAMS
/obj/item/storage/bag
	carry_weight = 450 GRAMS
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(35)
/obj/item/storage/belt
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(50)
/obj/item/storage/backpack/holding
	carry_weight = 1.5 KILOGRAMS
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(90)
/obj/item/storage/belt/utility/full/powertools/holding
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(90)
/obj/item/storage/bag/trash/bluespace
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(90)
/obj/item/storage/box
	carry_weight = 50 GRAMS

// MARK: Reagent containers
/obj/item/reagent_containers/applicator
	reagent_weight_factor = REAGENT_WEIGHT_DOSE
/obj/item/reagent_containers/applicator/pill
	carry_weight = 2 GRAMS
/obj/item/reagent_containers/applicator/patch
	carry_weight = 5 GRAMS
/obj/item/storage/pill_bottle
	carry_weight = 4 GRAMS
/obj/item/cigarette
	carry_weight = 1 GRAMS
	reagent_weight_factor = REAGENT_WEIGHT_DOSE
/obj/item/cigarette/cigar
	carry_weight = 8 GRAMS
/obj/item/cigarette/pipe
	carry_weight = 80 GRAMS

// MARK: Clothes
/obj/item/clothing/under
	carry_weight = 450 GRAMS
/obj/item/clothing/shoes
	carry_weight = 550 GRAMS
/obj/item/clothing/shoes/laceup
	carry_weight = 200 GRAMS
/obj/item/clothing/shoes/magboots
	carry_weight = 2.4 KILOGRAMS
/obj/item/clothing/gloves
	carry_weight = 120 GRAMS
/obj/item/clothing/gloves/captain
	carry_weight = 150 GRAMS
/obj/item/clothing/head/helmet
	carry_weight = 1.4 KILOGRAMS
/obj/item/clothing/head/helmet/toggleable/riot
	carry_weight = 2.2 KILOGRAMS
/obj/item/clothing/head/helmet/swat
	carry_weight = 2.4 KILOGRAMS
/obj/item/clothing/suit/space
	carry_weight = 6 KILOGRAMS
/obj/item/clothing/glasses
	carry_weight = 250 GRAMS

// Type I vest was the same couple of kilos as a sidearm. Soft armor is ~3 kg;
// plates, riot gear and heavy suits step up from there.
/obj/item/clothing/suit/armor
	carry_weight = 3.2 KILOGRAMS

/obj/item/clothing/suit/armor/vest/durathread
	carry_weight = 1.6 KILOGRAMS
/obj/item/clothing/suit/armor/vest/marine
	carry_weight = 7.5 KILOGRAMS
/obj/item/clothing/suit/armor/bulletproof
	carry_weight = 6.5 KILOGRAMS
/obj/item/clothing/suit/armor/riot
	carry_weight = 8 KILOGRAMS
/obj/item/clothing/suit/armor/heavy
	carry_weight = 12 KILOGRAMS
/obj/item/clothing/suit/armor/balloon_vest
	carry_weight = 200 GRAMS


/*
 - Скорость снарядов у дробовиков TG
 - Какой то плохо работает
 - Бинбег снаряды у дробовиков (найти)
 - ПП путь стреляет автоматом-по 2 пули
 - Сделать предметы в руках весят в 2 раза меньше
 - /obj/item/stack/medical/wrap/sticky_tape
 - /obj/item/stack/medical
*/
// MARK: Guns
// Empty body; magazine, cell and chambered rounds add themselves.
/obj/item/gun/ballistic/automatic
	carry_weight = 2.3 KILOGRAMS
/obj/item/gun/ballistic/automatic/pistol
	carry_weight = 750 GRAMS
/obj/item/gun/ballistic/automatic/pistol/deagle
	carry_weight = 1.8 KILOGRAMS
/obj/item/gun/ballistic/automatic/pistol/aps
	carry_weight = 1.15 KILOGRAMS
/obj/item/gun/ballistic/automatic/wt550
	carry_weight = 2.5 KILOGRAMS
/obj/item/gun/ballistic/automatic/m90
	carry_weight = 3.4 KILOGRAMS
/obj/item/gun/ballistic/automatic/tommygun
	carry_weight = 4.2 KILOGRAMS
/obj/item/gun/ballistic/automatic/laser
	carry_weight = 3.2 KILOGRAMS
/obj/item/gun/ballistic/automatic/battle_rifle
	carry_weight = 3.8 KILOGRAMS
/obj/item/gun/ballistic/automatic/l6_saw
	carry_weight = 9.5 KILOGRAMS
/obj/item/gun/ballistic/revolver
	carry_weight = 1.05 KILOGRAMS
/obj/item/gun/ballistic/revolver/grenadelauncher
	carry_weight = 3.4 KILOGRAMS
/obj/item/gun/ballistic/revolver/grenadelauncher/underbarrel
	carry_weight = 1.4 KILOGRAMS
/obj/item/gun/ballistic/shotgun
	carry_weight = 3.3 KILOGRAMS
/obj/item/gun/ballistic/shotgun/automatic/combat
	carry_weight = 4.2 KILOGRAMS
/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	carry_weight = 3.3 KILOGRAMS
/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	carry_weight = 4.8 KILOGRAMS
/obj/item/gun/energy/laser
	carry_weight = 2.8 KILOGRAMS
/obj/item/gun/energy/laser/pistol
	carry_weight = 1.1 KILOGRAMS
/obj/item/gun/energy/pulse
	carry_weight = 4.6 KILOGRAMS
/obj/item/gun/energy/pulse/pistol
	carry_weight = 1.5 KILOGRAMS

// MARK: Ammo.
// A cartridge is grams; the box/mag shell is separate.
/obj/item/ammo_casing
	carry_weight = 12 GRAMS
/obj/item/ammo_casing/c38
	carry_weight = 10 GRAMS
/obj/item/ammo_casing/c357
	carry_weight = 15 GRAMS
/obj/item/ammo_casing/shotgun
	carry_weight = 4 GRAMS
/obj/item/ammo_casing/a40mm
	carry_weight = 230 GRAMS
/obj/item/ammo_casing/rocket
	carry_weight = 1.6 KILOGRAMS
/obj/item/ammo_box/magazine
	carry_weight = 100 GRAMS
/obj/item/ammo_box/magazine/internal
	carry_weight = 50 GRAMS

// MARK: MODsuit.
// Parts and modules live inside the control unit.
/obj/item/mod/control
	carry_weight = 2.2
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(30)

/// Weight (kg) the servos take off the deployed parts. Stowed parts sit in contents and get the
/// same relief through storage_weight_multiplier, so deploying or retracting never changes your load.
/obj/item/mod/control/proc/get_deployed_weight_relief()
	. = 0
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		. += part.get_carry_weight() * (1 - storage_weight_multiplier)

/obj/item/mod/core
	carry_weight = 400 GRAMS
/obj/item/mod/module
	carry_weight = 250 GRAMS
/obj/item/clothing/head/mod
	carry_weight = 1.4 KILOGRAMS
/obj/item/clothing/suit/mod
	carry_weight = 8 KILOGRAMS
/obj/item/clothing/gloves/mod
	carry_weight = 600 GRAMS
/obj/item/clothing/shoes/mod
	carry_weight = 1.2 KILOGRAMS

// Glass, not a kilo of beaker before the liquid goes in. 100u of water is still 1 kg.
/obj/item/reagent_containers/cup/beaker
	carry_weight = 120 GRAMS
/obj/item/reagent_containers/cup/bottle
	carry_weight = 80 GRAMS

// MARK: Tool containers
/obj/item/storage/part_replacer
	carry_weight = 2.5 KILOGRAMS
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(50)
/obj/item/storage/part_replacer/bluespace
	carry_weight = 2 KILOGRAMS
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(90)
/obj/item/storage/bag/ore
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(50)
/obj/item/storage/bag/ore/holding
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(90)
/obj/item/storage/bag/sheetsnatcher
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(50)
/obj/item/surgery_tray/full
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(50)
/obj/item/storage/briefcase
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(50)
/obj/item/storage/toolbox
	storage_weight_multiplier = STORAGE_WEIGHT_MULT(50)

// MARK: Sheets
/obj/item/stack/sheet/iron
	carry_weight_per_unit = 400 GRAMS
/obj/item/stack/sheet/plasteel
	carry_weight_per_unit = 600 GRAMS
/obj/item/stack/sheet/runed_metal
	carry_weight_per_unit = 400 GRAMS
/obj/item/stack/sheet/bronze
	carry_weight_per_unit = 450 GRAMS
/obj/item/stack/sheet/hauntium
	carry_weight_per_unit = 500 GRAMS
/obj/item/stack/sheet/mineral/metal_hydrogen
	carry_weight_per_unit = 500 GRAMS
/obj/item/stack/sheet/mineral/runite
	carry_weight_per_unit = 550 GRAMS
/obj/item/stack/sheet/mineral/zaukerite
	carry_weight_per_unit = 600 GRAMS
/obj/item/stack/sheet/mineral/mythril
	carry_weight_per_unit = 200 GRAMS
/obj/item/stack/sheet/mineral/adamantine
	carry_weight_per_unit = 800 GRAMS
/obj/item/stack/sheet/mineral/abductor
	carry_weight_per_unit = 350 GRAMS
/obj/item/stack/sheet/mineral/coal
	carry_weight_per_unit = 300 GRAMS
/obj/item/stack/sheet/plastic
	carry_weight_per_unit = 150 GRAMS
/obj/item/stack/sheet/glass
	carry_weight_per_unit = 250 GRAMS
/obj/item/stack/sheet/rglass
	carry_weight_per_unit = 350 GRAMS
/obj/item/stack/sheet/plasmaglass
	carry_weight_per_unit = 400 GRAMS
/obj/item/stack/sheet/plasmarglass
	carry_weight_per_unit = 500 GRAMS
/obj/item/stack/sheet/titaniumglass
	carry_weight_per_unit = 450 GRAMS
/obj/item/stack/sheet/plastitaniumglass
	carry_weight_per_unit = 550 GRAMS
/obj/item/stack/sheet/mineral/gold
	carry_weight_per_unit = 900 GRAMS
/obj/item/stack/sheet/mineral/uranium
	carry_weight_per_unit = 800 GRAMS
/obj/item/stack/sheet/mineral/silver
	carry_weight_per_unit = 550 GRAMS
/obj/item/stack/sheet/mineral/plasma
	carry_weight_per_unit = 400 GRAMS
/obj/item/stack/sheet/mineral/diamond
	carry_weight_per_unit = 300 GRAMS
/obj/item/stack/sheet/mineral/titanium
	carry_weight_per_unit = 350 GRAMS
/obj/item/stack/sheet/mineral/plastitanium
	carry_weight_per_unit = 550 GRAMS
/obj/item/stack/sheet/mineral/bananium
	carry_weight_per_unit = 300 GRAMS
/obj/item/stack/sheet/mineral/sandstone
	carry_weight_per_unit = 400 GRAMS
/obj/item/stack/sheet/mineral/sandbags
	carry_weight_per_unit = 800 GRAMS
/obj/item/stack/sheet/mineral/snow
	carry_weight_per_unit = 100 GRAMS
/obj/item/stack/sheet/mineral/wood
	carry_weight_per_unit = 250 GRAMS
/obj/item/stack/sheet/mineral/bamboo
	carry_weight_per_unit = 100 GRAMS
/obj/item/stack/sheet/cardboard
	carry_weight_per_unit = 80 GRAMS
/obj/item/stack/sheet/paperframes
	carry_weight_per_unit = 100 GRAMS
/obj/item/stack/sheet/cloth
	carry_weight_per_unit = 50 GRAMS
/obj/item/stack/sheet/durathread
	carry_weight_per_unit = 60 GRAMS
/obj/item/stack/sheet/cotton
	carry_weight_per_unit = 30 GRAMS
/obj/item/stack/sheet/bone
	carry_weight_per_unit = 150 GRAMS
/obj/item/stack/sheet/animalhide
	carry_weight_per_unit = 100 GRAMS
/obj/item/stack/sheet/hot_ice
	carry_weight_per_unit = 450 GRAMS
/obj/item/stack/sheet/lessergem
	carry_weight_per_unit = 200 GRAMS
/obj/item/stack/sheet/greatergem
	carry_weight_per_unit = 400 GRAMS

// MARK: Sheet families
/obj/item/stack/sheet/bluespace_crystal
	carry_weight_per_unit = 100 GRAMS
/obj/item/stack/sheet/telepolycrystal
	carry_weight_per_unit = 30 GRAMS
/obj/item/stack/sheet/wethide
	carry_weight_per_unit = 120 GRAMS
/obj/item/stack/sheet/hairlesshide
	carry_weight_per_unit = 80 GRAMS
/obj/item/stack/sheet/leather
	carry_weight_per_unit = 60 GRAMS
/obj/item/stack/sheet/sinew
	carry_weight_per_unit = 30 GRAMS
/obj/item/stack/sheet/meat
	carry_weight_per_unit = 150 GRAMS
/obj/item/stack/sheet/pizza
	carry_weight_per_unit = 150 GRAMS

// MARK: Ores
// A raw chunk is rock plus metal, so it outweighs its refined sheet.
// (~1.35x now). Base covers plain rock and any future subtype.
/obj/item/stack/ore
	carry_weight_per_unit = 250 GRAMS
/obj/item/stack/ore/slag
	carry_weight_per_unit = 200 GRAMS
/obj/item/stack/ore/iron
	carry_weight_per_unit = 550 GRAMS
/obj/item/stack/ore/glass
	carry_weight_per_unit = 300 GRAMS
/obj/item/stack/ore/plasma
	carry_weight_per_unit = 500 GRAMS
/obj/item/stack/ore/silver
	carry_weight_per_unit = 750 GRAMS
/obj/item/stack/ore/gold
	carry_weight_per_unit = 1.2 KILOGRAMS
/obj/item/stack/ore/uranium
	carry_weight_per_unit = 1.1 KILOGRAMS
/obj/item/stack/ore/titanium
	carry_weight_per_unit = 450 GRAMS
/obj/item/stack/ore/diamond
	carry_weight_per_unit = 350 GRAMS
/obj/item/stack/ore/bananium
	carry_weight_per_unit = 400 GRAMS
/obj/item/stack/ore/bluespace_crystal
	carry_weight_per_unit = 150 GRAMS

// MARK: Construction stacks
// 1 iron sheet -> 2 rods (0.2), 1 sheet -> 4 floor tiles (0.1); a cable length is a wire strip.
/obj/item/stack/rods
	carry_weight_per_unit = 200 GRAMS
/obj/item/stack/tile
	carry_weight_per_unit = 100 GRAMS
/obj/item/stack/cable_coil
	carry_weight_per_unit = 20 GRAMS

// MARK: Medical
/obj/item/stack/medical
	carry_weight_per_unit = 10 GRAMS
/obj/item/stack/medical/bruise_pack
	carry_weight_per_unit = 20 GRAMS
/obj/item/stack/medical/suture
	carry_weight_per_unit = 5 GRAMS
/obj/item/stack/medical/ointment
	carry_weight_per_unit = 15 GRAMS
/obj/item/stack/medical/mesh
	carry_weight_per_unit = 8 GRAMS
/obj/item/stack/medical/mesh/advanced
	carry_weight_per_unit = 12 GRAMS
/obj/item/stack/medical/aloe
	carry_weight_per_unit = 5 GRAMS
/obj/item/stack/medical/aloe/fresh
	carry_weight_per_unit = 20 GRAMS
/obj/item/stack/medical/bone_gel
	carry_weight_per_unit = 20 GRAMS
/obj/item/stack/medical/poultice
	carry_weight_per_unit = 8 GRAMS
/obj/item/stack/medical/bandage
	carry_weight_per_unit = 15 GRAMS

// Devices and containers
/obj/item/storage/medkit
	carry_weight = 350 GRAMS
/obj/item/defibrillator
	carry_weight = 5.5 KILOGRAMS
/obj/item/defibrillator/compact
	carry_weight = 1.8 KILOGRAMS
/obj/item/healthanalyzer
	carry_weight = 250 GRAMS
/obj/item/reagent_containers/syringe
	carry_weight = 10 GRAMS
/obj/item/reagent_containers/hypospray/medipen
	carry_weight = 30 GRAMS
/obj/item/reagent_containers/blood
	carry_weight = 50 GRAMS
/obj/item/bodybag
	carry_weight = 150 GRAMS
/obj/item/storage/belt/medipenal
	carry_weight = 150 GRAMS

// Surgical tools: steel instruments, not the 0.04 kg of a paperclip.
/obj/item/scalpel
	carry_weight = 100 GRAMS
/obj/item/scalpel/advanced
	carry_weight = 200 GRAMS
/obj/item/hemostat
	carry_weight = 120 GRAMS
/obj/item/retractor
	carry_weight = 150 GRAMS
/obj/item/retractor/advanced
	carry_weight = 200 GRAMS
/obj/item/cautery
	carry_weight = 200 GRAMS
/obj/item/cautery/advanced
	carry_weight = 250 GRAMS
/obj/item/surgicaldrill
	carry_weight = 900 GRAMS
/obj/item/circular_saw
	carry_weight = 1.2 KILOGRAMS
/obj/item/bonesetter
	carry_weight = 500 GRAMS
/obj/item/surgical_drapes
	carry_weight = 100 GRAMS
/obj/item/blood_filter
	carry_weight = 400 GRAMS

// MARK: Misc
/obj/item/card
	carry_weight = 50 GRAMS
/obj/item/seeds
	carry_weight = 10 GRAMS
/obj/item/crowbar
	carry_weight = 1.2 KILOGRAMS
