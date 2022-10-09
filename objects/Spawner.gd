extends Node2D

#export (Array, PackedScene) var scenes

var RNG = RandomNumberGenerator.new()
var selected_scene_index := 0

const coin_scene := "Coin"
const stone_scene := "Stone"
const trimob_scene := "Trimob"
const obstacle_scene := "Obstacle"

const packed_scenes = [
	"res://objects/Coin.tscn",
	"res://objects/Stone.tscn",
	"res://objects/Trimob.tscn",
	"res://objects/Obstacle.tscn"]
var scenes := []

var objects := []


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("world_stopped", self, "on_world_stopped")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_attack_finished")
# warning-ignore:return_value_discarded
	Signals.connect("objects_ready", self, "on_objects_ready")
	
	for i in packed_scenes.size():
		scenes.append(load(packed_scenes[i]))
	
	RNG.randomize()


func on_objects_ready(initiated_objects: Array) -> void:
#	print(initiated_objects)
	objects = initiated_objects


func on_world_stopped():
	$SpawnTimer.stop()


func on_attack_finished():
	$SpawnTimer.start()


func _on_Timer_timeout():
	selected_scene_index = RNG.randi_range(0, scenes.size() - 1)
	var temp_scene = scenes[selected_scene_index].instance()
	match temp_scene.name:
		coin_scene, trimob_scene:
			temp_scene.translate(Vector2(0, -Globals.SPAWN_LAYER_HEIGHT \
				* rand_range(1, Globals.SPAWN_LAYER_NUM)))
		obstacle_scene:
			temp_scene.init(get_object(obstacle_scene))
	
#	add_child_below_node(self, temp_scene) - was used in tutorial, why?
	add_child(temp_scene)
	
	if temp_scene.name == coin_scene and rand_range(0, 10) > 3:
		spawn_several_coins(temp_scene, selected_scene_index)


func get_object(scene_name: String) -> Dictionary:
	for obj in objects:
		if(obj["type"] == scene_name):
			return obj
	return {}


func spawn_several_coins(first_coin_scene, scene_index: int) -> void:
	var next_coin_scene
	for i in rand_range(1, Globals.SPAWN_COINS_MAX + 1):
		next_coin_scene = scenes[scene_index].instance()
		next_coin_scene.translate(
			Vector2(first_coin_scene.get_position().x + i * 20,
			first_coin_scene.get_position().y))
		add_child(next_coin_scene)
