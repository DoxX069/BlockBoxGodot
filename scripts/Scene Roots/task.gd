extends Node3D



@export_enum("fade", "wipe") var transition_type: String
@export_file_path("*.tscn") var next_scene: String
@export_range(0, 10, 0.1) var duration: float = 1
@export var camera: Camera3D



func _ready() -> void:
	# Change camera
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "size", 6, 0.3)


func _on_play_pressed() -> void:
	SceneTransitionController.change_scene(next_scene, transition_type, duration)
