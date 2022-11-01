extends Node

const RUN_WORLD_SPEED := 10.0
const ZERO_WORLD_SPEED := 0.0001
const DASH_WORLD_SPEED := 1.5 * RUN_WORLD_SPEED
var world_speed := ZERO_WORLD_SPEED

const SPAWN_LAYER_NUM := 2
const SPAWN_LAYER_HEIGHT := 80 # in pixels

const SPAWN_COINS_MAX := 5

#const INITIAL_SCORE := 0

# checked before playing every sound
const SILENT_MODE := true

var MONEY_PER_COIN := 10
const INITIAL_MONEY := 0


const AVATAR_NODE_NAME = "Avatar"

const OBJECTS_NAMES = [
	"Coin",
	"Obstacle",
	"OneHitMon",
	"Mob"
]
