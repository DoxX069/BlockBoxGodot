extends StaticBody3D
class_name BlockController


@onready var block_manager: BlockManager= self.get_parent().get_parent()

var is_task_block: bool = false
var is_build_block: bool = false
var dragging_disabled := false
var start_drag_pos: Vector3
var dict_key: String

var state_machine: CallableStateMachine = CallableStateMachine.new()
var draggable := false
var dragged_block: Node3D
var ground_distance: float
var dropable := true
var falling:= false

@onready var camera: Camera3D = get_viewport().get_camera_3d()
const ray_length := 50
var ray_down: Dictionary
var intersection: Dictionary
var last_intersection: Dictionary
var offset: Vector3


func _ready() ->void:
	state_machine.add_states(Callable(self, "state_idle"), Callable(self, "enter_state_idle"), Callable(self, "leave_state_idle"))
	state_machine.add_states(Callable(self, "state_drag"), Callable(self, "enter_state_drag"), Callable(self, "leave_state_drag"))
	state_machine.add_states(Callable(self, "state_drop"), Callable(self, "enter_state_drop"), Callable(self, "leave_state_drop"))
	state_machine.add_states(Callable(self, "state_fall"), Callable(self, "enter_state_fall"), Callable(self, "leave_state_fall"))
	state_machine.set_initial_state(state_idle)


#func _process(_delta):
#	state_machine.update()
	
# or
func _physics_process(_delta) ->void:
	state_machine.update()


# States:

func enter_state_idle() ->void:
	if last_intersection:
		pass
		#reset_material(Global.last_intersection.collider)


func state_idle() ->void:
	raycast()
	raycast_down()
	if ray_down:
		ground_distance = ray_down.position.distance_to(self.global_transform.origin)
		
	if ground_distance > 1 and Global.falling_allowed and ray_down.collider != dragged_block:
		state_machine.change_state(state_fall)
	
	if Input.is_action_just_pressed("drag") and draggable and not dragging_disabled:
		state_machine.change_state(state_drag)
		

func leave_state_idle() ->void:
	# remove position from position array
	if is_task_block:
		for key in block_manager.task_block_positions.keys():
			var array_value = block_manager.task_block_positions[key]
			if array_value.has(self.position):
				dict_key = key
				array_value.erase(self.position)
	elif is_build_block:
		for key in block_manager.build_block_positions.keys():
			var array_value = block_manager.build_block_positions[key]
			if array_value.has(self.position):
				dict_key = key
				array_value.erase(self.position)
	block_manager.sort_dicts()


func enter_state_drag() ->void:
	raycast()
	start_drag_pos = self.position
	

func state_drag() ->void:
	raycast()
	var delta = get_process_delta_time()
	if intersection:
		# Change position while dragging
		self.global_position = lerp(self.global_position,intersection.position+Vector3(0,0.5,0),35*delta)
	
	if Input.is_action_just_released("drag"):
		state_machine.change_state(state_drop)


func leave_state_drag() ->void:
	pass


func enter_state_drop() ->void:
	raycast()
	raycast_down()
	block_manager.update_valid_pos()
	var new_pos: Vector3 = ray_down.collider.position + ray_down.normal
	var is_valid_pos:bool = block_manager.valid_build_pos.has(new_pos)
	
	var closest_distance: float = 100
	var fallback_pos: Vector3
	for pos in block_manager.valid_build_pos:
		if self.position.distance_to(pos) < closest_distance:
			fallback_pos = pos
			closest_distance = self.position.distance_to(pos)
	
	var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	if is_valid_pos:
		# Drop to the last raycast collider
		current_tween.tween_property(self,"global_position",new_pos,0.3)
		await current_tween.finished
		current_tween.kill()
		# Change state
		state_machine.change_state(state_idle)
	else:
		# Drop to the last raycast collider
		current_tween.tween_property(self,"global_position",fallback_pos,0.3)
		await current_tween.finished
		current_tween.kill()
		# Change state
		state_machine.change_state(state_idle)

func state_drop() ->void:
	pass
#	block_manager.build_block_positions.find_key(self.position).
#	key.val


func leave_state_drop() ->void:
	# add position to position array
	if is_task_block:
		var array_value = block_manager.task_block_positions[dict_key]
		array_value.append(self.position)
	elif is_build_block:
		var array_value = block_manager.build_block_positions[dict_key]
		array_value.append(self.position)
	block_manager.sort_dicts()
		
	
func enter_state_fall() ->void:
	var new_pos: Vector3 = ray_down.collider.position + ray_down.normal
	# add position to position array
	if is_task_block:
		var array_value = block_manager.task_block_positions[dict_key]
		array_value.append(new_pos)
	elif is_build_block:
		var array_value = block_manager.build_block_positions[dict_key]
		array_value.append(new_pos)
	block_manager.sort_dicts()
	
	raycast_down()
	Global.falling_allowed = false
	if ray_down:
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(self,"global_position",new_pos,0.1)
		await current_tween.finished
		Global.falling_allowed = true
		state_machine.change_state(state_idle)
	else:
		state_machine.change_state(state_idle)


func state_fall() ->void:
	pass
		
	
func leave_state_fall() ->void:
	pass
	
	
# Functions:

func raycast():
	# Raycast from camera to mouse
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * ray_length
	var layers
	if is_task_block:
		layers = 4 | 2
	elif is_build_block:
		layers = 1 | 2
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers,[])
	if dragged_block:
		query.exclude = [dragged_block]
	query.collide_with_areas = true
	intersection = space_state.intersect_ray(query)
	# Store last intersection except for the platform area
	if intersection and intersection.collider != $"../../../platform/Area3D":
		last_intersection = intersection


func _on_mouse_entered() -> void:
	draggable = true
	dragged_block = self # For ignoring dragged block in raycast intersection


func _on_mouse_exited() -> void:
	draggable = false
	dragged_block = null # For ignoring dragged block in raycast intersection


func raycast_down() ->void:
	var space_state = self.get_world_3d().direct_space_state
	var origin = self.position
	var end = origin + Vector3(0,-1,0) * ray_length
	var layers
	if is_task_block:
		layers = 4 | 2
	elif is_build_block:
		layers = 1 | 2
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers, [])
	if dragged_block:
		query.exclude = [dragged_block]
	var result = space_state.intersect_ray(query)
	if result:
		ray_down = result
	

func change_material(node: Node3D) ->void:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(10,10,10)
	if node.get_node("MeshInstance3D"):
		node.get_node("MeshInstance3D").material_override = material
	else:
		pass


func reset_material(node: Node3D):
	if node.get_node("MeshInstance3D"):
		node.get_node("MeshInstance3D").material_override = null
	else:
		pass
