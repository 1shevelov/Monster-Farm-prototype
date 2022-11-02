extends Node2D

signal money_changed

const MONEY := "money"
const MONEY_MIN := "min"
const MONEY_MAX := "max"

const MONEY_MAXIMUM := 1000000
const MONEY_DEFAULT := 0

var money: int = MONEY_DEFAULT

onready var sound = $MoneySound


func init_component(money_data) -> void:
	if typeof(money_data) == TYPE_DICTIONARY:
		Json.validate_dic_of_int(money_data, MONEY_DEFAULT, MONEY_MAXIMUM, \
		MONEY_DEFAULT, MONEY)
		money = randi() % (money_data[MONEY_MAX] - \
		money_data[MONEY_MIN] + 1) + money_data[MONEY_MIN]
	else:
		money = Json.validate_int(money_data, MONEY_DEFAULT, MONEY_MAXIMUM, \
		MONEY_DEFAULT, MONEY)


func connect_avatar_ui(money_counter_node: Control) -> void:
	var err = connect("money_changed", money_counter_node, "update_counter", \
	[money], CONNECT_DEFERRED)
	if err:
		print_debug("Error connecting \"money_changed\" to ", money_counter_node)


# empties the purse
# should play the sound only if money is given to avatar
func give_all() -> int:
	if money > MONEY_DEFAULT and not Globals.SILENT_MODE:
		sound.play()
	var whole_summ := money
	money = MONEY_DEFAULT
	return whole_summ


# returns part of the summ, but no less then 1
func give_a_part(percent: float) -> int:
	if money > MONEY_DEFAULT and not Globals.SILENT_MODE:
		sound.play()
	var part = int(ceil(money * percent))
	money -= part
	return part


func avatar_add_money(addition: int) -> void:
	if addition > 0:
		money += addition
		emit_signal("money_changed")


func avatar_remove_money(subtraction: int) -> void:
	if subtraction > 0:
		money -= subtraction
		if money < 0:
			money = 0
		emit_signal("money_changed")

