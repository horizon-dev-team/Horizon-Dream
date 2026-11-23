// Muzzle points of every gun that takes a silencer attachment.
//
// The silencer draws its own sprite (silencer-attached), so it needs to know where the barrel
// of each gun ends. The point is the bottom-left corner of the silencer sprite on the gun's
// icon, in pixels from the bottom-left of the tile: x is the last barrel column, y is the
// barrel's centre minus the sprite's own centre line. All guns face right.
// Measured from the gun sprites, so a gun with a changed sprite needs its entry rechecked.
// Types inherit the entry of their parent, so only guns with a sprite of their own are listed.
// Every list repeats the default rail entry from /obj/item/gun in gun.dm, as slot_offsets is replaced whole.

#define GUN_RAIL_OFFSET list("x" = 17, "y" = 17)
#define GUN_MUZZLE_OFFSETS(muzzle_x, muzzle_y) list(ATTACHMENT_SLOT_RAIL = GUN_RAIL_OFFSET, ATTACHMENT_SLOT_MUZZLE = list("x" = muzzle_x, "y" = muzzle_y))

/obj/item/gun/ballistic/automatic/proto
	slot_offsets = GUN_MUZZLE_OFFSETS(24, 16)

/obj/item/gun/ballistic/automatic/c20r
	slot_offsets = GUN_MUZZLE_OFFSETS(25, 16)

/obj/item/gun/ballistic/automatic/mini_uzi
	slot_offsets = GUN_MUZZLE_OFFSETS(30, 20)

/obj/item/gun/ballistic/automatic/battle_rifle
	slot_offsets = GUN_MUZZLE_OFFSETS(39, 14)

/obj/item/gun/ballistic/automatic/gyropistol
	slot_offsets = GUN_MUZZLE_OFFSETS(27, 18)

/obj/item/gun/ballistic/automatic/pistol
	slot_offsets = GUN_MUZZLE_OFFSETS(25, 19)

/obj/item/gun/ballistic/automatic/pistol/clandestine
	slot_offsets = GUN_MUZZLE_OFFSETS(26, 19)

/obj/item/gun/ballistic/automatic/pistol/aps
	slot_offsets = GUN_MUZZLE_OFFSETS(27, 17)

/obj/item/gun/ballistic/automatic/pistol/stickman
	slot_offsets = GUN_MUZZLE_OFFSETS(23, 18)

/obj/item/gun/ballistic/revolver/nagant
	slot_offsets = GUN_MUZZLE_OFFSETS(27, 17)

/obj/item/gun/ballistic/rifle/sniper_rifle
	slot_offsets = GUN_MUZZLE_OFFSETS(30, 28)

/obj/item/gun/ballistic/automatic/lahti
	slot_offsets = GUN_MUZZLE_OFFSETS(71, 16)

/obj/item/gun/ballistic/automatic/toy
	slot_offsets = GUN_MUZZLE_OFFSETS(24, 16)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/ruger
	slot_offsets = GUN_MUZZLE_OFFSETS(17, 12)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/aps
	slot_offsets = GUN_MUZZLE_OFFSETS(25, 6)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/m1911
	slot_offsets = GUN_MUZZLE_OFFSETS(23, 14)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/combatmaster
	slot_offsets = GUN_MUZZLE_OFFSETS(29, 14)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/glock17
	slot_offsets = GUN_MUZZLE_OFFSETS(27, 18)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/ppk
	slot_offsets = GUN_MUZZLE_OFFSETS(22, 12)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/aniquilador
	slot_offsets = GUN_MUZZLE_OFFSETS(27, 16)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/john
	slot_offsets = GUN_MUZZLE_OFFSETS(30, 18)

/obj/item/gun/ballistic/automatic/pistol/hd_gun/pm9
	slot_offsets = GUN_MUZZLE_OFFSETS(27, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare/m545
	slot_offsets = GUN_MUZZLE_OFFSETS(43, 15)

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/warfare/m545/ak
	slot_offsets = GUN_MUZZLE_OFFSETS(44, 18)

/obj/item/gun/ballistic/automatic/hd_gun/remis/winter
	slot_offsets = GUN_MUZZLE_OFFSETS(43, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss
	slot_offsets = GUN_MUZZLE_OFFSETS(47, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/abyss/donator
	slot_offsets = GUN_MUZZLE_OFFSETS(47, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/steyr
	slot_offsets = GUN_MUZZLE_OFFSETS(43, 14)

/obj/item/gun/ballistic/automatic/hd_gun/remis/svd
	slot_offsets = GUN_MUZZLE_OFFSETS(59, 14)

/obj/item/gun/ballistic/automatic/hd_gun/remis/g36
	slot_offsets = GUN_MUZZLE_OFFSETS(49, 14)

/obj/item/gun/ballistic/shotgun/hd_gun
	slot_offsets = GUN_MUZZLE_OFFSETS(38, 16)

/obj/item/gun/ballistic/shotgun/hd_gun/ithaca
	slot_offsets = GUN_MUZZLE_OFFSETS(38, 16)

/obj/item/gun/ballistic/shotgun/hd_gun/hunting
	slot_offsets = GUN_MUZZLE_OFFSETS(39, 16)

/obj/item/gun/ballistic/shotgun/hd_gun/riot
	slot_offsets = GUN_MUZZLE_OFFSETS(39, 16)

/obj/item/gun/ballistic/shotgun/hd_gun/bulldog
	slot_offsets = GUN_MUZZLE_OFFSETS(37, 16)

/obj/item/gun/ballistic/shotgun/hd_gun/abyss
	slot_offsets = GUN_MUZZLE_OFFSETS(45, 16)

/obj/item/gun/ballistic/shotgun/hd_gun/bolas
	slot_offsets = GUN_MUZZLE_OFFSETS(45, 16)

/obj/item/gun/ballistic/shotgun/hd_gun/denominator
	slot_offsets = GUN_MUZZLE_OFFSETS(41, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/ppsh
	slot_offsets = GUN_MUZZLE_OFFSETS(31, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/solitario
	slot_offsets = GUN_MUZZLE_OFFSETS(30, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/bastardo
	slot_offsets = GUN_MUZZLE_OFFSETS(42, 18)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/thump
	slot_offsets = GUN_MUZZLE_OFFSETS(43, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/solitario/suppressed
	slot_offsets = GUN_MUZZLE_OFFSETS(46, 16)

/obj/item/gun/ballistic/automatic/hd_gun/remis/smg/bolsa
	slot_offsets = GUN_MUZZLE_OFFSETS(41, 18)

#undef GUN_MUZZLE_OFFSETS
#undef GUN_RAIL_OFFSET
