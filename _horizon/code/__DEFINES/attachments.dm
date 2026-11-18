// horizon-dev-sync[bot] port from Shiptest
// Attachment system defines, components, and items.
// Ported from Shiptest's attachment system.

// =============================================================================
// DEFINES
// =============================================================================

#define TRAIT_ATTACHABLE "attachable"

// Attachment signals
#define COMSIG_ATTACHMENT_ATTACH "attach-attach"
#define COMSIG_ATTACHMENT_DETACH "attach-detach"
#define COMSIG_ATTACHMENT_EXAMINE "attach-examine"
#define COMSIG_ATTACHMENT_TRY_FIRE_GUN "attach-try-fire-gun"
#define COMSIG_ATTACHMENT_PRE_ATTACK "attach-pre-attack"
#define COMSIG_ATTACHMENT_ATTACK "attach-attacked"
#define COMSIG_ATTACHMENT_WIELD "attach-wield"
#define COMSIG_ATTACHMENT_UNWIELD "attach-unwield"
#define COMSIG_ATTACHMENT_UPDATE_OVERLAY "attach-overlay"
#define COMSIG_ATTACHMENT_CTRL_CLICK "attach-ctrl-click"
#define COMSIG_ATTACHMENT_ALT_CLICK "attach-alt-click"
#define COMSIG_ATTACHMENT_ATTACK_HAND "attach-attack-hand"
#define COMSIG_ATTACHMENT_TOGGLE "attach-toggle"
#define COMSIG_ATTACHMENT_TOGGLE_AMMO "attach-ammo"
#define COMSIG_ATTACHMENT_GET_SLOT "attach-slot-who"
#define COMSIG_ATTACHMENT_CHANGE_SLOT "change_attach_slot"


// Slots
#define ATTACHMENT_SLOT_MUZZLE "muzzle"
#define ATTACHMENT_SLOT_SCOPE "scope"
#define ATTACHMENT_SLOT_GRIP "grip"
#define ATTACHMENT_SLOT_RAIL "rail"
#define ATTACHMENT_SLOT_STOCK "stock"

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

/proc/attachment_slot_from_bflag(slot)
	switch(slot)
		if(1<<0)
			return ATTACHMENT_SLOT_MUZZLE
		if(1<<1)
			return ATTACHMENT_SLOT_SCOPE
		if(1<<2)
			return ATTACHMENT_SLOT_GRIP
		if(1<<3)
			return ATTACHMENT_SLOT_RAIL
		if(1<<4)
			return ATTACHMENT_SLOT_STOCK

#define ATTACHMENT_DEFAULT_SLOT_AVAILABLE list( \
	ATTACHMENT_SLOT_MUZZLE = 1, \
	ATTACHMENT_SLOT_SCOPE = 1, \
	ATTACHMENT_SLOT_GRIP = 1, \
	ATTACHMENT_SLOT_RAIL = 1, \
	ATTACHMENT_SLOT_STOCK = 1, \
)

// attach_features_flags
#define ATTACH_REMOVABLE_HAND (1<<0)
#define ATTACH_REMOVABLE_TOOL (1<<1)
#define ATTACH_TOGGLE (1<<2)
#define ATTACH_NO_SPRITE (1<<3)
#define ATTACH_AMMOMODE (1<<4)
