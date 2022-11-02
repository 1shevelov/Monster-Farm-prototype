extends "../scripts/ScrollMovement.gd"

signal avatar_attacked_one_hit_mob # on collision
signal avatar_damaged  # on this.weapon attacking avatar
#signal destroyed  # on this destoyed

onready var hit_sound := $HitSound

var has_weapon := false


func init_object(obj: Dictionary) -> void:
	if obj.has("image"):
		$Sprite.set_texture(load(obj.image))
		var sprite_size: Vector2 = $Sprite.get_texture().get_size()
#		if sprite_size.x > sprite_size.y:
		$Collision/CollisionShape2D.get_shape().set_radius(sprite_size.x / 1.5)
		
	if obj.has("money"):
		$Resources.init_component(obj["money"])
			
	if obj.has("weapon") and $Weapon.init_component(obj.weapon):
		has_weapon = true


func _physics_process(_delta):
	move()


func connect_to_avatar(avatar_node: Node) -> void:
	var err = connect("avatar_attacked_one_hit_mob", avatar_node, "on_attacked_one_hit_mob", [], \
	CONNECT_ONESHOT + CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"avatar_attacked_one_hit_mob\": ", err)
	err = connect("avatar_damaged", \
	avatar_node, "on_damaged", [], CONNECT_ONESHOT + CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"avatar_damaged\": ", err)
	elif has_weapon:
		$Weapon.attack_stop()


func _on_Collision_body_entered(some_node: Node):
	if some_node.name == Globals.AVATAR_NODE_NAME:
		connect_to_avatar(some_node)
		emit_signal("avatar_attacked_one_hit_mob", self, $Resources.give_all())
		hide()
		if not Globals.SILENT_MODE:
			hit_sound.play()
		yield(hit_sound, "finished")
		if not has_weapon:
			queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func on_weapon_attacked(damage: int) -> void:
	emit_signal("avatar_damaged", damage)
	queue_free()


