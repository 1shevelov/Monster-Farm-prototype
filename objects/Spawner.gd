extends Node2D

export (Array, PackedScene) var scenes

var random_scene = RandomNumberGenerator.new()
var selected_scene_index := 0

const coin_scene := "Coin"
const stone_scene := "Stone"


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("world_stopped", self, "on_world_stopped")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_attack_finished")


func on_world_stopped():
	$SpawnTimer.stop()


func on_attack_finished():
	$SpawnTimer.start()


func _on_Timer_timeout():
	random_scene.randomize()
	selected_scene_index = random_scene.randi_range(0, scenes.size() - 1)
	var temp_scene = scenes[selected_scene_index].instance()
	
	if temp_scene.name == coin_scene:
		temp_scene.translate(Vector2(0, -Globals.SPAWN_LAYER_HEIGHT \
			* rand_range(1, Globals.SPAWN_LAYER_NUM)))
	
#	in tutorial was add_child_below_node(self, temp_scene) - Why?
	add_child(temp_scene)

