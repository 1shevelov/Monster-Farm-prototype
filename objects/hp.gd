extends Node2D

signal hp_changed

const HP := "hp"
const HP_MIN := "min"
const HP_MAX := "max"

const HP_MAXIMUM := 1000000
var full_hp: int = 0
var current_hp: int = 0

const HP_DEFAULT := 1

var is_avatar_hp := false
onready var hp_ui := $HPBarUI


func init_component(hp) -> void:
	if typeof(hp) == TYPE_DICTIONARY:
		Json.validate_dic_of_int(hp, HP_DEFAULT, HP_MAXIMUM, HP_DEFAULT, HP)
		# TODO: test resulting values
		full_hp = randi() % (hp[HP_MAX] - hp[HP_MIN] + 1) + hp[HP_MIN]
	else:
		full_hp = Json.validate_int(hp, HP_DEFAULT, HP_MAXIMUM, HP_DEFAULT, HP)
	current_hp = full_hp


func connect_avatar_ui(hp_bar_node: Control) -> void:
	var err = connect("hp_changed", hp_bar_node, "update_value", \
	[], CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"hp_changed\" to ", hp_bar_node)
	
	hp_bar_node.activate(false)
	is_avatar_hp = true


func show_ui() -> void:
	if not is_avatar_hp:
		hp_ui.activate(true, get_parent().get_global_position())


func receive_damage(amount: int) -> void:
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	if not is_dead():
		if is_avatar_hp:
			emit_signal("hp_changed", float(current_hp) / float(full_hp) * 100)
		else:
			hp_ui.update_value(float(current_hp) / float(full_hp) * 100)
	else:
		hp_ui.hide()
	

func is_dead() -> bool:
	if current_hp > 0:
		return false
	return true

