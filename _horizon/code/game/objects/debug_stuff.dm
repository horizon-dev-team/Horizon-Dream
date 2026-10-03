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

/obj/item/storage/bag/chemistry/debug/PopulateContents()
	for(var/i in 1 to 8)
		new /obj/item/reagent_containers/cup/beaker/bluespace(src)
		new /obj/item/reagent_containers/cup/beaker/meta(src)
		new /obj/item/reagent_containers/cup/beaker/plastic(src)
		new /obj/item/reagent_containers/cup/beaker/large(src)
		new /obj/item/reagent_containers/cup/beaker(src)
		new /obj/item/reagent_containers/cup/beaker/noreact(src)
