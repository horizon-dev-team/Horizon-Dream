/// Global list of all placeable atoms grouped by category.
GLOBAL_LIST_INIT(buildmode_items, build_buildmode_items())

/proc/build_buildmode_items()
	var/list/categories = list()

	categories += list(list("id" = BM_CATEGORY_TURF, "name" = "Turfs", "items" = build_category_items(/turf, list(/turf/template_noop))))
	categories += list(list("id" = BM_CATEGORY_OBJ, "name" = "Objects", "items" = build_category_items(/obj, list(/obj/item, /obj/effect), check_abstract = TRUE)))
	categories += list(list("id" = BM_CATEGORY_MOB, "name" = "Mobs", "items" = build_category_items(/mob, list(/mob/dead))))
	categories += list(list("id" = BM_CATEGORY_ITEM, "name" = "Items", "items" = build_category_items(/obj/item, list(/obj/item/clothing, /obj/item/reagent_containers, /obj/item/food, /obj/item/gun, /obj/item/stack))))
	categories += list(list("id" = BM_CATEGORY_WEAPON, "name" = "Weapons", "items" = build_category_items(/obj/item/gun)))
	categories += list(list("id" = BM_CATEGORY_CLOTHING, "name" = "Clothing", "items" = build_category_items(/obj/item/clothing)))
	categories += list(list("id" = BM_CATEGORY_REAGENT_CONTAINERS, "name" = "Reagents", "items" = build_category_items(/obj/item/reagent_containers, list(/obj/item/food))))
	categories += list(list("id" = BM_CATEGORY_FOOD, "name" = "Food", "items" = build_category_items(/obj/item/food)))
	categories += list(list("id" = BM_CATEGORY_MATERIALS, "name" = "Minerals", "items" = build_category_items(/obj/item/stack/sheet)))
	categories += list(list("id" = BM_CATEGORY_GAS, "name" = "Gas", "items" = build_category_items(list(/obj/machinery/portable_atmospherics/canister, /obj/machinery/atmospherics/miner))))

	return categories

/// Вспомогательный прок для сборки предметов с фильтрацией (теперь поддерживает списки путей)
/proc/build_category_items(base_path, list/exclude_paths, check_abstract = FALSE)
	var/list/items = list()
	var/list/paths_to_check = islist(base_path) ? base_path : list(base_path)
	for(var/current_base in paths_to_check)
		for(var/atom/path as anything in subtypesof(current_base))
			var/skip = FALSE
			for(var/ex_path in exclude_paths)
				if(ispath(path, ex_path))
					skip = TRUE
					break
			if(skip)
				continue
			if(check_abstract && IS_ABSTRACT(path))
				continue
			if(!initial(path.icon))
				continue
			if(!initial(path.icon_state) && !ispath(path, /turf))
				continue
			var/item_name = initial(path.name)
			if(!item_name || item_name == "[path]" || item_name == "Default Object")
				continue
			items += list(list("path" = path, "name" = item_name))
	return items

/**
 * Spritesheet for buildmode item browser icons.
 */
/datum/asset/spritesheet_batched/buildmode
	name = "buildmode"

/datum/asset/spritesheet_batched/buildmode/create_spritesheets()
	var/id = 1
	for(var/list/category in GLOB.buildmode_items)
		for(var/list/item in category["items"])
			var/atom/path = item["path"]
			var/datum/universal_icon/icon = uni_icon(initial(path.icon), initial(path.icon_state))
			icon.scale(32, 32)
			insert_icon("bm_[id]", icon)
			item["icon"] = "bm_[id]"
			id++
