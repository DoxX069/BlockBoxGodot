extends BlockState
class_name BlockIdle

func enter() ->void:
	if Global.last_intersection:
		reset_material(Global.last_intersection.collider)

func physics_update(_delta: float) -> void:
	raycast_down()
	if ray_down:
		ground_distance = ray_down.position.distance_to(block.global_transform.origin)
		
	if ground_distance > 1 and not Global.falling:
		finished.emit(self, "fall")
		
	if Input.is_action_just_pressed("drag") and draggable:
		finished.emit(self, "drag")
		
func _on_block_mouse_entered() -> void:
	draggable = true
	Global.dragged_block = block # For ignoring dragged block in raycast intersection
	
func _on_block_mouse_exited() -> void:
	draggable = false
	Global.dragged_block = null # For ignoring dragged block in raycast intersection
