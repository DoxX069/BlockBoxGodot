extends StaticBody3D
class_name TaskBlockController



@onready var block_manager: BlockManager = self.get_parent()
var falling_allowed: bool = true
var new_pos: Vector3
var old_pos: Vector3

var state_machine: CallableStateMachine = CallableStateMachine.new()



func _ready() ->void:
	state_machine.add_states(Callable(self, "state_idle"), Callable(self, "enter_state_idle"), Callable(self, "leave_state_idle"))
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
	if Global.task_block.valid_pos.has(old_pos - Vector3(0, 1, 0)):
		state_machine.change_state(state_fall)


func leave_state_idle() ->void:
	block_manager.update_pos(Global.task_block, Vector3(), old_pos)


func enter_state_fall() ->void:
	# Get new position
	new_pos = old_pos - Vector3(0, 1, 0)
	
	# Claim new position
	block_manager.update_pos(Global.task_block, new_pos)
	
	# Animate fall
	var current_tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	current_tween.tween_property(self,"position",new_pos,0.1)
	await current_tween.finished
	
	# Change to idle state
	state_machine.change_state(state_idle)


func state_fall() ->void:
	pass
		
	
func leave_state_fall() ->void:
	pass
