extends "../scripts/ScrollMovement.gd"

onready var hit_sound := $HitSound

onready var full_health_pool: int = round(rand_range(Globals.STONE_HEALTH_MIN,
	Globals.STONE_HEALTH_MAX))
onready var current_health: int = full_health_pool


func _physics_process(_delta):
	move()


func _on_Collision_body_entered(body: Node):
	if body.name == "Avatar":
		if not Globals.SILENT_MODE:
			hit_sound.play()
		Signals.emit_signal("being_attacked", self)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func receive_damage(amount: int) -> void:
	current_health -= amount
	print(self, " has health = ", current_health)
	if current_health < 0:
		current_health = 0 
	$HPBarUI.update_health(float(current_health) / float(full_health_pool) * 100)
	if current_health <= 0:
		Signals.emit_signal("killed", self)
#		die effect or sound?
		queue_free()


