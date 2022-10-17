extends KinematicBody2D

var velocity := Vector2.ZERO

export var jump_velocity := 600
export var dash_velocity := 250
export var gravity_scale := 20.0

enum {
	START,
	IDLE,
	RUN,
	JUMP,
	DASH,
	ATTACK
}

var state := START

#var score := Globals.INITIAL_SCORE
var money := Globals.INITIAL_MONEY

onready var animation := $AnimatedSprite
onready var jump_sound := $JumpSound
onready var death_sound := $DeathSound

#var attack_num := 0
#const STONE_ATTACK_NUM = 3
var attack_damage := 10
var attacked_node: Node2D = null


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("coin_picked", self, "on_coin_picked")
# warning-ignore:return_value_discarded
	Signals.connect("being_attacked", self, "on_being_attacked")
# warning-ignore:return_value_discarded
	Signals.connect("killed", self, "on_killed")
# warning-ignore:return_value_discarded
	Signals.connect("one_hit_killed", self, "on_one_hit_killed")


func _physics_process(delta):
	match state:
		START:
			animation.play("Idle")
		RUN:
			animation.play("Run")
		JUMP:
			velocity = Vector2.ZERO
			velocity.y -= jump_velocity
			animation.play("Jump")
			if not Globals.SILENT_MODE:
				jump_sound.play()
			state = IDLE
		DASH:
			velocity = Vector2.ZERO
			velocity.y -= jump_velocity
#			animation.play("Jump")
			if not Globals.SILENT_MODE:
				jump_sound.play()
			animation.play("Dash")
#			velocity.x += dash_velocity
#			TODO: shift position
			state = IDLE
		ATTACK:
			animation.play("Attack")
	
	velocity.y += gravity_scale
# warning-ignore:return_value_discarded
	move_and_collide(velocity * delta)


func _input(event):
#	IDLE state only on world start
	if state == START and event.is_action_pressed("jump"):
#		print("START")
		state = RUN
		Globals.world_speed = Globals.RUN_WORLD_SPEED
		Signals.emit_signal("attack_finished")

	if state == RUN and event.is_action_pressed("jump"):
		state = JUMP
		
	if state == ATTACK and event.is_action_pressed("jump"):
		$AttackTimer.stop()
		state = DASH
		print("DASH")
		Globals.world_speed = Globals.DASH_WORLD_SPEED
		Signals.emit_signal("attack_finished")
		$DashTimer.start()


func _on_Area2D_body_entered(body):
	if body is StaticBody2D and state != START:
		state = RUN


func _on_Area2D_body_exited(_body):
#	if body is StaticBody2D and state != DASH:
#		state = JUMP
		pass


# pseudo AI
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


func on_one_hit_killed(killed_node: Node2D, money_given: int = 0) -> void:
	print(killed_node, " killed")
	add_money(money_given)
#	animation.stop()
	animation.play("AirAttack")


func add_money(money_given: int) -> void:
	if money > 0:
		print("Money given: ", money_given)
		money += money_given
		Signals.emit_signal("update_money", money)


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
	attacked_node.receive_damage(attack_damage)


func on_killed(killed_node: Node2D, money_given: int = 0) -> void:
	if attacked_node == killed_node:
		print(killed_node, " killed")
		add_money(money_given)
		$AttackTimer.stop()
		state = RUN
		Globals.world_speed = Globals.RUN_WORLD_SPEED
		Signals.emit_signal("attack_finished")


func _on_DashTimer_timeout():
	state = RUN
	Globals.world_speed = Globals.RUN_WORLD_SPEED
	$DashTimer.stop()



