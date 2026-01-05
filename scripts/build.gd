extends Node3D


func _on_custom_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_block_manager_blocks_matching() -> void:
	get_tree().change_scene_to_file("res://scenes/task.tscn")
