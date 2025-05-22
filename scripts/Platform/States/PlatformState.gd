extends State
class_name PlatformState

var platform: Node3D
var dropable := true
const ray_length = 1000
 
func _ready() -> void:
	platform = get_node("../..")

func raycast_down():
	var space_state = platform.get_world_3d().direct_space_state
	
	var origin = platform.position
	var end = origin + Vector3(0,-1,0) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	if result:
		Global.under_block_position = result.position
		Global.under_block = result.collider
	
func raycast_up():
	var space_state = platform.get_world_3d().direct_space_state

	var origin = platform.position
	var end = origin + Vector3(0,1,0) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	if result:
		Global.block_above = result.collider
		print(Global.block_above)
