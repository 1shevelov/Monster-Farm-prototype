# currently, can be used only for the avatar
# cause velocity == Vector2.ZERO

extends Node2D

signal dash_finished

var jump_velocity := 600
var dash_velocity := 250
var gravity_scale := 20.0

var animation: AnimatedSprite
onready var host = get_parent()


func init_component(parent_animation_node: AnimatedSprite) -> void:
	animation = parent_animation_node
	
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


# called in Avatar physics process
func gravity() -> void:
	host.velocity.y += gravity_scale


func _on_DashTimer_timeout():
	emit_signal("dash_finished")


