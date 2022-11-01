extends Node2D

#export (Array, PackedScene) var scenes

var RNG = RandomNumberGenerator.new()
var selected_scene_index := 0

const coin_scene := "Coin"
const onehitmob_scene := "OneHitMob"
const obstacle_scene := "Obstacle"

const packed_scenes = [
	"res://objects/Coin.tscn",
	"res://objects/OneHitMob.tscn",
	"res://objects/Obstacle.tscn"]
var scenes := []

var objects := []


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("world_stopped", self, "on_world_stopped")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_attack_finished")
# warning-ignore:return_value_discarded
#	Signals.connect("objects_ready", self, "on_objects_ready")
	
	for i in packed_scenes.size():
		scenes.append(load(packed_scenes[i]))
	
	RNG.randomize()


func set_objects(world_objects: Array) -> void:
	objects = world_objects
#	print_debug(objects)


func on_world_stopped():
	$SpawnTimer.stop()


func on_attack_finished():
	$SpawnTimer.start()


func _on_Timer_timeout():
	selected_scene_index = RNG.randi_range(0, scenes.size() - 1)
	var temp_scene = scenes[selected_scene_index].instance()
	match temp_scene.name:
		coin_scene:
			temp_scene.translate(Vector2(0, -Globals.SPAWN_LAYER_HEIGHT \
				* rand_range(1, Globals.SPAWN_LAYER_NUM)))
		obstacle_scene:
			temp_scene.init_object(get_object(obstacle_scene))
		onehitmob_scene:
			temp_scene.init_object(get_object(onehitmob_scene))
			temp_scene.translate(Vector2(0, -Globals.SPAWN_LAYER_HEIGHT \
				* rand_range(1, Globals.SPAWN_LAYER_NUM)))
	
#	add_child_below_node(self, temp_scene) - was used in tutorial, why?
	add_child(temp_scene)
	
	if temp_scene.name == coin_scene and randi() % 10 > 2:
		spawn_several_objects(temp_scene, selected_scene_index)
	if temp_scene.name == onehitmob_scene and randi() % 10 > 3:
		spawn_several_objects(temp_scene, selected_scene_index)


func get_object(scene_name: String) -> Dictionary:
	var scene_objects: Array = []
	for obj in objects:
		if(obj["type"] == scene_name):
			scene_objects.append(obj)
	if scene_objects.size() > 0:
		return scene_objects[randi() % scene_objects.size()]
	return {}


func spawn_several_objects(first_object_scene, scene_index: int) -> void:
	var next_object_scene
	for i in randi() % Globals.SPAWN_COINS_MAX + 1:
		next_object_scene = scenes[scene_index].instance()
#		var pos1 = next_object_scene.get_position()
		if first_object_scene.name == onehitmob_scene:
			next_object_scene.init_object(get_object(onehitmob_scene))
		next_object_scene.translate(
			Vector2(first_object_scene.get_position().x + i * 20,
			first_object_scene.get_position().y))
#		print("Pos: %s/%s" % [pos1, next_object_scene.get_position()])
		add_child(next_object_scene)
