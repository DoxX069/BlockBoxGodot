extends Node3D

var rotation_finished = true
var zoom_finished = true
@export var rotationAngle: float = 45
var currentRotationAngle: float = 0
var rotationTween
#animation Curve (with tweens)
var zoomTween

var cameraZoom: float
var maxZoom: int = 125
var minZoom: int = 25
@export var zoomIncrement: float = 25
var zoomTarget: Vector3= Vector3(0,0,0)
var newPosition: Vector3
var blocks: Node3D

func _ready() -> void:
	blocks = get_node("../Blocks")
	cameraZoom = $Camera3D.global_transform.origin.distance_to(zoomTarget)

func _process(_delta):
	#if Global.closest_block.idle.is_dragging == false:
	if Input.is_action_just_pressed("rotate-") and zoom_finished:
		rotation_finished = false
		rot_tween(snapped(rotation.y -deg_to_rad(rotationAngle), 0.78539816339745))
		await rotationTween.finished
		if rotationTween and rotationTween.is_running():
			rotationTween.kill()
				
	elif Input.is_action_just_pressed("rotate+") and zoom_finished:
		rotation_finished = false
		rot_tween(snapped(rotation.y +deg_to_rad(rotationAngle), 0.78539816339745))
		await rotationTween.finished
		if rotationTween and rotationTween.is_running():
			rotationTween.kill()
				
	var zoomDirection: Vector3 = (self.global_position - $Camera3D.global_transform.origin).normalized()
		
	if Input.is_action_just_pressed("zoom in") and rotation_finished:
		zoom_finished = false
		cameraZoom = clamp(cameraZoom - zoomIncrement, minZoom, maxZoom)
		newPosition = self.global_position - zoomDirection * cameraZoom
		
		zoo_tween(newPosition)
		await zoomTween.finished
		if zoomTween and zoomTween.is_running():
			zoomTween.kill()
			
	elif Input.is_action_just_pressed("zoom out") and rotation_finished:
		zoom_finished = false
		cameraZoom = clamp(cameraZoom + zoomIncrement, minZoom, maxZoom) 
		newPosition = self.global_position - zoomDirection * cameraZoom
			
		zoo_tween(newPosition)
		await zoomTween.finished
		if zoomTween and zoomTween.is_running():
			zoomTween.kill()

func zoo_tween(zoom: Vector3) ->void:
	print(zoom)
	if zoomTween and zoomTween.is_running():
		zoomTween.kill()
	zoomTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	zoomTween.tween_property($Camera3D,"global_position",zoom,0.35)
	zoomTween.finished.connect(func():
		zoom_finished = true
	)

func rot_tween(angle: float) ->void:
	if rotationTween and rotationTween.is_running():
		rotationTween.kill()
	rotationTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	rotationTween.tween_property(self,"rotation:y",angle,0.35)
	rotationTween.finished.connect(func():
		rotation_finished = true
	)
