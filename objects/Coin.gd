extends "../scripts/ScrollMovement.gd"

onready var pickup_sound := $PickupSound


func _physics_process(delta):
	move()


func _on_Pickup_body_entered(body: Node):
	if body.name == "Avatar":
		self.hide()
		pickup_sound.play()
		Signals.emit_signal("coin_picked", 1)
		yield(pickup_sound, "finished")
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
