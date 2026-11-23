// horizon-dev-sync[bot] rewrite of the Shiptest-derived gun attachment system.
//
// The system is built from two components that talk through direct proc calls
// instead of a custom signal bus:
//   /datum/component/attachment_mount - lives on the gun, owns the installed attachments
//   /datum/component/gun_attachment   - lives on the attachment item, holds its behaviour
// See _horizon/code/datums/components/gun_attachment.dm for how to add a new attachment.

// =============================================================================
// SLOTS
// =============================================================================

#define ATTACHMENT_SLOT_MUZZLE "muzzle"
#define ATTACHMENT_SLOT_SCOPE "scope"
#define ATTACHMENT_SLOT_GRIP "grip"
#define ATTACHMENT_SLOT_RAIL "rail"
#define ATTACHMENT_SLOT_STOCK "stock"

/// Default slot capacity of a gun: one attachment per slot.
#define ATTACHMENT_DEFAULT_SLOT_AVAILABLE list( \
	ATTACHMENT_SLOT_MUZZLE = 1, \
	ATTACHMENT_SLOT_SCOPE = 1, \
	ATTACHMENT_SLOT_GRIP = 1, \
	ATTACHMENT_SLOT_RAIL = 1, \
	ATTACHMENT_SLOT_STOCK = 1, \
)

// =============================================================================
// FEATURE FLAGS (/datum/component/gun_attachment::feature_flags)
// =============================================================================

/// Can be removed with an empty-handed alt-click.
#define ATTACH_REMOVABLE_HAND (1<<0)
/// Can be removed by prying with a crowbar.
#define ATTACH_REMOVABLE_TOOL (1<<1)
/// Has an on/off state, a toggle action button and a ctrl-shift-click radial entry.
#define ATTACH_TOGGLE (1<<2)
/// Draws no overlay on the gun.
#define ATTACH_NO_SPRITE (1<<3)

// =============================================================================
// HOOK FLAGS (/datum/component/gun_attachment::hook_flags)
// An attachment sets the hooks it implements. The mount only listens for the
// matching engine signal on the gun while at least one installed attachment
// asked for it.
// =============================================================================

/// on_try_fire(): return TRUE to cancel the shot.
#define ATTACH_HOOK_FIRE (1<<0)
/// on_wield(): return TRUE to block wielding.
#define ATTACH_HOOK_WIELD (1<<1)
/// on_unwield()
#define ATTACH_HOOK_UNWIELD (1<<2)
/// on_pre_attack_secondary(): return TRUE to cancel the attack chain.
#define ATTACH_HOOK_PRE_ATTACK_SECONDARY (1<<3)
/// on_attack_hand_secondary(): return TRUE to cancel the attack chain.
#define ATTACH_HOOK_ATTACK_HAND_SECONDARY (1<<4)
/// on_attackby_secondary(): return TRUE to cancel the attack chain.
#define ATTACH_HOOK_ATTACKBY_SECONDARY (1<<5)
/// on_ctrl_click(): return TRUE if the click was handled.
#define ATTACH_HOOK_CTRL_CLICK (1<<6)

/// How long taking an attachment off a gun takes.
#define ATTACHMENT_DETACH_TIME (2 SECONDS)
