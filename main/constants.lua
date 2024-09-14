GLOBAL.setfenv(1, GLOBAL)

TOOLACTIONS.HACK = true
TOOLACTIONS.PAN = true
TOOLACTIONS.SHEAR = true
TOOLACTIONS.DISLODGE = true
TOOLACTIONS.SPY = true
TOOLACTIONS.GAS = true

SEASONS.TEMPERATE = "temperate"
SEASONS.HUMID = "humid"
SEASONS.LUSH = "lush"
SEASONS.APORKALYPSE = "aporkalypse"

BOATEQUIPSLOTS = {
    BOAT_SAIL = "sail",
    BOAT_LAMP = "lamp",
}

FOG_STATE = {
    SETTING = 1,
    FOGGY = 2,
    LIFTING = 3,
    CLEAR = 4,
}

FOODTYPE.GOLDDUST = "GOLDDUST"

COLLISION.VOID_LIMITS = 2 -- IA uses 1
COLLISION.GROUND = COLLISION.GROUND + COLLISION.VOID_LIMITS
COLLISION.WORLD = COLLISION.WORLD + COLLISION.VOID_LIMITS

WORLD_TILES.INTERIOR = WORLD_TILES.INVALID - 1
INVERTED_WORLD_TILES[WORLD_TILES.INTERIOR] = "INTERIOR"

INTERIOR_QUAKE_LEVELS = {
    PILLAR_WORKED = 1,
    PILLAR_DESTROYED = 2,
    QUEEN_ATTACK = 3,
    MINOR_QUAKE = 4,
    ANTHILL_REBUILT = 5,
}

AREAMODES = {
    DISTANCE = 0,
    ROOM = 1
}

ISLAND_TAGS = {
    "island_accademy",
    "island_royal",
    "island_pugalisk",
    "island_BFB",
    "island_ancient",
}

NUTRIENT_TILES = {
    [WORLD_TILES.PLAINS] = true,
    [WORLD_TILES.RAINFOREST] = true,
    [WORLD_TILES.DEEPRAINFOREST] = true,
    [WORLD_TILES.DEEPRAINFOREST_NOCANOPY] = true,
}

FUELTYPE.CORK = "CORK"
FUELTYPE.ANCIENT_REMNANT = "ANCIENT_REMNANT"

TECH.CITY = {
    CITY = 2
}

TECH.HOME = {
    HOME = 2
}

-- Just an arbitrary number
BUILDMODE.HOME_DECOR = 10

LOCKTYPE.ROYAL = "royal"

-- City pigman is dont in pigman_city.lua

NAUGHTY_VALUE["hippopotamoose"] = 4
NAUGHTY_VALUE["pangolden"] = 4

NAUGHTY_VALUE["dungbeetle"] = 3
NAUGHTY_VALUE["mandrakeman"] = 3
NAUGHTY_VALUE["peagawk"] = 3

NAUGHTY_VALUE["kingfisher"] = 2
NAUGHTY_VALUE["piko_orange"] = 2
NAUGHTY_VALUE["pog"] = 2

NAUGHTY_VALUE["glowfly"] = 1
NAUGHTY_VALUE["pigeon"] = 1
NAUGHTY_VALUE["piko"] = 1
