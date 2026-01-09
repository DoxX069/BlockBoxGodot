extends Node3D


@export var camera: Camera3D


func _ready() -> void:
	# Change camera
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "size", 6, 0.3)
