extends Node3D


@export var swipe_detector: SwipeDetector

var current_rotation_angle: float = 0
var is_rotating:= false

var start_pos: Vector2
var mouse_pos: Vector2
var delta_pos: Vector2
var swiping := false
	
@onready var camera: Camera3D = get_viewport().get_camera_3d()
var ray_length := 100


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("drag") and not mouse_on_object():
		swiping = true
		start_pos = get_viewport().get_mouse_position()
		current_rotation_angle = self.rotation_degrees.y
	elif Input.is_action_pressed("drag") and swiping:
		mouse_pos = get_viewport().get_mouse_position()
		delta_pos = mouse_pos - start_pos
		self.rotation_degrees.y = lerpf(self.rotation_degrees.y, current_rotation_angle + delta_pos.x * 0.3, 20 * delta) 
	elif Input.is_action_just_released("drag"):
		current_rotation_angle = self.rotation_degrees.y
		swiping = false
		snap_rotation()
	
					
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


func snap_rotation() ->void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",snappedf(self.rotation_degrees.y, 45), 0.3)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y
		
