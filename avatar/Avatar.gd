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

var score := Globals.INITIAL_SCORE

onready var animation := $AnimatedSprite
onready var jump_sound := $JumpSound
onready var death_sound := $DeathSound

var attack_num := 0
const STONE_ATTACK_NUM = 3


func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
# warning-ignore:return_value_discarded
	Signals.connect("coin_picked", self, "on_coin_picked")
# warning-ignore:return_value_discarded
	Signals.connect("stone_hit", self, "on_stone_hit")
# warning-ignore:return_value_discarded
	Signals.connect("attack_damage", self, "on_attack_damage")


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
	
	
func on_coin_picked(addon: int):
	score += addon
	Signals.emit_signal("update_score", score)


func on_stone_hit(to_remove: int):
#	score -= to_remove
#	Signals.emit_signal("update_score", score)
#	if score <= 0:
#		kill_avatar()
	state = ATTACK
	Globals.world_speed = Globals.ZERO_WORLD_SPEED
	$AttackTimer.start()
	Signals.emit_signal("attack_start")


func kill_avatar():
#		print("The avatar is dead")
	self.hide()
	Signals.disconnect("coin_picked", self, "on_coin_picked")
	Signals.disconnect("stone_hit", self, "on_stone_hit")
	death_sound.play()
	Signals.emit_signal("game_over")
	yield(death_sound, "finished")
	queue_free()


func _on_AttackTimer_timeout():
	Signals.emit_signal("attack_damage")


func on_attack_damage():
	attack_num += 1
	print("attack")
	if attack_num == STONE_ATTACK_NUM:
		attack_num = 0
		$AttackTimer.stop()
		state = RUN
		Globals.world_speed = Globals.DEFAULT_WORLD_SPEED
		Signals.emit_signal("attack_finished")



