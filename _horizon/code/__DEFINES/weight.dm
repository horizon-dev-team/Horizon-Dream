#define ENCUMBRANCE_NONE 0
#define ENCUMBRANCE_LIGHT 1
#define ENCUMBRANCE_MEDIUM 2
#define ENCUMBRANCE_HEAVY 3
#define ENCUMBRANCE_EXTREME 4

#define GRAMS * 0.001
#define KILOGRAMS * 1

/// Weight of an average human in kgs
#define HUMAN_WEIGHT 60
/// Weight required for someone to fall in water
#define DROWNING_WEIGHT (HUMAN_WEIGHT * 2)

/// Basic lift (kg) of a carbon in perfect shape. Original: STR^2/10 via attributes, STR 10 -> 10.
#define ENCUMBRANCE_DEFAULT_BASIC_LIFT 10
/// maximum_carry_weight is this many times the basic lift.
#define ENCUMBRANCE_MAXIMUM_PER_LIFT 10
/// Base move-delay used to scale encumbrance slowdown. Tunable.
#define ENCUMBRANCE_BASIC_SLOWDOWN 1.5
/// Refresh cadence for content changes that emit no mob signal (ammo, storage, reagents).
#define ENCUMBRANCE_REFRESH_INTERVAL (2 SECONDS)

/// Mass in kg of one reagent unit, so full containers and food are not weightless.
#define REAGENT_UNIT_KG 0.01

// Needs <-> weight link.
// Share of the basic lift a carbon keeps while thirsty or hungry. The worse of the two applies.
#define LIFT_MULT_THIRSTY 0.8
#define LIFT_MULT_DEHYDRATED 0.6
#define LIFT_MULT_HUNGRY 0.9
#define LIFT_MULT_VERY_HUNGRY 0.8
#define LIFT_MULT_STARVING 0.65

// How much faster hunger and thirst drain per step at each encumbrance level.
#define NEEDS_DRAIN_MULT_NONE 1
#define NEEDS_DRAIN_MULT_LIGHT 1.1
#define NEEDS_DRAIN_MULT_MEDIUM 1.25
#define NEEDS_DRAIN_MULT_HEAVY 1.5
#define NEEDS_DRAIN_MULT_EXTREME 2
