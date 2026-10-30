/atom/movable/screen/human_hud_background
	icon = '_horizon/icons/ui/screen_background.dmi'
	icon_state = "background"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = ui_stamina

/// Decorations so the frame
/atom/movable/screen/human_hud_edge
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = 3.05 // Magic number, but it's fucking simple. Define/undef here is just overkill.

/atom/movable/screen/human_hud_edge/top
	icon_state = "status_up"
	screen_loc = ui_healthdoll_edge

/atom/movable/screen/human_hud_edge/bottom
	icon_state = "status_down"
	screen_loc = ui_stamina

/atom/movable/screen/healthdoll/human
	icon = '_horizon/icons/ui/screen_gen.dmi'

/atom/movable/screen/healthdoll_limb
	icon = '_horizon/icons/ui/screen_limb.dmi'

/atom/movable/screen/healths/human
	icon = '_horizon/icons/ui/screen_health_human.dmi'


//End gas alerts
/*
/atom/movable/screen/alert/gross
	name = "Grossed out."
	desc = "That was kind of gross..."
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "gross"

/atom/movable/screen/alert/verygross
	name = "Very grossed out."
	desc = "You're not feeling very well..."
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "gross2"

/atom/movable/screen/alert/disgusted
	name = "DISGUSTED"
	desc = "ABSOLUTELY DISGUSTIN'"
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "gross3"
*/

/atom/movable/screen/alert/fire
	icon = '_horizon/icons/ui/screen_alert.dmi'
	icon_state = "fire"

// Temperature
/atom/movable/screen/alert/hot
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/cold
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/lowpressure
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/highpressure
	icon = '_horizon/icons/ui/screen_alert.dmi'

/* Gas alerts are continuously thrown/cleared by:
 * /obj/item/organ/lungs/proc/check_breath()
 * /mob/living/carbon/check_breath()
 * /mob/living/carbon/human/check_breath()
 * /datum/element/atmos_requirements/proc/on_non_stasis_life()
 * /mob/living/simple_animal/handle_environment()
 */

/atom/movable/screen/alert/status_effect/hypernob_protection
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/not_enough_oxy
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/too_much_oxy
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/not_enough_nitro
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/too_much_nitro
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/not_enough_co2
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/too_much_co2
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/not_enough_plas
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/too_much_plas
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/not_enough_n2o
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/too_much_n2o
	icon = '_horizon/icons/ui/screen_alert.dmi'

/atom/movable/screen/alert/not_enough_water
	icon = '_horizon/icons/ui/screen_alert.dmi'


/atom/movable/screen/alert/highgravity
	icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_state = "paralysis"

/atom/movable/screen/alert/veryhighgravity
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "paralysis"

/atom/movable/screen/alert/status_effect/drunk
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "drunk2"

/atom/movable/screen/alert/status_effect/blind
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "blind"

/atom/movable/screen/alert/tazed
	icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_state = "stun"

// weaken
/atom/movable/screen/alert/weightless
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "weightless"

/atom/movable/screen/alert/negative
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "negative"

/atom/movable/screen/alert/status_effect/convulsing
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "convulsing"

/atom/movable/screen/alert/status_effect/surrender
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "surrender"

/atom/movable/screen/alert/status_effect/woozy
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "woozy"

/atom/movable/screen/alert/status_effect/terrified
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_state = "terrified"

/*
/// Gives the player the option to succumb while in critical condition
/atom/movable/screen/alert/succumb
	name = "Succumb"
	desc = "Shuffle off this mortal coil."
	use_user_hud_icon = USER_HUD_STYLE_IGNORE
	overlay_icon = 'icons/mob/simple/mob.dmi'
	overlay_state = "ghost"
	clickable_glow = TRUE
	var/static/list/death_titles = list(
		"Goodnight, Sweet Prince",
		"Game Over, Man",
		"End Of The Road",
		"Live Long And Prosper",
		"See You Space Cowboy...",
		"It's Been An Honor",
		"The Curtains Close",
		"All Good Things Must End"
	)
*/

/atom/movable/screen/alert/buckled
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
