extends Control

func _ready():
	pass

func _process(_delta):
	pass
	

func _on_middle_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/task.tscn")
