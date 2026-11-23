// ~Attachment slots
#define ATTACHMENT_SLOT_MUZZLE "muzzle"
#define ATTACHMENT_SLOT_SCOPE "scope"
#define ATTACHMENT_SLOT_GRIP "grip"
#define ATTACHMENT_SLOT_RAIL "rail"
#define ATTACHMENT_SLOT_STOCK "stock"

/// Default slot layout of a gun: one attachment per slot.
#define ATTACHMENT_DEFAULT_SLOT_AVAILABLE list( \
	ATTACHMENT_SLOT_MUZZLE = 1, \
	ATTACHMENT_SLOT_SCOPE = 1, \
	ATTACHMENT_SLOT_GRIP = 1, \
	ATTACHMENT_SLOT_RAIL = 1, \
	ATTACHMENT_SLOT_STOCK = 1, \
)

// ~attach_features_flags
/// Attachment can be removed by hand.
#define ATTACH_REMOVABLE_HAND (1<<0)
/// Attachment can be removed with tools.
#define ATTACH_REMOVABLE_TOOL (1<<1)
/// Attachment can be toggled on/off.
#define ATTACH_TOGGLE (1<<2)
/// Attachment has no sprite overlay on the gun.
#define ATTACH_NO_SPRITE (1<<3)
/// Attachment switches the gun's ammo mode when toggled.
#define ATTACH_AMMOMODE (1<<4)

/// Converts an attachment slot name to its bitflag representation.
/proc/attachment_slot_to_bflag(slot)
	switch(slot)
		if(ATTACHMENT_SLOT_MUZZLE)
			return (1<<0)
		if(ATTACHMENT_SLOT_SCOPE)
			return (1<<1)
		if(ATTACHMENT_SLOT_GRIP)
			return (1<<2)
		if(ATTACHMENT_SLOT_RAIL)
			return (1<<3)
		if(ATTACHMENT_SLOT_STOCK)
			return (1<<4)

/// Converts an attachment slot bitflag back to its name.
/proc/attachment_slot_from_bflag(slot)
	switch(slot)
		if((1<<0))
			return ATTACHMENT_SLOT_MUZZLE
		if((1<<1))
			return ATTACHMENT_SLOT_SCOPE
		if((1<<2))
			return ATTACHMENT_SLOT_GRIP
		if((1<<3))
			return ATTACHMENT_SLOT_RAIL
		if((1<<4))
			return ATTACHMENT_SLOT_STOCK
