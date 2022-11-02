extends Node2D

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


# for avatar
func add_money(addition: int) -> void:
	money += addition


# for avatar
func update_ui() -> void:
	# emit_signal("ui_update_money", money)
	pass
