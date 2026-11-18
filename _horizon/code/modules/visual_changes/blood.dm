/atom/proc/blood_particles(mob/living/carbon/H)
	var/debris = "drip"
	var/debris_velocity = rand(5,10)
	var/debris_amount = 10
	var/debris_scale = 0.7
	var/new_direction = dir2angle(H.dir)
	var/x_component = sin(new_direction) * debris_velocity
	var/y_component = cos(new_direction) * debris_velocity
	var/obj/effect/abstract/particle_holder/blood_visuals
	var/position_offset = rand(-1,1)

	blood_visuals = new(src, /particles/debris)
	blood_visuals.particles.icon_state = debris
	blood_visuals.particles.position = generator(GEN_CIRCLE, position_offset, position_offset)
	blood_visuals.particles.velocity = list(x_component, y_component)
	blood_visuals.color ="#770000"
	blood_visuals.layer = CHAT_LAYER
	blood_visuals.particles.count = debris_amount
	blood_visuals.particles.spawning = debris_amount
	blood_visuals.particles.scale = debris_scale
	addtimer(CALLBACK(src, PROC_REF(remove_blood_particles), blood_visuals), 0.7 SECONDS)

/atom/proc/remove_blood_particles(obj/effect/abstract/particle_holder/blood_visuals)
	if(blood_visuals)
		QDEL_NULL(blood_visuals)

/// Cleanup helper for visual_effect(): removes the smoke / debris particle
/// holders after the effect finishes. Lives here (not in the gun module)
/// because it is called on arbitrary atoms hit by projectiles.
/atom/proc/remove_ping(obj/effect/abstract/particle_holder/smoke_visuals, obj/effect/abstract/particle_holder/debris_visuals)
	QDEL_NULL(smoke_visuals)
	if(debris_visuals)
		QDEL_NULL(debris_visuals)

/atom/proc/visual_effect(var/obj/projectile/P, var/debris = DEBRIS_SPARKS)
	var/debris_velocity = -15
	if(debris == "drip")
		debris_velocity = 15
	var/debris_amount = 8
	var/debris_scale = 0.7
	var/x_component = sin(P.angle) * debris_velocity
	var/y_component = cos(P.angle) * debris_velocity
	var/x_component_smoke = sin(P.angle) * -15
	var/y_component_smoke = cos(P.angle) * -15
	var/obj/effect/abstract/particle_holder/debris_visuals
	var/obj/effect/abstract/particle_holder/smoke_visuals
	var/position_offset = rand(-6,6)
	if(debris != "drip")
		smoke_visuals = new(src, /particles/impact_smoke)
		smoke_visuals.particles.position = list(position_offset, position_offset)
		smoke_visuals.particles.velocity = list(x_component_smoke, y_component_smoke)
		smoke_visuals.layer = ABOVE_OBJ_LAYER + 0.01

	debris_visuals = new(src, /particles/debris)
	if(debris == "drip")
		debris_visuals.color ="#770000"
	debris_visuals.particles.position = generator(GEN_CIRCLE, position_offset, position_offset)
	debris_visuals.particles.velocity = list(x_component, y_component)
	debris_visuals.layer = ABOVE_OBJ_LAYER + 0.02
	debris_visuals.particles.icon_state = debris
	debris_visuals.particles.count = debris_amount
	debris_visuals.particles.spawning = debris_amount
	debris_visuals.particles.scale = debris_scale
	addtimer(CALLBACK(src, PROC_REF(remove_ping), smoke_visuals, debris_visuals), 0.7 SECONDS)
