extends BlockController
class_name TaskBlockController



var state_machine: CallableStateMachine = CallableStateMachine.new()



func _ready() ->void:
	state_machine.add_states(Callable(self, "state_idle"), Callable(self, "enter_state_idle"), Callable(self, "leave_state_idle"))
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
		
	if ground_distance >= 1.5 and falling_allowed:
		state_machine.change_state(state_fall)


func leave_state_idle() ->void:
	Global.build_block.block_pos.erase(self.position)
	block_manager.update_valid_pos(Global.build_block)
	print(" --- Blocks --- ")
	for pos in Global.build_block.block_pos:
		print(pos)
	# update start drag position
	idle_pos = self.position


func enter_state_fall() ->void:
	raycast_down()
	# set new position
	var new_pos: Vector3 = ray_down.collider.position + ray_down.normal
		
	# fall
	falling_allowed = false
	var current_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	current_tween.tween_property(self,"position",new_pos,0.1)
	await current_tween.finished
	falling_allowed = true
	state_machine.change_state(state_idle)


func state_fall() ->void:
	pass
		
	
func leave_state_fall() ->void:
	# update block position
	block_manager.update_block_pos(Global.build_block, self.position)
