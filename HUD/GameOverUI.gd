extends Control


func _ready():
	Signals.connect("game_over", self, "on_game_over")


func _on_RestartButton_pressed():
	get_tree().reload_current_scene()


func on_game_over():
	self.show()


