/atom/movable/screen/background_hud
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/background_hud/human
	icon = '_horizon/icons/ui/screen_background.dmi'
	icon_state = "background"
	screen_loc = ui_stamina

/atom/movable/screen/background_hud/battery
	icon_state = "status_battery"
	screen_loc = ui_spacesuit
	alpha = 0

/// Decorations so the frame
/atom/movable/screen/background_hud/edge
	layer = 3.05 // Magic number, but it's fucking simple. Define/undef here is just overkill.

/atom/movable/screen/background_hud/edge/top
	icon_state = "status_up"
	screen_loc = ui_healthdoll_edge

/atom/movable/screen/background_hud/edge/bottom
	icon_state = "status_down"
	screen_loc = ui_stamina

// Re-desing style screen HUD icons
/atom/movable/screen/healthdoll/human
	icon = '_horizon/icons/ui/screen_gen.dmi'

/atom/movable/screen/healthdoll_limb
	icon = '_horizon/icons/ui/screen_limb.dmi'

/atom/movable/screen/healths/human
	icon = '_horizon/icons/ui/screen_health_human.dmi'

/atom/movable/screen/spacesuit
	icon = '_horizon/icons/ui/screen_gen.dmi'

/atom/movable/screen/stamina
	icon = '_horizon/icons/ui/screen_gen.dmi'
	icon_state = "stamina_0"

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

// Gas alerts
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

// Other alerts
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

/atom/movable/screen/alert/buckled
	icon = '_horizon/icons/ui/screen_alert.dmi'
	overlay_icon = '_horizon/icons/ui/screen_alert.dmi'
