extends Node3D



func _ready() -> void:
	loop_rotation()


func loop_rotation():
	var tween: Tween = create_tween()
	tween.set_ease(tween.EASE_IN_OUT)
	tween.set_trans(tween.TRANS_EXPO)
	tween.set_loops()
	
	tween.tween_property(self,"rotation_degrees:y", 90, 3)
	tween.tween_property(self,"rotation_degrees:y", 180, 3)
	tween.tween_property(self,"rotation_degrees:y", 270, 3)
	tween.tween_property(self,"rotation_degrees:y", 360, 3)
	tween.tween_property(self,"rotation_degrees:y", 0, 0)
	
