extends "../scripts/ScrollMovement.gd"

onready var hit_sound := $HitSound

var full_hp: int
var current_hp: int


func _ready():
	pass


func init(obj: Dictionary) -> void:
	if obj.has("image"):
		$Sprite.set_texture(load(Resources.objects + obj.image))
	if obj.has("hp"):
		var hp_min := 0.0
		var hp_max := 0.0
		if typeof(obj.hp) == TYPE_REAL:
			hp_min = obj.hp
			hp_max = hp_min
		elif typeof(obj.hp) == TYPE_DICTIONARY:
			if obj.hp.has("min"):
				hp_min = obj.hp.min
			if obj.hp.has("max"):
				hp_max = obj.hp.max
				
		if hp_min > 0 and hp_max >= hp_min:
# warning-ignore:narrowing_conversion
			full_hp = round(rand_range(hp_min, hp_max))
			current_hp = full_hp


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
		Signals.emit_signal("killed", self)
#		die effect or sound?
		queue_free()


