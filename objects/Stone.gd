extends "../scripts/ScrollMovement.gd"

onready var hit_sound := $HitSound


func _physics_process(_delta):
	move()


func _on_Obstacle_body_entered(body: Node):
	if body.name == "Avatar":
		hit_sound.play()
		Signals.emit_signal("stone_hit", 10)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

