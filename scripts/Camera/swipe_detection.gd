extends Camera3D

const length := 100
var startPos: Vector2
var curPos: Vector2
var swiping:= false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("drag"):
		if swiping == false:
			swiping = true
			startPos = get_viewport().get_mouse_position()
			print("Start Position: ", startPos)
	if Input.is_action_pressed("drag"):
		if swiping:
			curPos = get_viewport().get_mouse_position()
			if startPos.distance_to(curPos) >= length:
				print("Swipe Detected!")
				swiping = false
	else: 
		swiping = false
				
