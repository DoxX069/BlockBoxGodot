extends Node




var is_rotating: bool = false



func _ready() -> void:
	snap_rotation()
	
	
func snap_rotation() ->void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",snapped(self.rotation_degrees.y, 90), 0.3).from_current()
		await current_tween.finished
		is_rotating = false



func _on_rotate_right_pressed() -> void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y", -90, 0.3).from_current()
		await current_tween.finished
		is_rotating = false


func _on_rotate_left_pressed() -> void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y", +90, 0.3).from_current()
		await current_tween.finished
		is_rotating = false
