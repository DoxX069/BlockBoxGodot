extends CanvasLayer



signal transition_half_completed(target_scene: String)
signal transition_completed

var current_transition: Node = null
var is_transitioning: bool = false



func change_scene(target_scene: String, transition_type: String = "fade", duration: float = 1.0):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Create the transition Effect
	var transition_scene: Node = null
	
	match transition_type:
		"wipe":
			transition_scene = load("res://scenes/Transitions/wipe.tscn").instantiate()
		"fade":
			transition_scene = load("res://scenes/Transitions/fade.tscn").instantiate()
		_:
			transition_scene = load("res://scenes/Transitions/fade.tscn").instantiate()
			
	# Set duration
	transition_scene.duration = duration
	
	# Connect signals
	transition_half_completed.connect(_on_transition_half_completed)
	transition_completed.connect(_on_transition_completed)
	
	# Add to scene tree
	add_child(transition_scene)
	current_transition = transition_scene
	
	# Start transition
	transition_scene.transition_in(target_scene)


func _on_transition_half_completed(target_scene: String):
	# Change to the target scene
	get_tree().change_scene_to_file(target_scene)
	
	
func _on_transition_completed():
	# Clean up
	if current_transition:
		current_transition.queue_free()
		current_transition = null
		
		# Disconnect old signal
		transition_half_completed.disconnect(_on_transition_half_completed)
		transition_completed.disconnect(_on_transition_completed)
	
	is_transitioning = false
