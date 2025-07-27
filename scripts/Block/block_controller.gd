extends StaticBody3D
class_name Block


@onready var block_manager: BlockManager= self.get_parent()
@onready var block_mesh: MeshInstance3D = self.get_child(0).get_child(0)

var is_task_block: bool = false
var is_build_block: bool = false
var dragging_disabled := false
var dict_key: String
var idle_pos: Vector3

var state_machine: CallableStateMachine = CallableStateMachine.new()
var draggable := false
var dragged_block: Node3D
var ground_distance: float
var dropable := true
var falling:= false

@onready var camera: Camera3D = get_viewport().get_camera_3d()
const ray_length := 100
var ray_down: Dictionary
var ray_up: Dictionary
var intersection: Dictionary
var last_intersection: Dictionary
var offset: Vector3


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
	pass
	

func state_idle() ->void:
	raycast()
	raycast_down()
	if ray_down:
		ground_distance = ray_down.position.distance_to(self.global_position)
		
	if ground_distance >= 1.5 and Global.falling_allowed and is_build_block and not is_task_block:
		state_machine.change_state(state_fall)
	
	if Input.is_action_just_pressed("drag") and draggable and not block_manager.dragging_disabled and is_build_block and not is_task_block:
		state_machine.change_state(state_drag)
		

func leave_state_idle() ->void:
	block_manager.build_block_pos.erase(self.position)
	block_manager.update_build_valid_pos()
	print(" --- Build Blocks --- ")
	for pos in block_manager.build_block_pos:
		print(pos)
	# update start drag position
	idle_pos = self.position


func enter_state_drag() ->void:
	raycast()
	# ignore dragged block in raycast intersection
	Global.dragged_block = self
	
	var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	current_tween.tween_property(block_mesh,"scale",Vector3(1.1, 1.1, 1.1),0.2)
	

func state_drag() ->void:
	raycast()
	var delta = get_process_delta_time()
	if intersection:
		# Change position while dragging
		self.global_position = lerp(self.global_position,intersection.position+Vector3(0,0.6,0),20*delta)
	
	if Input.is_action_just_released("drag"):
		state_machine.change_state(state_drop)


func leave_state_drag() ->void:
	var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	current_tween.tween_property(block_mesh,"scale",Vector3(1, 1, 1),0.2)


func enter_state_drop() ->void:
	raycast()
	raycast_down()
	var new_pos: Vector3 = ray_down.collider.position + ray_down.normal
	var is_valid_pos:bool = block_manager.build_valid_pos.has(new_pos)
	var closest_distance: float = 100
	var fallback_pos: Vector3
	for pos in block_manager.build_valid_pos:
		if self.global_position.distance_to(pos) < closest_distance:
			fallback_pos = pos
			closest_distance = self.global_position.distance_to(pos)
	
	var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	if is_valid_pos:
		# Drop to the last raycast collider
		current_tween.tween_property(self,"position",new_pos,0.3)
		await current_tween.finished
		current_tween.kill()
		# Change state
		state_machine.change_state(state_idle)
	else:
		# Drop to the last raycast collider
		current_tween.tween_property(self,"position",fallback_pos,0.3)
		await current_tween.finished
		current_tween.kill()
		# Change state
		state_machine.change_state(state_idle)

func state_drop() ->void:
	pass


func leave_state_drop() ->void:
	# ignore dragged block in raycast intersection
	Global.dragged_block = null
	# update block position
	block_manager.update_build_block_pos(self.position)
	

func enter_state_fall() ->void:
	raycast_down()
	# set new position
	var new_pos: Vector3 = ray_down.collider.position + ray_down.normal
		
	# fall
	Global.falling_allowed = false
	var current_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	current_tween.tween_property(self,"position",new_pos,0.1)
	await current_tween.finished
	Global.falling_allowed = true
	state_machine.change_state(state_idle)


func state_fall() ->void:
	pass
		
	
func leave_state_fall() ->void:
	# update block position
	block_manager.update_build_block_pos(self.position)
	
	
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
	var layers
	if is_task_block:
		layers = 4 | 2
	else:
		layers = 1 | 2
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers,[])
	if Global.dragged_block:
		query.exclude = [Global.dragged_block]
	query.collide_with_areas = true
	intersection = space_state.intersect_ray(query)
	# Store last intersection except for the platform area
	if intersection and intersection.collider != $"../../platform/Area3D":
		last_intersection = intersection


func raycast_down() ->void:
	var space_state = self.get_world_3d().direct_space_state
	var origin = self.global_position
	var end = origin + Vector3(0,-1,0) * ray_length
	var layers
	if is_task_block:
		layers = 4 | 2
	else:
		layers = 1 | 2
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers, [])
	var result = space_state.intersect_ray(query)
	if result:
		ray_down = result
		
		
func raycast_up() ->void:
	var space_state = self.get_world_3d().direct_space_state
	var origin = self.global_position
	var end = origin + Vector3(0,1,0) * ray_length
	var layers
	if is_task_block:
		layers = 4
	else:
		layers = 1
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers, [])
	var result = space_state.intersect_ray(query)
	if result:
		print(self.name+": block above")
		dragging_disabled = true
	else:
		dragging_disabled = false
		print(self.name+": free above")
	
