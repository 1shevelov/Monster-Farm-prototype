extends Node

# this is an endless scroller
const DEFAULT_WORLD_SPEED := 10.0
const ZERO_WORLD_SPEED := 0.0001
var world_speed := DEFAULT_WORLD_SPEED

const SPAWN_LAYER_NUM := 2
const SPAWN_LAYER_HEIGHT := 80 # in pixels


#const INITIAL_SCORE := 0

# checked before playing every sound
const SILENT_MODE := true

const STONE_HEALTH_MIN := 28
const STONE_HEALTH_MAX := 48

var MONEY_PER_COIN := 10
const INITIAL_MONEY := 0
