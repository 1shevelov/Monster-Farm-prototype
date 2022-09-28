extends Control


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("update_score", self, "on_update_score")
	$RichTextLabel.text = String(Globals.INITIAL_SCORE)


func on_update_score(new_score: int):
	$RichTextLabel.text = String(new_score)
	
