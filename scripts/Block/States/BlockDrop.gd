extends BlockState
class_name BlockDrop

func enter() ->void:
	raycast_down()
	var current_tween := get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
	if Global.intersection:
		# Drop to the last raycast collider
		if Global.intersection.normal == Vector3(0,1,0):
			current_tween.tween_property(block,"global_position",Global.last_intersection.collider.position + Global.last_intersection.normal,0.5)
			await current_tween.finished
			current_tween.kill()
			# Change state
			finished.emit(self, "idle")

		# Fall when dropped on the side
		elif Global.intersection.normal != Vector3(0,1,0) and ray_down:
			current_tween.tween_property(block,"global_position",ray_down.collider.position + Vector3(0,1,0),0.5)
			await current_tween.finished
			current_tween.kill()
			# Change state
			finished.emit(self, "idle")
