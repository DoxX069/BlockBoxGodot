extends Node3D
class_name SwipeDetector

	
var start_pos: Vector2
var previous_pos: Vector2
var mouse_pos: Vector2
var delta_pos: Vector2
var mouse_vel: Vector2
var swipe_distance := 125
var swipe_vel := 1000
var swiping := false
signal swipe_up
signal swipe_down
signal swipe_left
signal swipe_right
	
@export var camera: Camera3D
var ray_length := 100

	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("drag") and not mouse_on_object():
		swiping = true
		mouse_pos = get_viewport().get_mouse_position()
		start_pos = mouse_pos
		previous_pos = mouse_pos
	elif Input.is_action_pressed("drag") and swiping:
		mouse_pos = get_viewport().get_mouse_position()
		delta_pos = mouse_pos - start_pos
		mouse_vel = abs((mouse_pos - previous_pos) / delta)
		previous_pos = mouse_pos
		
		if delta_pos.length() > swipe_distance:
			swiping = false
			if mouse_vel.y > swipe_vel:
				if abs(delta_pos.y) > abs(delta_pos.x):
					if delta_pos.y < 0:
						emit_signal("swipe_up")
					elif delta_pos.y > 0:
						emit_signal("swipe_down")
			elif mouse_vel.x > swipe_vel:
				if abs(delta_pos.x) > abs(delta_pos.y):
					if delta_pos.x < 0:
						emit_signal("swipe_left")
					elif delta_pos.x > 0:
						emit_signal("swipe_right")
	
					
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
