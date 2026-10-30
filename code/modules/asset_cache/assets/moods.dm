/datum/asset/spritesheet_batched/moods
	name = "moods"

/datum/asset/spritesheet_batched/moods/create_spritesheets()
	var/list/mood_colors = list(
		"mood1" = "#f7595a",
		"mood2" = "#d5a862",
		"mood3" = "#cbd562",
		"mood4" = "#75d562",
		"mood5" = "#2d4e93",
		"mood6" = "#4884cf",
		"mood7" = "#61cef2",
		"mood8" = "#61cef2",
		"mood9" = "#61cef2",
	)
	for(var/target_to_insert in mood_colors)
		var/blended_color = mood_colors[target_to_insert]
		insert_icon(target_to_insert, uni_icon('_horizon/icons/ui/screen_gen.dmi', target_to_insert, color=blended_color))
