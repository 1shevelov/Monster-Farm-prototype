extends "../scripts/ScrollMovement.gd"

onready var hit_sound := $HitSound
onready var money_sound := $MoneySound

var full_hp: int
var current_hp: int

var money: int


func _ready():
	pass


func init(obj: Dictionary) -> void:
	if obj.has("image"):
		$Sprite.set_texture(load(Resources.objects + obj.image))
		var sprite_size: Vector2 = $Sprite.get_texture().get_size()
		$Collision/CollisionShape2D.get_shape().set_extents(sprite_size / 1.5)
		
	if obj.has("hp"):
		var hp_min := 0.0
		var hp_max := 0.0
		if typeof(obj.hp) == TYPE_REAL:
			if obj.hp > 0:
				hp_min = obj.hp
			full_hp = int(round(hp_min))
			current_hp = full_hp
		elif typeof(obj.hp) == TYPE_DICTIONARY:
			if obj.hp.has("min") and obj.hp.min == TYPE_REAL and obj.hp.min > 0:
				hp_min = obj.hp.min
			if obj.hp.has("max") and obj.hp.max == TYPE_REAL:
				if obj.hp.max > hp_min:
					hp_max = obj.hp.max
				else:
					hp_max = hp_min
			full_hp = int(round(rand_range(hp_min, hp_max)))
			current_hp = full_hp
			
	if obj.has("money"):
		var money_min := 0.0
		var money_max := 0.0
		if typeof(obj.money) == TYPE_REAL:
			if obj.money > 0:
				money_min = obj.money
			money = int(round(money_min))
		elif typeof(obj.money) == TYPE_DICTIONARY:
			if obj.money.has("min") and obj.money.min == TYPE_REAL and obj.money.min > 0:
				money_min = obj.money.min
			if obj.money.has("max") and obj.money.max == TYPE_REAL:
				money_max = obj.money.max
				if money_max < money_min:
					money_max = money_min
		money = int(round(rand_range(money_min, money_max)))


func _physics_process(_delta):
	move()


func _on_Collision_body_entered(body: Node):
	if body.name == "Avatar":
		if not Globals.SILENT_MODE:
			hit_sound.play()
		Signals.emit_signal("being_attacked", self)
		print(self, " attacked, hp= ", current_hp)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func receive_damage(damage_amount: int) -> void:
	current_hp -= damage_amount
	if current_hp < 0:
		current_hp = 0 
	$HPBarUI.update_health(float(current_hp) / float(full_hp) * 100)
	if current_hp <= 0:
		Signals.emit_signal("killed", self, money)
		if money > 0 and not Globals.SILENT_MODE:
			money_sound.play()
#		die effect or sound?
		queue_free()


