extends "../scripts/ScrollMovement.gd"

signal avatar_hit_resource_object # on collision with avatar
#var gives_money := Globals.MONEY_PER_COIN


func _ready() -> void:
	$Resources.init_component(Globals.MONEY_PER_COIN)


func _physics_process(_delta):
	move()


func connect_to_avatar(avatar_node: Node) -> void:
	var err = connect("avatar_hit_resource_object", avatar_node, "on_hit_resource_object", \
	[], CONNECT_ONESHOT + CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"avatar_hit_resource_object\": ", err)


func _on_Collision_body_entered(some_node: Node):
	if some_node.name == "Avatar":
		connect_to_avatar(some_node)
		hide()
#		if not Globals.SILENT_MODE:
#			pickup_sound.play()
		emit_signal("avatar_hit_resource_object", $Resources.give_all())
#		Signals.emit_signal("coin_picked", gives_money)
#		yield(pickup_sound, "finished")
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


