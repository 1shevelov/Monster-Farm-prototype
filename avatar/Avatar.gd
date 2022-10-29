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

var avatar_name := ""
#var attack_num := 0
#const STONE_ATTACK_NUM = 3
#var attack_damage := 10
var attacked_node: Node2D = null


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("coin_picked", self, "on_coin_picked")


func init_object(avatar_obj: Dictionary) -> void:
#	print_debug(avatar_obj)
	if avatar_obj.has("name"):
		avatar_name = avatar_obj["name"]

	if avatar_obj.has("weapon"):
		$Weapon.init_component(avatar_obj.weapon)
	if avatar_obj.has("hp"):
		$hp.init_component(avatar_obj.hp)
		$hp.show_ui()
	else:
		print("ERROR: Avatar has no hp")
			
#	if avatar_obj.has("money"):
#		var money_min := 0.0
#		var money_max := 0.0
#		if typeof(obj.money) == TYPE_REAL:
#			if obj.money > 0:
#				money_min = obj.money
#			money = int(round(money_min))
#		elif typeof(obj.money) == TYPE_DICTIONARY:
#			if obj.money.has("min") and typeof(obj.money.min) == TYPE_REAL and obj.money.min > 0:
#				money_min = obj.money.min
#			if obj.money.has("max") and typeof(obj.money.max) == TYPE_REAL:
#				money_max = obj.money.max
#				if money_max < money_min:
#					money_max = money_min
#		money = int(round(rand_range(money_min, money_max)))


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
	if body is StaticBody2D:
		if state != START:
			state = RUN
	elif body.has("OBJECT_TYPE"):
		match body.OBJECT_TYPE:
			Globals.object_type.COIN:
				pass
			Globals.object_type.ONE_HIT_MOB:
				on_hitting_one_hit_mob(body)
			Globals.object_type.MOB, Globals.object_type.OBSTACLE:
				on_being_attacked(body)
	else:
		print_debug("Unknown body collided: ", body)


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


func on_being_attacked(attacking_node: Node2D):
	print("Avatar is under attack from ", attacking_node)
	state = ATTACK
	attacked_node = attacking_node
	Globals.world_speed = Globals.ZERO_WORLD_SPEED
	$AttackTimer.start()
	Signals.emit_signal("world_stopped")


func on_hitting_one_hit_mob(one_hit_mob: Node2D) -> void:
	print(one_hit_mob, " killed")
	attacked_node = one_hit_mob
#	animation.stop()
	animation.play("AirAttack")


func add_money(money_given: int) -> void:
	if money_given > 0:
		print("Money given: ", money_given)
		money += money_given
		Signals.emit_signal("update_money", money)


# when receiving damage from object's weapon
func on_avatar_attacked(attacking_node: Node2D, damage: int) -> void:
	print("Avatar is attacked by %s for %s damage" % [attacking_node, damage])
	$hp.receive_damage(damage)
	if $hp.is_dead():
		on_killed()


func on_killed():
	print("The avatar is dead")
	hide()
	Signals.disconnect("coin_picked", self, "on_coin_picked")
	if not Globals.SILENT_MODE:
		death_sound.play()
	Signals.emit_signal("game_over")
	yield(death_sound, "finished")
	queue_free()


func _on_AttackTimer_timeout():
	var damage = $Weapon.get_damage()
	print("Avatar is attacking with the %s for %s" % [$Weapon.weapon_name, damage])
	attacked_node.receive_damage(damage)


# when attacked object destroyed
func on_object_destroyed(destroyed_node: Node2D, money_given: int = 0) -> void:
	if attacked_node == destroyed_node:
		print(destroyed_node, " destroyed")
		add_money(money_given)
		$AttackTimer.stop()
		state = RUN
		Globals.world_speed = Globals.RUN_WORLD_SPEED
		Signals.emit_signal("attack_finished")


func _on_DashTimer_timeout():
	state = RUN
	Globals.world_speed = Globals.RUN_WORLD_SPEED
	$DashTimer.stop()



