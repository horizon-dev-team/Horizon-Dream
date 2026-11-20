/datum/element/cutting_tool_target
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/cutting_tool_target/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(on_welder_act))

/datum/element/cutting_tool_target/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER))

/datum/element/cutting_tool_target/proc/on_welder_act(atom/source, mob/living/user, obj/item/tool, list/recipes)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(tool, TRAIT_CUTTING_TOOL))
		return NONE
	return source.deconstruct_act(user, tool)
