/obj/item/gun
	/// Assoc list of attachment slot -> how many attachments fit in that slot
	var/list/slot_available = ATTACHMENT_DEFAULT_SLOT_AVAILABLE
	/// Whitelist of attachment types this gun accepts. Defaults to all attachments.
	var/list/valid_attachments = list(/obj/item/attachment)
	/// Assoc list of attachment slot -> list("x" = n, "y" = n) pixel offsets for that slot's overlay.
	var/list/slot_offsets = list(ATTACHMENT_SLOT_RAIL = list("x" = 17, "y" = 17),)
	/// Attachment typepaths this gun spawns with already installed.
	var/list/default_attachments = null
