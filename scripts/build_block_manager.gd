extends BlockManager


signal blocks_matching


func _ready() -> void:
	# Change to build Blocks
	var i := 0
	for inst: Block in block_inst:
		inst.collision_layer = 1
		inst.collision_mask = 1 | 2
		inst.is_task_block = false
		inst.is_build_block = true
		inst.position = build_block_pos[i]
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(inst, "position", build_block_pos[i], 0.2)
		i += 1
	
	# Start Timer
	if build_timer.is_stopped:
		build_timer.start()
	else:
		build_timer.resume()
	
	# Change camera size
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "size", 5.5, 0.3)
	
	
	
	
	build_valid_pos = [
		Vector3(0, 1, 0),
		Vector3(-1, 1, 0), Vector3(1, 1, 0),
		Vector3(0, 1, -1), Vector3(0, 1, 1),
		Vector3(-1, 1, -1), Vector3(1, 1, 1),
		Vector3(1, 1, -1), Vector3(-1, 1, 1)
	]
	

func _process(_delta: float) -> void:
	# Enable dragging
	Global.dragging_disabled = false
	
	if play_add_task_button_down == true:
		play_add_task_button_down = false
		state_machine.change_state(state_show_task)
		
	# Check if task- and build block positions are equal	
	task_block_pos.sort_custom(custom_sorter)
	build_block_pos.sort_custom(custom_sorter)
	if build_block_pos == task_block_pos:
		emit_signal("blocks_matching")
	
