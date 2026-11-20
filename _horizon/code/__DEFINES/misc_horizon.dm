// ~ Plane / layer defines for legacy horizon code
/// Plane above the regular game plane - used by blood projectiles for FOV-hidden rendering
#define GAME_PLANE_UPPER (GAME_PLANE + 1)
/// Plane hidden from FOV effects, above GAME_PLANE_UPPER
#define GAME_PLANE_UPPER_FOV_HIDDEN (GAME_PLANE_UPPER + 1)
/// Layer for blood projectiles (above most mobs)
#define BLOOD_PROJECTILE_LAYER (ABOVE_ALL_MOB_LAYER + 0.5)
