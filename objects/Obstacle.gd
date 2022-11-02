extends "../scripts/ScrollMovement.gd"

signal avatar_attacked_hp_object # on collision
signal avatar_damaged  # on this.weapon attacking avatar
signal destroyed_hp_object  # on this destoyed

var avatar_node: Node2D

onready var hit_sound := $HitSound

var obstacle_name := ""

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
		$Resources.init_component(obj["money"])
		
	if obj.has("weapon") and $Weapon.init_component(obj.weapon):
		has_weapon = true


func _physics_process(_delta) -> void:
	move()


func connect_to_avatar() -> void:
	var err = connect("avatar_attacked_hp_object", avatar_node, \
	"on_attacked_hp_object", [], CONNECT_ONESHOT + CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"avatar_attacked_hp_object\": ", err)
	err = connect("avatar_damaged", avatar_node, "on_damaged", [], CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"avatar_damaged\": ", err)
	elif has_weapon:
		$Weapon.attack_start()
	err = connect("destroyed_hp_object", avatar_node, "on_object_destroyed", \
	[], CONNECT_ONESHOT + CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"destroyed_hp_object\": ", err)


func _on_Collision_body_entered(some_node: Node) -> void:
	if some_node.name == Globals.AVATAR_NODE_NAME:
		avatar_node = some_node
		if not Globals.SILENT_MODE:
			hit_sound.play()
		$hp.show_ui()
		connect_to_avatar()
		emit_signal("avatar_attacked_hp_object", self)


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func on_destroyed() -> void: 
	emit_signal("destroyed_hp_object", self, $Resources.give_all())
#	disconnect("avatar_damaged", avatar_node, "on_damaged")
	queue_free()


func receive_damage(damage_amount: int) -> void:
	$hp.receive_damage(damage_amount)
	if $hp.is_dead():
		on_destroyed()


func on_weapon_attacked(damage: int) -> void:
	emit_signal("avatar_damaged", damage)

