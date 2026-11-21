// horizon-dev-sync[bot] port
// Signals missing from upstream /tg/station codebase but referenced by
// horizon mechanics (projectile embedding, gunpoint, storage, wound messages,
// two-handed wield check).

// ~ Gun ammo HUD
/// Sent to gun to update the ammo HUD overlay. (gun)
#define COMSIG_UPDATE_AMMO_HUD "update_ammo_hud"

// ~ Two-handed wield check
/// Sent to a two-handed item to ask whether it is currently wielded with both hands.
/// Returns COMPONENT_TWOHANDED_WIELDED when wielded.
#define COMSIG_TWOHANDED_WIELD_CHECK "twohanded_wield_check"
/// Returned by two-handed items when they ARE currently wielded in both hands.
#define COMPONENT_TWOHANDED_WIELDED (1<<0)

// ~ Projectile embedding
/// From base of /obj/projectile/proc/process_hit(): sent to projectile when it tries to embed in a target.
/// (firer, target, result, mode)
#define COMSIG_PROJECTILE_TRY_EMBED "projectile_try_embed"
/// Returned by the embed handler when the projectile successfully embeds.
#define COMPONENT_EMBED_SUCCESS (1<<0)
/// Returned by the embed handler when the projectile fails to embed.
#define COMPONENT_EMBED_FAILURE (1<<1)
/// Returned by the embed handler when the projectile was stopped by armor.
#define COMPONENT_EMBED_STOPPED_BY_ARMOR (1<<2)
/// Returned by the embed handler when the projectile went through the target.
#define COMPONENT_EMBED_WENT_THROUGH (1<<3)

// ~ Carbon wound messages (legacy wound overlay API)
/// Sent to carbon mob to add a wound message to its overlay. (message)
#define COMSIG_CARBON_ADD_TO_WOUND_MESSAGE "carbon_add_to_wound_message"
/// Sent to carbon mob to clear all pending wound messages.
#define COMSIG_CARBON_CLEAR_WOUND_MESSAGE "carbon_clear_wound_message"

// ~ Storage (legacy /datum/component/storage signals)
/// Sent when an item enters a storage datum. (item)
#define COMSIG_STORAGE_ENTERED "storage_entered"
/// Sent when an item exits a storage datum. (item)
#define COMSIG_STORAGE_EXITED "storage_exited"
/// Sent to ask whether an atom contains storage. Returns COMPONENT_CONTAINS_STORAGE.
#define COMSIG_CONTAINS_STORAGE "contains_storage"
/// Returned from COMSIG_CONTAINS_STORAGE to indicate storage is present.
#define COMPONENT_CONTAINS_STORAGE (1<<0)
