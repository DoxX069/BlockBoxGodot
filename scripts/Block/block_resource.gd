extends Resource
class_name BlockResource

var block_name: String

var material: Material

var position: Vector3

var collision_layer: int
var collision_mask: int

var dragging_disabled: bool

var is_task_block: bool
var is_build_block: bool

func get_neighbors() ->Array:
	var neighbors: Array
	if position:
		neighbors = [
			position-Vector3(1,0,0), position+Vector3(1,0,0),
			position+Vector3(0,1,0),
			position-Vector3(0,0,1), position+Vector3(0,0,1)
		]
		return neighbors
	else:
		neighbors = []
		return neighbors
