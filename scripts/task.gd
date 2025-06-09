extends Node3D


func _on_middle_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
