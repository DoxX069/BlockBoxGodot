extends Node3D

@onready var build_blocks := $BuildBlocks
@onready var task_blocks := $TaskBlocks


var start_pos: Vector2
var mouse_pos: Vector2
var delta_pos: Vector2
var swipe_distance := 125
var swiping := false
	
@onready var camera := $"../CameraRig/Camera3D"
var ray_length := 100	


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("drag") and not mouse_on_object():
		swiping = true
		start_pos = get_viewport().get_mouse_position()
	elif Input.is_action_just_released("drag") and swiping:
		swiping = false
		delta_pos = get_viewport().get_mouse_position() - start_pos
		if delta_pos.length() > swipe_distance:
			if abs(delta_pos.y) > abs(delta_pos.x):
				if delta_pos.y < 0:
					build_blocks.visible = false
					task_blocks.visible = true
				elif delta_pos.y > 0:
					build_blocks.visible = true
					task_blocks.visible = false
						
		
func mouse_on_object() ->bool:
	# Raycast from camera to mouse
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1,[])
	var result = space_state.intersect_ray(query)
	# Store last intersection
	if result == {}:
		return false
	else:
		return true
		

# Block Manager:

# - switch between showing Build- or TaskBlocks

# - store BuildBlock / TaskBlock in array
# - pick random Block
# - first block always in the middle
# - instantiate blocks at random neighbour positions stored in array

# - store BuildBlock / TaskBlock positions in array
# - check if they are matching
