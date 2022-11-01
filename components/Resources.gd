extends Node2D

const MONEY := "money"
const MONEY_MIN := "min"
const MONEY_MAX := "max"

const MONEY_MAXIMUM := 1000000
const MONEY_DEFAULT := 0

var money: int = MONEY_DEFAULT


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
func give_away() -> int:
	var whole_summ := money
	money = MONEY_DEFAULT
	return whole_summ


# returns part of the summ, but no less then 1
func give_a_part(percent: float) -> int:
	var part = int(ceil(money * percent))
	money -= part
	return part

