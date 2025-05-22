extends BlockState
class_name BlockFall

func enter() ->void:
	raycast_down()
	Global.falling = true
	if ray_down:
		var current_tween := get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(block,"global_position",ray_down.collider.position + Vector3(0,1,0),0.15)
		await current_tween.finished
		Global.falling = false
		finished.emit(self, "idle")
	else:
		finished.emit(self, "idle")
