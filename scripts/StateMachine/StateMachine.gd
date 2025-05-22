extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Give every state a reference to the state machine.
	for state_node: State in get_children():
		if state_node is State:
			states[state_node.name.to_lower()] = state_node
			state_node.finished.connect(_transition_to_next_state)
		
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _transition_to_next_state(state, new_state_name) -> void:
	if state != current_state:
		return

	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	
	current_state = new_state
	
	print(current_state)

func is_in_state(state: State) ->bool:
	return current_state == state
	
