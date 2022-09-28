extends "../scripts/ScrollMovement.gd"

onready var hit_sound := $HitSound

onready var health_pool: int = round(rand_range(Globals.STONE_HEALTH_MIN, Globals.STONE_HEALTH_MAX))


func _physics_process(_delta):
	move()


func _on_Obstacle_body_entered(body: Node):
	if body.name == "Avatar":
		if not Globals.SILENT_MODE:
			hit_sound.play()
		Signals.emit_signal("stone_hit", self)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func receive_damage(amount: int) -> void:
	health_pool -= amount
	print(self, " has health = ", health_pool)
	if health_pool <= 0:
		Signals.emit_signal("killed", self)
#		die effect or sound?
		queue_free()
