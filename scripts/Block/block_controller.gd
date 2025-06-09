extends RigidBody3D

var state_machine: CallableStateMachine = CallableStateMachine.new()
var draggable := false
var dragged_block: Node3D
var ground_distance: float
var dropable := true
var falling:= false

@onready var camera: Camera3D = $"../../../CameraRig/Camera3D"
const ray_length = 50
var ray_down: Dictionary
var intersection: Dictionary
var last_intersection: Dictionary


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
		
	if ground_distance > 1 and not Global.falling:
		state_machine.change_state(state_fall)
	
	if Input.is_action_just_pressed("drag") and draggable:
		state_machine.change_state(state_drag)
		

func leave_state_idle() ->void:
	pass


func enter_state_drag() ->void:
	pass


func state_drag() ->void:
	raycast()
	var delta = get_process_delta_time()
	if intersection:# and space_is_free(self, self.position):
		#change_material(Global.last_intersection.collider)
		# Change position while dragging
		self.position = lerp(self.position, intersection.position + Vector3(intersection.normal.x*0.5,0.5,intersection.normal.z*0.5), 25 * delta)
	
	if Input.is_action_just_released("drag"):
		state_machine.change_state(state_drop)


func leave_state_drag() ->void:
	pass


func enter_state_drop() ->void:
	raycast()
	raycast_down()
	var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	if intersection:
		# Drop to the last raycast collider
		if intersection.normal == Vector3(0,1,0):
			current_tween.tween_property(self,"global_position",last_intersection.collider.position + last_intersection.normal,0.5)
			await current_tween.finished
			current_tween.kill()
			# Change state
			state_machine.change_state(state_idle)

		# Fall when dropped on the side
		elif intersection.normal != Vector3(0,1,0) and ray_down:
			current_tween.tween_property(self,"global_position",ray_down.collider.position + Vector3(0,1,0),0.5)
			await current_tween.finished
			current_tween.kill()
			# Change state
			state_machine.change_state(state_idle)
	

func state_drop() ->void:
	pass


func leave_state_drop() ->void:
	pass
	
	
func enter_state_fall() ->void:
	raycast_down()
	Global.falling = true
	if ray_down:
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(self,"global_position",ray_down.position + Vector3(0,0.5,0),0.10)
		await current_tween.finished
		Global.falling = false
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
	var layers = 1 | 2
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers,[])
	if dragged_block:
		query.exclude = [dragged_block]
	query.collide_with_areas = true
	intersection = space_state.intersect_ray(query)
	# Store last intersection except for the platform area
	if intersection and intersection.collider != $"../../../platform/Area3D":
		last_intersection = intersection
		#print(Global.intersection.collider)


func space_is_free(block: Node3D, pos: Vector3) -> bool:
	var space = get_world_3d().direct_space_state
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = block.get_node("CollisionShape3D").shape
	query.transform = Transform3D(block.global_transform.basis, pos)
	query.margin = 0.001
	query.exclude = [self]   # don’t collide with itself
	# Optional: set collision layers/mask if you only care about PhysicsBodies
	# query.collision_mask = <your_mask>

	# did we collide?
	var result = space.intersect_shape(query, 1)
	
	if result == null:
		return true
	else:
		return false


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
	var layers = 1 | 2
	var query = PhysicsRayQueryParameters3D.create(origin, end, layers, [])
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
