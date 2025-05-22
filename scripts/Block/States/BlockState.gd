extends State
class_name BlockState

var block: Node3D
var draggable := false
var ground_distance: float
var dropable := true
const ray_length = 1000
var ray_down: Dictionary
 
func _ready() -> void:
	block = get_node("../..")

func raycast_down():
	var space_state = block.get_world_3d().direct_space_state
	var origin = block.position
	var end = origin + Vector3(0,-1,0) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	if result:
		ray_down = result
	
func change_material(node: Node3D) ->void:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(10,10,10)
	if node.get_node("MeshInstance3D"):
		node.get_node("MeshInstance3D").material_override = material
	else:
		pass

func reset_material(node: Node3D):
	if node.get_node("MeshInstance3D"):
		node.get_node("MeshInstance3D").material_override = null
	else:
		pass
