extends Node2D

#export (Array, PackedScene) var scenes

var random_scene = RandomNumberGenerator.new()
var selected_scene_index := 0

const coin_scene := "Coin"
const stone_scene := "Stone"
const trimob_scene := "Trimob"

const objects_scenes = [
	"res://objects/Coin.tscn",
	"res://objects/Stone.tscn",
	"res://objects/Trimob.tscn"]
	
var scenes = []


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("world_stopped", self, "on_world_stopped")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_attack_finished")
# warning-ignore:return_value_discarded
	Signals.connect("object_created", self, "on_object_created")
	
	for i in objects_scenes.size():
		scenes.append(load(objects_scenes[i]))


func on_object_created(new_object: String) -> void:
#	print(new_object)
	scenes.append(load(new_object))


func on_world_stopped():
	$SpawnTimer.stop()


func on_attack_finished():
	$SpawnTimer.start()


func _on_Timer_timeout():
	random_scene.randomize()
	selected_scene_index = random_scene.randi_range(0, scenes.size() - 1)
	var temp_scene = scenes[selected_scene_index].instance()
	
	if temp_scene.name == coin_scene or temp_scene.name == trimob_scene:
		temp_scene.translate(Vector2(0, -Globals.SPAWN_LAYER_HEIGHT \
			* rand_range(1, Globals.SPAWN_LAYER_NUM)))
	
#	in tutorial was add_child_below_node(self, temp_scene) - Why?
	add_child(temp_scene)
	
#	spawn several coins
	if temp_scene.name == coin_scene and rand_range(0, 10) > 3:
		var coin_scene
		for i in rand_range(1, Globals.SPAWN_COINS_MAX + 1):
			coin_scene = scenes[selected_scene_index].instance()
			coin_scene.translate(Vector2(temp_scene.get_position().x + i * 20, \
				temp_scene.get_position().y))
			add_child(coin_scene)


