/obj/item/gun
	/// If set, shows a gunshot overlay when firing. Format: list("icon" = ..., "icon_state" = ..., "pixel_x" = ..., "pixel_y" = ..., "duration" = ..., "inactive_when_suppressed" = TRUE/FALSE)
	var/list/gunshot_animation_information = null
	/// If set, plays a recoil animation when firing. Format: list("recoil_angle_upper" = ..., "recoil_angle_lower" = ..., "recoil_speed" = ..., "return_speed" = ...)
	var/list/recoil_animation_information = null
	/// If set, applies client-side camera recoil when firing. Format: list("strength" = ..., "duration" = ..., "easing" = ...)
	var/list/client_recoil_animation_information = null
	var/doing_recoil_burst_animation = FALSE

/// Plays gunshot overlay + recoil animation.
/obj/item/gun/proc/firing_animation(mob/user, burst_fire = FALSE)
	if(gunshot_animation_information)
		INVOKE_ASYNC(src, PROC_REF(gunshot_animation), user, burst_fire)
	if(recoil_animation_information)
		INVOKE_ASYNC(src, PROC_REF(recoil_animation), user, burst_fire)

/// Shows a muzzle flash overlay on the gun for a few ticks. Suppressed guns
/// skip it when "inactive_when_suppressed" is set in the animation info.
/obj/item/gun/proc/gunshot_animation(mob/user, burst_fire = FALSE)
	if(suppressed && LAZYACCESS(gunshot_animation_information, "inactive_when_suppressed"))
		return
	var/shot_icon = gunshot_animation_information["icon"] || '_horizon/icons/effects/gunshot.dmi'
	var/shot_icon_state = gunshot_animation_information["icon_state"] || "gunshot"
	var/shot_duration = gunshot_animation_information["duration"] || 2
	var/shot_pixel_x = gunshot_animation_information["pixel_x"] || 0
	var/shot_pixel_y = gunshot_animation_information["pixel_y"] || 0
	var/image/shots_fired = image(shot_icon, shot_icon_state, src, src.layer - 0.01)
	shots_fired.pixel_x = shot_pixel_x
	shots_fired.pixel_y = shot_pixel_y
	add_overlay(shots_fired)
	sleep(shot_duration)
	cut_overlay(shots_fired)

/// Rotates the gun slightly on fire, then returns to original position.
/obj/item/gun/proc/recoil_animation(mob/user, burst_fire = FALSE)
	if(doing_recoil_burst_animation)
		return
	if(burst_fire)
		return recoil_animation_burst(user)
	var/recoil_angle_upper = recoil_animation_information["recoil_angle_upper"] || -20
	var/recoil_angle_lower = recoil_animation_information["recoil_angle_lower"] || -40
	var/recoil_speed = recoil_animation_information["recoil_speed"] || 2
	var return_speed = recoil_animation_information["return_speed"] || 2
	var/recoil_easing = recoil_animation_information["recoil_easing"] || ELASTIC_EASING
	var/return_easing = recoil_animation_information["return_easing"] || ELASTIC_EASING
	var/matrix/return_matrix = matrix(transform)
	var/matrix/recoil_matrix = matrix(transform)
	recoil_matrix = recoil_matrix.Turn(rand(recoil_angle_lower, recoil_angle_upper))

	animate(src, transform = recoil_matrix, time = recoil_speed, easing = recoil_easing)
	sleep(recoil_speed)
	animate(src, transform = return_matrix, time = return_speed, easing = return_easing)

/// Burst fire recoil: more violent, with pixel offset.
/obj/item/gun/proc/recoil_animation_burst(mob/user)
	var/recoil_burst_angle_upper = recoil_animation_information["recoil_burst_angle_upper"] || -5
	var/recoil_burst_angle_lower = recoil_animation_information["recoil_burst_angle_lower"] || -10
	var/recoil_burst_speed = recoil_animation_information["recoil_burst_speed"] || 0.5
	var/return_burst_speed = recoil_animation_information["return_burst_speed"] || 0.5
	var/recoil_burst_easing = recoil_animation_information["recoil_burst_easing"] || ELASTIC_EASING
	var/return_burst_easing = recoil_animation_information["return_burst_easing"] || ELASTIC_EASING
	var/recoil_burst_pixel_x = recoil_animation_information["recoil_burst_pixel_x"] || -5
	var/recoil_burst_pixel_y = recoil_animation_information["recoil_burst_pixel_y"] || 0
	var/old_pixel_x = pixel_x
	var/new_pixel_x = pixel_x+recoil_burst_pixel_x
	var/old_pixel_y = pixel_y
	var/new_pixel_y = pixel_y+recoil_burst_pixel_y
	var/matrix/return_matrix = matrix(transform)
	var/matrix/recoil_matrix = matrix(transform)
	recoil_matrix = recoil_matrix.Turn(rand(recoil_burst_angle_lower, recoil_burst_angle_upper))
	doing_recoil_burst_animation = TRUE
	for(var/i in 1 to burst_size)
		animate(src, transform = recoil_matrix, time = recoil_burst_speed, easing = recoil_burst_easing, flags = ANIMATION_PARALLEL)
		animate(src, pixel_x = new_pixel_x, time = recoil_burst_speed, easing = recoil_burst_easing, flags = ANIMATION_PARALLEL)
		animate(src, pixel_y = new_pixel_y, time = recoil_burst_speed, easing = recoil_burst_easing, flags = ANIMATION_PARALLEL)
		sleep(recoil_burst_speed)
		animate(src, transform = return_matrix, pixel_x = old_pixel_x, pixel_y = old_pixel_y, time = return_burst_speed, easing = return_burst_easing, flags = ANIMATION_PARALLEL)
		animate(src, pixel_x = old_pixel_x, time = return_burst_speed, easing = return_burst_easing, flags = ANIMATION_PARALLEL)
		animate(src, pixel_y = old_pixel_y, time = return_burst_speed, easing = return_burst_easing, flags = ANIMATION_PARALLEL)
		sleep(return_burst_speed)
	doing_recoil_burst_animation = FALSE
