extends KinematicBody2D

var velocity := Vector2.ZERO

export var jump_velocity: int = 600
export var gravity_scale: float = 20.0

enum {
	IDLE,
	RUN,
	JUMP,
	ATTACK
}

var state := RUN

#var score := Globals.INITIAL_SCORE
var money := Globals.INITIAL_MONEY

onready var animation := $AnimatedSprite
onready var jump_sound := $JumpSound
onready var death_sound := $DeathSound

#var attack_num := 0
#const STONE_ATTACK_NUM = 3
var attack_damage := 10
var attacked_node: Node2D = null

const Objects: GDScript = preload("res://objects/InitObjects.gd")
onready var objects_instance := Objects.new()


func _ready():
	objects_instance.load_all_objects()
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
# warning-ignore:return_value_discarded
	Signals.connect("coin_picked", self, "on_coin_picked")
# warning-ignore:return_value_discarded
	Signals.connect("being_attacked", self, "on_being_attacked")
# warning-ignore:return_value_discarded
	Signals.connect("attack_damage", self, "on_attack_damage")
# warning-ignore:return_value_discarded
	Signals.connect("killed", self, "on_killed")
# warning-ignore:return_value_discarded
	Signals.connect("one_hit_killed", self, "on_one_hit_killed")
	
	randomize()


func _physics_process(delta):
	match state:
		IDLE:
			pass
		RUN:
			animation.play("Run")
		JUMP:
			velocity = Vector2.ZERO
			velocity.y -= jump_velocity
			animation.play("Jump")
			if not Globals.SILENT_MODE:
				jump_sound.play()
			state = IDLE
		ATTACK:
			animation.play("Attack")
	
	velocity.y += gravity_scale
# warning-ignore:return_value_discarded
	move_and_collide(velocity * delta)


func _input(event):
	if state == RUN and event.is_action_pressed("jump"):
		state = JUMP


func _on_Area2D_body_entered(body):
	if body is StaticBody2D:
		state = RUN


func _on_Area2D_body_exited(body):
	if body is StaticBody2D:
		state = JUMP


func get_random_state(state_list):
	randomize()
	state_list.shuffle()
	return state_list.front()
	
	
func on_coin_picked(money_given: int):
	money += money_given
#	Signals.emit_signal("update_score", score)
	Signals.emit_signal("update_money", money)


func on_being_attacked(attacked_object: Node2D):
	state = ATTACK
	attacked_node = attacked_object
	Globals.world_speed = Globals.ZERO_WORLD_SPEED
	$AttackTimer.start()
	Signals.emit_signal("world_stopped")


func on_one_hit_killed(killed_node: Node2D) -> void:
	print(killed_node, " killed")
#	animation.stop()
	animation.play("AirAttack")


func kill_avatar():
#		print("The avatar is dead")
	hide()
	Signals.disconnect("coin_picked", self, "on_coin_picked")
	Signals.disconnect("being_attacked", self, "on_being_attacked")
	if not Globals.SILENT_MODE:
		death_sound.play()
	Signals.emit_signal("game_over")
	yield(death_sound, "finished")
	queue_free()


func _on_AttackTimer_timeout():
	Signals.emit_signal("attack_damage")


func on_attack_damage():
	attacked_node.receive_damage(attack_damage)
	print("attack on ", attack_damage)


func on_killed(killed_node: Node2D) -> void:
	if attacked_node == killed_node:
		print(killed_node, " killed")
		$AttackTimer.stop()
		state = RUN
		Globals.world_speed = Globals.DEFAULT_WORLD_SPEED
		Signals.emit_signal("attack_finished")

