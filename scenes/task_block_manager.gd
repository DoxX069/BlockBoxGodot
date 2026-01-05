extends BlockManager

func _ready() -> void:
	task_block_pos.clear()
	build_block_pos.clear()
	task_valid_pos = [
		Vector3(0, 1, 0),
		Vector3(-1, 1, 0), Vector3(1, 1, 0),
		Vector3(0, 1, -1), Vector3(0, 1, 1),
		Vector3(-1, 1, -1), Vector3(1, 1, 1),
		Vector3(1, 1, -1), Vector3(-1, 1, 1)
		]
	build_valid_pos = [
		Vector3(0, 1, 0),
		Vector3(-1, 1, 0), Vector3(1, 1, 0),
		Vector3(0, 1, -1), Vector3(0, 1, 1),
		Vector3(-1, 1, -1), Vector3(1, 1, 1),
		Vector3(1, 1, -1), Vector3(-1, 1, 1)
	]
	instantiate_block(number_of_blocks)


func _process(_delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/build.tscn")


func _on_remove_pressed() -> void:
	number_of_blocks += 1
	build_timer.set_elapsed_time(build_timer.elapsed_time - clampf(reduce_time_new_block, 0.5, 15))
	reduce_time_new_block += 1
	reduce_time_correct = 1
	instantiate_block(1)


func _on_add_pressed() -> void:
	number_of_blocks -= 1
	build_timer.set_elapsed_time(build_timer.elapsed_time + clampf(reduce_time_new_block, 0.5, 15))
	reduce_time_new_block -= 1
	reduce_time_correct = 1
	remove_block(1)
	
