extends Node3D

@onready var camera: Camera3D = $Camera3D

var rotation_angle: float = 45
var current_rotation_angle: float = 0
var is_rotating:= false

var zoom_increment:= 3
var current_zoom:= 17
var is_zooming:= false


func _physics_process(delta: float) -> void:
	rotation()
	zoom()	


func rotation() ->void:
	var current_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	if Input.is_action_just_pressed("rotate-") and not is_rotating:
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",current_rotation_angle - rotation_angle, 0.35)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y
	elif Input.is_action_just_pressed("rotate+") and not is_rotating:
		is_rotating = true
		current_tween.tween_property(self,"rotation_degrees:y",current_rotation_angle + rotation_angle, 0.35)
		await current_tween.finished
		is_rotating = false
		current_rotation_angle = self.rotation_degrees.y


func zoom() ->void:
	var current_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	if Input.is_action_just_pressed("zoom in") and not is_zooming:
		is_zooming = true
		current_tween.tween_property(camera,"size",clamp(current_zoom - zoom_increment,5,20), 0.35)
		await current_tween.finished
		is_zooming = false
		current_zoom = camera.size
	elif Input.is_action_just_pressed("zoom out") and not is_zooming:
		is_zooming = true
		current_tween.tween_property(camera,"size",clamp(current_zoom + zoom_increment,5,20), 0.35)
		await current_tween.finished
		is_zooming = false
		current_zoom = camera.size
	
