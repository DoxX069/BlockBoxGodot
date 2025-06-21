extends Node3D


@export var swipe_detector: SwipeDetector

var rotation_angle: float = 90
var current_rotation_angle: float = 0
var is_rotating:= false


func _on_swipe_detector_swipe_left() -> void:
	rotation_left()


func _on_swipe_detector_swipe_right() -> void:
	rotation_right()


func rotation_right() ->void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",current_rotation_angle + rotation_angle, 0.3)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y


func rotation_left() ->void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",current_rotation_angle - rotation_angle, 0.3)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y
