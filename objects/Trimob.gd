extends "../scripts/ScrollMovement.gd"

onready var hit_sound := $HitSound


func _physics_process(_delta):
	move()


func _on_Obstacle_body_entered(body: Node):
	if body.name == "Avatar":
		hide()
		if not Globals.SILENT_MODE:
			hit_sound.play()
		Signals.emit_signal("one_hit_killed", self)
		yield(hit_sound, "finished")
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


