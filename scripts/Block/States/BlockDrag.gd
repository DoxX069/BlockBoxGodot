extends BlockState
class_name BlockDrag

var offset: Vector3
var distance_to_intersection: float

func enter() -> void:
	pass

func physics_update(delta: float) ->void:
	if Global.intersection:
		#change_material(Global.last_intersection.collider)
		# Change position while dragging
		block.global_transform.origin = lerp(block.global_transform.origin, Global.intersection.position + Global.intersection.normal * 0.5 , 15 * delta)
		# Change state
	if Input.is_action_just_released("drag"):
		finished.emit(self, "drop")
