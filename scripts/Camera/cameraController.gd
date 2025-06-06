extends Node3D

@onready var camera: Camera3D = $Camera3D

var rotation_angle: float = 45
var current_rotation_angle: float = 0
var is_rotating:= false

var zoom_increment:= 3
var current_zoom:= 17
var is_zooming:= false

const length := 125
var startPos: Vector2
var curPos: Vector2
var swiping:= false
var threshold := 50

const ray_length = 50
var intersection: Dictionary= {}


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("drag") and not swiping and not mouse_on_object():
		swiping = true
		startPos = get_viewport().get_mouse_position()
		pass
	if Input.is_action_pressed("drag") and swiping:
		curPos = get_viewport().get_mouse_position()
		if startPos.distance_to(curPos) >= length:
			if abs(startPos.y - curPos.y) <= threshold:
				if startPos.x > curPos.x:
					swiping = false
					rotation_left()
				elif startPos.x < curPos.x:
					swiping = false
					rotation_right()
			

func rotation_left() ->void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",current_rotation_angle + rotation_angle, 0.35)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y


func rotation_right() ->void:
	if is_rotating == false:
		var current_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",current_rotation_angle - rotation_angle, 0.35)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y

func mouse_on_object() ->bool:
	# Raycast from camera to mouse
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	# Store last intersection
	if result == {}:
		return false
	else:
		return true
