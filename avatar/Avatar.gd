extends KinematicBody2D

var velocity := Vector2.ZERO

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

onready var animation := $AnimatedSprite
onready var death_sound := $DeathSound

var avatar_name := ""
var attacked_node: Node2D = null


func _ready():
	pass


# called from Game
func connect_ui(money_counter: Control, hp_bar: Control) -> void:
	$Resources.connect_avatar_ui(money_counter)
	$hp.connect_avatar_ui(hp_bar)


func init_object(avatar_obj: Dictionary) -> void:
#	print_debug(avatar_obj)
	if avatar_obj.has("name"):
		avatar_name = avatar_obj["name"]

	if avatar_obj.has("weapon"):
		$Weapon.init_component(avatar_obj.weapon)
	if avatar_obj.has("hp"):
		$hp.init_component(avatar_obj.hp)
	else:
		print("ERROR: Avatar has no hp")
			
	if avatar_obj.has("money"):
		$Resources.init_component(avatar_obj["money"])
		# update UI money cointer
		
	$Jump.init_component($AnimatedSprite, get_global_position().y)


func _physics_process(delta: float) -> void:
	match state:
		START:
			animation.play("Idle")
		RUN:
			animation.play("Run")
		JUMP:
			$Jump.jump()
			state = IDLE
		DASH:
			$Jump.dash()
			state = IDLE
		ATTACK:
			animation.play("Attack")
	
	$Jump.gravity()
# warning-ignore:return_value_discarded
	move_and_collide(velocity * delta)


func _input(event) -> void:
#	IDLE state only on world start
#	print("STATE = ", state)
	if state == START and event.is_action_pressed("jump"):
		$Stats.start_life()
		$Stats.jumps += 1
		state = RUN
		Globals.world_speed = Globals.RUN_WORLD_SPEED
		Signals.emit_signal("attack_finished")

	if state == RUN and event.is_action_pressed("jump"):
		state = JUMP
		$Stats.jumps += 1
		
	if state == IDLE and event.is_action_released("jump"):
		$Jump.set_fall_gravity()
		
	if state == ATTACK and event.is_action_pressed("jump"):
		$AttackTimer.stop()
		$Stats.jumps += 1
		state = DASH
		Globals.world_speed = Globals.DASH_WORLD_SPEED
		Signals.emit_signal("attack_finished")
		
	if event.is_action_pressed("end_life"):
		on_killed()


func _on_Area2D_body_entered(body):
	if body is StaticBody2D and state != START:
		state = RUN
		$Jump.set_jump_gravity()


func _on_Area2D_body_exited(_body):
#	if body is StaticBody2D and state != DASH:
#		state = JUMP
		pass


# pseudo AI
func get_random_state(state_list):
	randomize()
	state_list.shuffle()
	return state_list.front()
	
	
func on_hit_resource_object(money_given: int):
#	Signals.emit_signal("update_score", score)
#	Signals.emit_signal("update_money", money)
	$Resources.avatar_add_money(money_given)
	$Stats.total_money += money_given
	$Stats.coins_picked += 1
	# Play pick up animation, like Yipee!


func on_attacked_hp_object(attacking_node: Node2D) -> void:
#	print_debug("Avatar is under attack by hp object")
	attacked_node = attacking_node
	state = ATTACK
	Globals.world_speed = Globals.ZERO_WORLD_SPEED
	$AttackTimer.start()
	Signals.emit_signal("world_stopped")


func on_attacked_one_hit_mob(attacking_node: Node2D, money_given: int = 0) -> void:
#	print(attacking_node, " killed")
	attacked_node = attacking_node
	$Resources.avatar_add_money(money_given)
	$Stats.total_money += money_given
	$Stats.killed_one_hit_mobs += 1
#	animation.stop()
	animation.play("AirAttack")


# when receiving damage from object's weapon
func on_damaged(damage: int) -> void:
	$hp.receive_damage(damage)
	if $hp.is_dead():
		on_killed()


func on_killed():
	print("The avatar is dead")
	$Stats.end_life()
	hide()
	Signals.disconnect("coin_picked", self, "on_coin_picked")
	if not Globals.SILENT_MODE:
		death_sound.play()
	Globals.world_speed = Globals.ZERO_WORLD_SPEED
	Signals.emit_signal("world_stopped")
	Signals.emit_signal("game_over")
	print("  ** END RESULTS **")
	print($Stats.get_finals())
	yield(death_sound, "finished")
	queue_free()


func _on_AttackTimer_timeout():
	var damage = $Weapon.get_damage()
#	print("Avatar is attacking with the %s for %s" % [$Weapon.weapon_name, damage])
	$Stats.total_damage_dealt += damage
	attacked_node.receive_damage(damage)


# when attacked hp object is destroyed
func on_object_destroyed(destroyed_node: Node2D, money_given: int = 0) -> void:
	if attacked_node == destroyed_node:
		print(destroyed_node, " destroyed")
		$Resources.avatar_add_money(money_given)
		$Stats.total_money += money_given
		$AttackTimer.stop()
		# since for now only obstacles has hp
		$Stats.destroyed_obstacles += 1
		state = RUN
		Globals.world_speed = Globals.RUN_WORLD_SPEED
		Signals.emit_signal("attack_finished")


func on_dash_finished():
	Globals.world_speed = Globals.RUN_WORLD_SPEED


