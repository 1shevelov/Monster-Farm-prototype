extends "../scripts/ScrollMovement.gd"

onready var hit_sound := $HitSound
onready var money_sound := $MoneySound

var money: int

func init(obj: Dictionary) -> void:
	if obj.has("image"):
		$Sprite.set_texture(load(obj.image))
		var sprite_size: Vector2 = $Sprite.get_texture().get_size()
#		if sprite_size.x > sprite_size.y:
		$Collision/CollisionShape2D.get_shape().set_radius(sprite_size.x / 1.5)
		
	if obj.has("money"):
		var money_min := 0.0
		var money_max := 0.0
		if typeof(obj.money) == TYPE_REAL:
			if (obj.money) > 0:
				money_min = obj.money
			money = int(round(money_min))
		elif typeof(obj.money) == TYPE_DICTIONARY:
			if obj.money.has("min") and typeof(obj.money.min) == TYPE_REAL and obj.money.min > 0:
				money_min = obj.money.min
			if obj.money.has("max") and typeof(obj.money.max) == TYPE_REAL:
				money_max = obj.money.max
				if money_max < money_min:
					money_max = money_min
			money = int(round(rand_range(money_min, money_max)))


func _physics_process(_delta):
	move()


func _on_Collision_body_entered(body: Node):
	if body.name == "Avatar":
		hide()
		if not Globals.SILENT_MODE:
			hit_sound.play()
		Signals.emit_signal("one_hit_killed", self, money)
		if money > 0 and not Globals.SILENT_MODE:
			money_sound.play()
		yield(hit_sound, "finished")
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()



