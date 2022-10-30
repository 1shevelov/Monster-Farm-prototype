extends "../scripts/ScrollMovement.gd"

signal avatar_attacked # on collision
signal avatar_damaged  # on this.weapon attacking avatar
signal destroyed  # on this destoyed

onready var hit_sound := $HitSound
onready var money_sound := $MoneySound

var avatar_node: Node2D

var money: int

var has_weapon := false


func init_object(obj: Dictionary) -> void:
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
			
	if obj.has("weapon") and $Weapon.init_component(obj.weapon):
		has_weapon = true


func _physics_process(_delta):
	move()


func connect_to_avatar() -> void:
# warning-ignore:return_value_discarded
	connect("avatar_attacked", avatar_node, "on_attacked", [], \
	CONNECT_ONESHOT + CONNECT_DEFERRED)
	if has_weapon and connect("avatar_damaged", \
	avatar_node, "on_damaged", [], CONNECT_ONESHOT + CONNECT_DEFERRED):
		$Weapon.attack_stop()
# warning-ignore:return_value_discarded
	connect("destroyed", avatar_node, "on_object_destroyed", [], \
	CONNECT_ONESHOT + CONNECT_DEFERRED)


func _on_Collision_body_entered(some_node: Node):
	if some_node.name == Globals.AVATAR_NODE_NAME:
		avatar_node = some_node
		connect_to_avatar()
		emit_signal("avatar_attacked", self, "OneHitMob")
		hide()
		if not Globals.SILENT_MODE:
			hit_sound.play()
		if money > 0 and not Globals.SILENT_MODE:
			money_sound.play()
		emit_signal("destroyed", self, money)
		yield(hit_sound, "finished")
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func on_weapon_attacked(damage: int) -> void:
	emit_signal("avatar_damaged", self, damage)


