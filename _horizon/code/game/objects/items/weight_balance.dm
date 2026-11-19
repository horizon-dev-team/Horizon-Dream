// Explicit masses and bag relief. w_class stays the inventory-size system;
// carry_weight is kilograms and wins over weight_class_to_kg().
// Liquid is 100u = 1 kg. See REAGENT_UNIT_KG.

// --- worn containers (contents only; shell mass is carry_weight) ---
/obj/item/storage/backpack
	carry_weight = 1
	storage_weight_multiplier = STORAGE_WEIGHT_MULT_BACKPACK

/obj/item/storage/backpack/satchel
	carry_weight = 0.7
	storage_weight_multiplier = STORAGE_WEIGHT_MULT_SATCHEL

/obj/item/storage/backpack/duffelbag
	carry_weight = 1.3
	storage_weight_multiplier = STORAGE_WEIGHT_MULT_DUFFEL

/obj/item/storage/backpack/holding
	carry_weight = 1.5
	storage_weight_multiplier = STORAGE_WEIGHT_MULT_HOLDING

/obj/item/storage/backpack/santabag
	storage_weight_multiplier = 0.4

/obj/item/storage/bag
	carry_weight = 0.45
	storage_weight_multiplier = STORAGE_WEIGHT_MULT_BAG

/obj/item/storage/bag/trash/bluespace
	storage_weight_multiplier = STORAGE_WEIGHT_MULT_HOLDING

/obj/item/storage/bag/ore/holding
	storage_weight_multiplier = STORAGE_WEIGHT_MULT_HOLDING

// --- doses are not litres ---
/obj/item/reagent_containers/applicator
	reagent_weight_factor = REAGENT_WEIGHT_DOSE

/obj/item/reagent_containers/applicator/pill
	carry_weight = 0.002

/obj/item/reagent_containers/applicator/patch
	carry_weight = 0.005

/obj/item/storage/pill_bottle
	carry_weight = 0.04

/obj/item/cigarette
	carry_weight = 0.001
	reagent_weight_factor = REAGENT_WEIGHT_DOSE

/obj/item/cigarette/cigar
	carry_weight = 0.008

/obj/item/cigarette/pipe
	carry_weight = 0.08

// --- clothes that used to share the "normal item" bracket ---
/obj/item/clothing/under
	carry_weight = 0.45

/obj/item/clothing/shoes
	carry_weight = 0.55

/obj/item/clothing/shoes/magboots
	carry_weight = 2.4

/obj/item/clothing/gloves
	carry_weight = 0.12

/obj/item/clothing/head/helmet
	carry_weight = 1.4

/obj/item/clothing/head/helmet/toggleable/riot
	carry_weight = 2.2

/obj/item/clothing/head/helmet/swat
	carry_weight = 2.4

/obj/item/clothing/suit/space
	carry_weight = 6

// Type I vest was the same couple of kilos as a sidearm. Soft armor is ~3 kg;
// plates, riot gear and heavy suits step up from there.
/obj/item/clothing/suit/armor
	carry_weight = 3.2

/obj/item/clothing/suit/armor/vest/durathread
	carry_weight = 1.6

/obj/item/clothing/suit/armor/vest/marine
	carry_weight = 7.5

/obj/item/clothing/suit/armor/bulletproof
	carry_weight = 6.5

/obj/item/clothing/suit/armor/riot
	carry_weight = 8

/obj/item/clothing/suit/armor/heavy
	carry_weight = 12

/obj/item/clothing/suit/armor/balloon_vest
	carry_weight = 0.2

// --- guns. Empty body; magazine, cell and chambered rounds add themselves. ---
/obj/item/gun/ballistic/automatic
	carry_weight = 2.3

/obj/item/gun/ballistic/automatic/pistol
	carry_weight = 0.75

/obj/item/gun/ballistic/automatic/pistol/deagle
	carry_weight = 1.8

/obj/item/gun/ballistic/automatic/pistol/aps
	carry_weight = 1.15

/obj/item/gun/ballistic/automatic/wt550
	carry_weight = 2.5

/obj/item/gun/ballistic/automatic/m90
	carry_weight = 3.4

/obj/item/gun/ballistic/automatic/tommygun
	carry_weight = 4.2

/obj/item/gun/ballistic/automatic/laser
	carry_weight = 3.2

/obj/item/gun/ballistic/automatic/battle_rifle
	carry_weight = 3.8

/obj/item/gun/ballistic/automatic/l6_saw
	carry_weight = 9.5

/obj/item/gun/ballistic/revolver
	carry_weight = 1.05

/obj/item/gun/ballistic/revolver/grenadelauncher
	carry_weight = 3.4

/obj/item/gun/ballistic/revolver/grenadelauncher/underbarrel
	carry_weight = 1.4

/obj/item/gun/ballistic/shotgun
	carry_weight = 3.3

/obj/item/gun/ballistic/shotgun/automatic/combat
	carry_weight = 4.2

/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	carry_weight = 3.3

/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	carry_weight = 4.8

/obj/item/gun/energy/laser
	carry_weight = 2.8

/obj/item/gun/energy/laser/pistol
	carry_weight = 1.1

/obj/item/gun/energy/pulse
	carry_weight = 4.6

/obj/item/gun/energy/pulse/pistol
	carry_weight = 1.5

// --- ammo. A cartridge is grams; the box/mag shell is separate. ---
/obj/item/ammo_casing
	carry_weight = 0.012

/obj/item/ammo_casing/c38
	carry_weight = 0.01

/obj/item/ammo_casing/c357
	carry_weight = 0.015

/obj/item/ammo_casing/shotgun
	carry_weight = 0.04

/obj/item/ammo_casing/a40mm
	carry_weight = 0.23

/obj/item/ammo_casing/rocket
	carry_weight = 1.6

/obj/item/ammo_box/magazine
	carry_weight = 0.1

/obj/item/ammo_box/magazine/internal
	carry_weight = 0.05

// --- MODsuit. Parts and modules live inside the control unit. ---
/obj/item/mod/control
	carry_weight = 2.2

/obj/item/mod/core
	carry_weight = 0.4

/obj/item/mod/module
	carry_weight = 0.25

/obj/item/clothing/head/mod
	carry_weight = 1.4

/obj/item/clothing/suit/mod
	carry_weight = 8

/obj/item/clothing/gloves/mod
	carry_weight = 0.6

/obj/item/clothing/shoes/mod
	carry_weight = 1.2

// Glass, not a kilo of beaker before the liquid goes in. 100u of water is still 1 kg.
/obj/item/reagent_containers/cup/beaker
	carry_weight = 0.12

/obj/item/reagent_containers/cup/bottle
	carry_weight = 0.08
