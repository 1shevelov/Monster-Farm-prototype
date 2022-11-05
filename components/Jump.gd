# currently, can be used only for the avatar
# cause velocity == Vector2.ZERO

extends Node2D

signal dash_finished

const STARTING_JUMP_HEIGHT := 150.0
const MAX_JUMP_HEIGHT := 350.0
const TIME_UP := 0.6
const TIME_DOWN := 0.4

onready var jump_height := STARTING_JUMP_HEIGHT
#onready var jump_time_up := TIME_UP
#onready var jump_time_down := TIME_DOWN

onready var jump_velocity := (2.0 * jump_height) / TIME_UP
onready var jump_gravity := jump_height / (TIME_UP * TIME_UP) / 30
# or fall_gravity = 2 x jump_gravity
onready var fall_gravity := jump_height / (TIME_DOWN * TIME_DOWN) / 30

# where he runs
var base_avatar_y: float

#var dash_velocity := 250

var animation: AnimatedSprite
onready var host = get_parent()

var is_button_released := false


func init_component(parent_animation_node: AnimatedSprite, base_y: float) -> void:
	animation = parent_animation_node
	base_avatar_y = base_y
	
	var err = connect("dash_finished", host, "on_dash_finished", \
	[], CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"dash_finished\" to ", host)


func jump() -> void:
	host.velocity = Vector2.ZERO
	host.velocity.y -= jump_velocity
	animation.play("Jump")
	if not Globals.SILENT_MODE:
		$Sound.play()


func dash() -> void:
	host.velocity = Vector2.ZERO
	host.velocity.y -= jump_velocity
	animation.play("Dash")
	if not Globals.SILENT_MODE:
		$Sound.play()
#		velocity.x += dash_velocity
	$DashTimer.start()


func get_gravity() -> float:
#	return jump_gravity if host.velocity.y < 0.0 else fall_gravity
	if host.get_global_position().y > base_avatar_y - jump_height \
	and not is_button_released:
		return jump_gravity
	else:
		return fall_gravity


func set_fall_gravity() -> void:
	is_button_released = true


func set_jump_gravity() -> void:
	is_button_released = false


# called in Avatar physics process
func gravity() -> void:
	host.velocity.y += get_gravity()
#	if abs(host.velocity.y) < 0.5:
#		print("Top Y: ", host.get_global_position().y)


func _on_DashTimer_timeout():
	emit_signal("dash_finished")


