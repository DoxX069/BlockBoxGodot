extends Node3D


@export var camera: Camera3D
@export var build_timer: CustomTimer





func _ready() -> void:
	# Change camera size
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "size", 5.5, 0.3)
	
	# Start Timer
	if build_timer.is_stopped:
		build_timer.start()
	else:
		build_timer.resume()



func _on_block_manager_blocks_matching() -> void:
	get_tree().change_scene_to_file("res://scenes/task.tscn")


func _on_block_manager_blocks_removed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
