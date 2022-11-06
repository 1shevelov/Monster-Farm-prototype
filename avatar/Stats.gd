extends Node


var start_life_moment: float = 0.0
var end_life_moment: float = 0.0
var jumps: int = 0

var total_money: int = 0
var coins_picked: int = 0
var total_damage_dealt: int = 0
var destroyed_obstacles: int = 0
var killed_one_hit_mobs: int = 0

# derivative counters
#var money_per_min: int  # total_money / minutes of life
#var money_per_jump: int  # total_money / jumps
# damage_per_minute: int


func start_life() -> void:
	start_life_moment = Time.get_unix_time_from_system()


func end_life() -> void:
	end_life_moment = Time.get_unix_time_from_system()


# clear on the avatar's death
func reset() -> void:
	start_life_moment = 0.0
	end_life_moment = 0.0
	total_money = 0
	total_damage_dealt = 0
	destroyed_obstacles = 0
	killed_one_hit_mobs = 0
	coins_picked = 0


func get_finals() -> Dictionary:
	var life_time: float
	if start_life_moment == 0.0 or end_life_moment == 0.0:
		print_debug("Start or end life moments are not set")
	life_time = end_life_moment - start_life_moment
	return {
		"Life time": life_time,
		"Money": total_money,
		"Total damage": total_damage_dealt,
		"Destroyed obstacles": destroyed_obstacles,
		"Killed one-hit-mobs": killed_one_hit_mobs,
		"Coins picked": coins_picked,
		"Money per minute": round(total_money / life_time * 60),
		"Money per jump": round(total_money / float(jumps)),
		"Damage per minute": round(total_damage_dealt / life_time * 60)
	}


