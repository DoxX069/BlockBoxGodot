extends Node3D


var rotation_angle: float = 90
var current_rotation_angle: float = 0
var is_rotating:= false

@onready var camera := $Camera3D
var ray_length := 100

var start_pos: Vector2
var mouse_pos: Vector2
var delta_pos: Vector2
var swipe_distance := 125
var swiping := false
	

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("drag") and not mouse_on_object():
		swiping = true
		start_pos = get_viewport().get_mouse_position()
	elif Input.is_action_just_released("drag") and swiping:
		swiping = false
		delta_pos = get_viewport().get_mouse_position() - start_pos
		if delta_pos.length() > swipe_distance:
			if abs(delta_pos.x) > abs(delta_pos.y):
				if delta_pos.x < 0:
					rotation_left()
				elif delta_pos.x > 0:
					rotation_right()
					

func mouse_on_object() ->bool:
	# Raycast from camera to mouse
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1, [])
	var result = space_state.intersect_ray(query)
	# Store last intersection
	if result == {}:
		return false
	else:
		return true


func rotation_left() ->void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",current_rotation_angle + rotation_angle, 0.35)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y


func rotation_right() ->void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",current_rotation_angle - rotation_angle, 0.35)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y


					
	# add checking for swiping speed (if to low stop swipe)
