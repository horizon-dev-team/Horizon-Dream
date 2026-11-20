/proc/weight_class_to_icon(w_class, user, actually_readable = FALSE)
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			w_class = "Tiny"
		if(WEIGHT_CLASS_SMALL)
			w_class = "Small"
		if(WEIGHT_CLASS_NORMAL)
			w_class = "Normal"
		if(WEIGHT_CLASS_BULKY)
			w_class = "Bulky"
		if(WEIGHT_CLASS_HUGE)
			w_class = "Huge"
		if(WEIGHT_CLASS_GIGANTIC)
			w_class = "Gigantic"
	if(actually_readable)
		return "[icon2html(DAMAGE_ICON_SET, user, w_class)] [w_class]"
	return icon2html(DAMAGE_ICON_SET, user, w_class)
