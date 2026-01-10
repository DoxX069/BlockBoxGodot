extends Node3D



@export_enum("fade", "wipe") var transition_type: String
@export_range(0, 10, 0.1) var duration: float = 1

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
	SceneTransitionController.change_scene("res://scenes/task.tscn", transition_type, duration)


func _on_block_manager_blocks_removed() -> void:
	SceneTransitionController.change_scene("res://scenes/main_menu.tscn", transition_type, duration)
