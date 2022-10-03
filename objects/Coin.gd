extends "../scripts/ScrollMovement.gd"

onready var pickup_sound := $PickupSound

var gives_money := Globals.MONEY_PER_COIN


func _physics_process(_delta):
	move()


func _on_Collision_body_entered(body: Node):
	if body.name == "Avatar":
		hide()
		if not Globals.SILENT_MODE:
			pickup_sound.play()
		Signals.emit_signal("coin_picked", gives_money)
		yield(pickup_sound, "finished")
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


