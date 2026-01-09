extends TextureProgressBar


@export var timer: CustomTimer


func _physics_process(_delta: float) -> void:
	if timer.is_stopped:
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		current_tween.tween_property(self,"value",0,0.15)
	else:
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		current_tween.tween_property(self,"value",(timer.duration - timer.time_left) / timer.duration * 100,0.15)
