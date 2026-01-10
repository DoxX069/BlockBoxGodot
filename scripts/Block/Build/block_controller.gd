extends StaticBody3D
class_name BuildBlockController



@onready var block_manager: BlockManager = self.get_parent()
var ray_result: Dictionary
var ray_down_result: Dictionary
var dragged_block: StaticBody3D
var draggable: bool = false
var falling_allowed: bool = true
var new_pos: Vector3
var old_pos: Vector3

var state_machine: CallableStateMachine = CallableStateMachine.new()



func _ready() ->void:
	state_machine.add_states(Callable(self, "state_idle"), Callable(self, "enter_state_idle"), Callable(self, "leave_state_idle"))
	state_machine.add_states(Callable(self, "state_drag"), Callable(self, "enter_state_drag"), Callable(self, "leave_state_drag"))
	state_machine.add_states(Callable(self, "state_drop"), Callable(self, "enter_state_drop"), Callable(self, "leave_state_drop"))
	state_machine.add_states(Callable(self, "state_fall"), Callable(self, "enter_state_fall"), Callable(self, "leave_state_fall"))
	state_machine.set_initial_state(state_idle)


func _physics_process(_delta) ->void:
	state_machine.update()



# States:

func enter_state_idle() ->void:
	# Save old position
	old_pos = round(self.position)
	

func state_idle() ->void:
	# Change to falling state
	if Global.build_block.valid_pos.has(old_pos - Vector3(0, 1, 0)):
		state_machine.change_state(state_fall)
	
	# Change to drag state
	if Input.is_action_just_pressed("drag") and draggable:
		state_machine.change_state(state_drag)
		

func leave_state_idle() ->void:
	block_manager.update_pos(Global.build_block, Vector3(), old_pos)


func enter_state_drag() ->void:
	# Set self as being dragged
	dragged_block = self
	
	# Animate scale
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"scale",Vector3(1.05, 1.05, 1.05),0.2)
	

func state_drag() ->void:
	# Update raycast
	raycast()
	
	# Change position while dragging
	var delta = get_process_delta_time()
	self.position = lerp(self.position, ray_result.position + Vector3(0,0.6,0), 45 * delta)
	
	# Change to drop state
	if Input.is_action_just_released("drag"):
		state_machine.change_state(state_drop)


func leave_state_drag() ->void:
	# Set self as not being dragged
	dragged_block = null
	
	# Animate scale
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"scale",Vector3(1, 1, 1),0.2)


func enter_state_drop() ->void:
	# Set new position
	new_pos = get_closest_valid_position()
	
	# Claim new position
	block_manager.update_pos(Global.build_block, new_pos)
	
	# Animate drop
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"position",new_pos,0.3)
	await tween.finished
	
	# Change to idle state
	state_machine.change_state(state_idle)


func state_drop() ->void:
	pass


func leave_state_drop() ->void:
	pass
	

func enter_state_fall() ->void:
	# Set new position
	new_pos = old_pos - Vector3(0, 1, 0)
	
	# Claim new position
	block_manager.update_pos(Global.build_block, new_pos)

	# Animate fall
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"position",new_pos,0.1)
	await tween.finished
	
	# Change to idle state
	state_machine.change_state(state_idle)


func state_fall() ->void:
	pass
		
	
func leave_state_fall() ->void:
	pass



func _on_mouse_entered() -> void:
	draggable = true
	

func _on_mouse_exited() -> void:
	draggable = false


func get_closest_valid_position():
	var closest_distance: float = 100
	var closest_pos: Vector3
	for pos in Global.build_block.valid_pos:
		if self.position.distance_to(pos) < closest_distance:
			# Set new position
			closest_pos = pos
			closest_distance = self.position.distance_to(pos)
	return closest_pos


func raycast():
	# Raycast from camera to mouse
	var camera: Camera3D = get_viewport().get_camera_3d()
	const ray_length: int = 100
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var end: Vector3 = origin + camera.project_ray_normal(mouse_pos) * ray_length
	var layers: int = 1 | 2
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, layers,[])
	if dragged_block:
		query.exclude = [dragged_block]
	query.collide_with_areas = true
	ray_result = space_state.intersect_ray(query)
