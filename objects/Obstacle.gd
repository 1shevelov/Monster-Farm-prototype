extends "../scripts/ScrollMovement.gd"

signal avatar_attacked  # on this.weapon attacking avatar
signal destroyed  # on this destoyed

const OBJECT_TYPE = Globals.object_type.OBSTACLE

var avatar_node: Node2D

onready var hit_sound := $HitSound
onready var money_sound := $MoneySound

var obstacle_name := ""

var money := 0

var has_weapon := false


#func _ready():
#	pass


func init_object(obj: Dictionary) -> void:
	if obj.has("name"):
		obstacle_name = obj["name"]
		
	if obj.has("image"):
		$Sprite.set_texture(load(obj.image))
		var sprite_size: Vector2 = $Sprite.get_texture().get_size()
		$Collision/CollisionShape2D.get_shape().set_extents(sprite_size / 1.5)
		
	if obj.has("hp"):
		$hp.init_component(obj.hp)
	else:
		print("ERROR: Obstacle has no hp")
			
	if obj.has("money"):
		var money_min := 0.0
		var money_max := 0.0
		if typeof(obj.money) == TYPE_REAL:
			if obj.money > 0:
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


func _physics_process(_delta) -> void:
	move()


func connect_to_avatar() -> void:
# warning-ignore:return_value_discarded
	connect("destroyed", avatar_node, "on_object_destroyed", [self, money], \
	CONNECT_ONESHOT + CONNECT_DEFERRED)
	if has_weapon and connect("avatar_attacked", \
	avatar_node, "on_avatar_attacked", [self], CONNECT_DEFERRED):
		$Weapon.attack_start()


func _on_Collision_body_entered(some_node: Node) -> void:
	if some_node.name == Globals.AVATAR_NODE_NAME:
		avatar_node = some_node
		if not Globals.SILENT_MODE:
			hit_sound.play()
		$hp.show_ui()
		connect_to_avatar()


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func on_destroyed() -> void:
	emit_signal("destroyed", self, money)
	if money > 0 and not Globals.SILENT_MODE:
		money_sound.play()
#		die effect or sound?
	disconnect("avatar_attacked", avatar_node, "on_avatar_attacked")
	queue_free()


func receive_damage(damage_amount: int) -> void:
	$hp.receive_damage(damage_amount)
	if $hp.is_dead():
		on_destroyed()


func on_weapon_attacked(damage: int) -> void:
	emit_signal("avatar_attacked", self, damage)

