/particles/leaves
	icon = '_horizon/icons/obj/flora/leaves.dmi'
	icon_state = list("leaf1", "leaf2", "leaf3", "leaf4", "leaf5")
	width = 256
	height = 256
	count = 50
	spawning = 0.035
	lifespan = 10 SECONDS
	fadein = 1 SECONDS
	fade = 2.5 SECONDS
	position = generator("box", list(0, 92, 0), list(120, 64, 0), "SQUARE_RAND")
	gravity = list(0, -0.3)
	drift = generator("vector", list(-1, 0, 0), list(1, 0, 0), "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")
	friction = 0.3

/particles/leaves/hit
	count = 8
	spawning = 6
	position = generator("box", list(-48, 92, 0), list(48, 44, 0), "SQUARE_RAND")

// Small
/particles/leaves/small
	lifespan = 50
	position = generator("box", list(0, 80, 0), list(120, 32, 0), "SQUARE_RAND")

/particles/leaves/small/hit
	count = 8
	spawning = 6
	position = generator("box", list(-32, 80, 0), list(64, 32, 0), "SQUARE_RAND")

// Cherry
/particles/leaves/cherry
	icon = '_horizon/icons/obj/flora/leaves_cherry.dmi'

/particles/leaves/cherry/hit
	count = 8
	spawning = 6
	position = generator("box", list(-48, 92, 0), list(48, 44, 0), "SQUARE_RAND")
