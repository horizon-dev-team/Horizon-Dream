/* Wall-FOV room sight: server-side counterpart of the client-side wall shadow mask.
 *
 * The visual mask is built from wall shadow sprites: solid walls and closed solid
 * doors cast room shadows, while glass, windows and grilles do not. The logic
 * equivalent is a straight line-of-sight walk blocked by fully opaque turfs
 * (IS_OPAQUE_TURF), which tracks the same sources through turf directional opacity.
 *
 * The sight anchor follows the client's eye (cameras, AI eye) and any pixel pan
 * (binoculars/scope), just like the render planes do, so gating matches what is
 * actually visible on screen.
 */
/proc/wall_fov_room_visible(mob/user, atom/target)
	var/turf/target_turf = get_turf(target)
	if(!user || isnull(target_turf))
		return TRUE

	var/client/user_client = user.canon_client
	var/atom/viewer = user_client.eye || user
	var/turf/viewer_turf = get_turf(viewer)
	if(isnull(viewer_turf) || viewer_turf.z != target_turf.z)
		return TRUE

	var/pan_x = user_client.pixel_x
	var/pan_y = user_client.pixel_y
	if(pan_x || pan_y)
		var/turf/panned_turf = locate(viewer_turf.x + round(pan_x / ICON_SIZE_X, 1), viewer_turf.y + round(pan_y / ICON_SIZE_Y, 1), viewer_turf.z)
		if(panned_turf)
			viewer_turf = panned_turf

	if(viewer_turf == target_turf)
		return TRUE

	for(var/turf/line_turf in get_line(viewer_turf, target_turf))
		if(line_turf == viewer_turf || line_turf == target_turf)
			continue
		if(IS_OPAQUE_TURF(line_turf))
			return FALSE
	return TRUE
