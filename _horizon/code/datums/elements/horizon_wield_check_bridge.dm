/datum/element/horizon_wield_check_bridge
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/horizon_wield_check_bridge/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_TWOHANDED_WIELD_CHECK, PROC_REF(on_wield_check))

/datum/element/horizon_wield_check_bridge/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_TWOHANDED_WIELD_CHECK)

/datum/element/horizon_wield_check_bridge/proc/on_wield_check(datum/source)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_WIELDED))
		return COMPONENT_TWOHANDED_WIELDED
	return NONE

/obj/item/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/horizon_wield_check_bridge)
