/obj/item/storage/box/traitorbundledebug
	name = "debug traitor box"
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/traitorbundledebug/PopulateContents()
	var/static/items_inside = list(
		/obj/item/card/emag=1,\
		/obj/item/uplink/debug=1,\
		/obj/item/uplink/nuclear/debug=1,\
		/obj/item/flashlight/emp/debug=1,\
	)
	generate_items_inside(items_inside,src)
