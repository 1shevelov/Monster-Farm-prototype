extends Node2D

const HP := "hp"
const HP_MIN := "min"
const HP_MAX := "max"

const HP_MAXIMUM := 1000000
var full_hp: int = 0
var current_hp: int = 0

const HP_DEFAULT := 1

onready var hp_ui := $HPBarUI


func init(hp) -> void:
	if typeof(hp) == TYPE_DICTIONARY:
		Json.validate_dic_of_int(hp, HP_DEFAULT, HP_MAXIMUM, HP_DEFAULT, HP)
		# TODO: test resulting values
		full_hp = randi() % (hp[HP_MAX] - hp[HP_MIN] + 1) + hp[HP_MIN]
	else:
		full_hp = Json.validate_int(hp, HP_DEFAULT, HP_MAXIMUM, HP_DEFAULT, HP)
	current_hp = full_hp


func show_ui() -> void:
	if get_parent().name == Globals.AVATAR_NODE_NAME:
		hp_ui.activate(false)
	else:
		hp_ui.activate(true, get_parent().get_global_position())


func receive_damage(amount: int) -> void:
	current_hp -= amount
	if not is_dead():
		hp_ui.update_value(float(current_hp) / float(full_hp) * 100)
	else:
		hp_ui.hide()
	

func is_dead() -> bool:
	if current_hp > 0:
		return false
	return true

