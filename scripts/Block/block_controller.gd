extends StaticBody3D
class_name BlockController



@onready var block_manager: BlockManager = self.get_parent()

var dragging_disabled := false
var dict_key: String
var idle_pos: Vector3


var draggable := false
var dragged_block: StaticBody3D
var ground_distance: float
var dropable := true
var falling:= false
var falling_allowed := true

@onready var camera: Camera3D = get_viewport().get_camera_3d()
const ray_length := 100
var ray_down: Dictionary
var ray_up: Dictionary
var intersection: Dictionary
var last_intersection: Dictionary
var offset: Vector3


func _ready() ->void:
	pass


func _physics_process(_delta) ->void:
	pass



	
	
# Functions:
func _on_mouse_entered() -> void:
	draggable = true
	

func _on_mouse_exited() -> void:
	draggable = false


func raycast():
	# Raycast from camera to mouse
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * ray_length
	var layers = 1 | 2
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers,[])
	if dragged_block:
		query.exclude = [dragged_block]
	query.collide_with_areas = true
	intersection = space_state.intersect_ray(query)
	# Store last intersection except for the platform area
	if intersection and intersection.collider != $"../../platform/Area3D":
		last_intersection = intersection


func raycast_down() ->void:
	var space_state = self.get_world_3d().direct_space_state
	var origin = self.global_position
	var end = origin + Vector3(0,-1,0) * ray_length
	var layers = 1 | 2
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers, [])
	var result = space_state.intersect_ray(query)
	if result:
		ray_down = result
		
