/turf/closed/wall/material
	name = "wall"
	desc = "A huge chunk of material used to separate rooms."
	icon = 'icons/turf/walls/material_wall.dmi'
	rcd_memory = null
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/closed/wall/material/break_wall()
	for(var/i in custom_materials)
		var/datum/material/M = i
		new M.sheet_type(src, FLOOR(custom_materials[M] / SHEET_MATERIAL_AMOUNT, 1))
	return new girder_type(src)

/turf/closed/wall/material/devastate_wall()
	for(var/i in custom_materials)
		var/datum/material/M = i
		new M.sheet_type(src, FLOOR(custom_materials[M] / SHEET_MATERIAL_AMOUNT, 1))

/turf/closed/wall/material/finalize_material_effects(list/materials)
	. = ..()
	desc = "A huge chunk of [get_material_english_list(materials)] used to separate rooms."

