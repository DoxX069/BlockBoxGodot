extends Node3D
class_name BlockManager


var state_machine: CallableStateMachine = CallableStateMachine.new()

@export var counter: Counter
var multiplier: int = 1
@export var build_timer: CustomTimer
var reduce_time_correct: float = 1
var reduce_time_new_block: float = 1
var timer_timeout := false
var swipe_up := false
var swipe_down := false
var dragging_disabled: bool = false

signal data_saved
signal data_loaded

var number_of_blocks: int = 1

@export var task_blocks: Node3D
@export var build_blocks: Node3D

@onready var block_scene: PackedScene = preload("res://scenes/Block/block.tscn")

var current_inst: Block
var current_inst_pos: Vector3
var block_inst: Array = []
var task_block_pos: Array = []
var build_block_pos: Array = []
var task_valid_pos: Array = []
var build_valid_pos: Array = []


func _ready() -> void:
	state_machine.add_states(Callable(self, "state_new_block"), Callable(self, "enter_state_new_block"), Callable(self, "leave_state_new_block"))
	state_machine.add_states(Callable(self, "state_build"), Callable(self, "enter_state_build"), Callable(self, "leave_state_build"))
	state_machine.add_states(Callable(self, "state_show_task"), Callable(self, "enter_state_show_task"), Callable(self, "leave_state_show_task"))
	state_machine.add_states(Callable(self, "state_win"), Callable(self, "enter_state_win"), Callable(self, "leave_state_win"))
	state_machine.add_states(Callable(self, "state_loose"), Callable(self, "enter_state_loose"), Callable(self, "leave_state_loose"))
	state_machine.set_initial_state(state_new_block)
		

func _process(_delta: float) -> void:
	state_machine.update()


# States

func enter_state_new_block() -> void:
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
	for i in number_of_blocks:
		create_block_pos()
		instantiate_block()
		spawn_animation()
	

func state_new_block() -> void:
	if swipe_up:
		number_of_blocks += 1
		build_timer.set_elapsed_time(build_timer.elapsed_time - clampf(reduce_time_new_block, 0.5, 15))
		reduce_time_new_block += 1
		reduce_time_correct = 1
		create_block_pos()
		instantiate_block()
		spawn_animation()
		swipe_up = false
	if swipe_down:
		state_machine.change_state(state_build)
		swipe_down = false
	
	
func leave_state_new_block() -> void:
	if build_timer.is_stopped:
		build_timer.start()
	else:
		build_timer.resume()
	
	
func enter_state_build() -> void:
	make_build_block()
	build_valid_pos = [
		Vector3(0, 1, 0),
		Vector3(-1, 1, 0), Vector3(1, 1, 0),
		Vector3(0, 1, -1), Vector3(0, 1, 1),
		Vector3(-1, 1, -1), Vector3(1, 1, 1),
		Vector3(1, 1, -1), Vector3(-1, 1, 1)
	]
	

func state_build() -> void:
	# Check if task- and build block positions are equal
	if swipe_up == true:
		make_task_block()
		dragging_disabled = true
		swipe_up = false
	elif swipe_down == true:
		make_build_block()
		dragging_disabled = false
		swipe_down = false
		
	task_block_pos.sort_custom(custom_sorter)
	build_block_pos.sort_custom(custom_sorter)
	if build_block_pos == task_block_pos:
		state_machine.change_state(state_win)
	if timer_timeout == true:
		state_machine.change_state(state_loose)
		timer_timeout = false
	

func leave_state_build() -> void:
	pass
	

func enter_state_show_task() -> void:
	pass
	

func state_show_task() -> void:
	pass
	
	
func leave_state_show_task() -> void:
	pass


func enter_state_win() -> void:
	build_timer.pause()
	build_timer.set_elapsed_time(build_timer.elapsed_time - reduce_time_correct * number_of_blocks)
	if reduce_time_correct > 0.25:
		reduce_time_correct -= 0.15
	despawn_animation()
	counter.add_to_counter(block_inst.size(), multiplier)
	await get_tree().create_timer(0.5).timeout
	state_machine.change_state(state_new_block)
	
	
func state_win() -> void:
	pass
	
	
func leave_state_win() -> void:
	remove_block()
	
	
func enter_state_loose() -> void:
	build_timer.stop()
	despawn_animation()
	counter.reset_counter()
	
	
func state_loose() -> void:
	if Input.is_action_just_pressed("drag"):
		state_machine.change_state(state_new_block)
	

func leave_state_loose() -> void:
	number_of_blocks = 1
	remove_block()
	

# Functions

func custom_sorter(a, b) -> bool:
	if a < b:
		return true
	return false


func make_task_block() -> void:
	dragging_disabled = true
	var i := 0
	for inst: Block in block_inst:
		inst.collision_layer = 4
		inst.collision_mask = 4 | 2
		inst.is_task_block = true
		inst.is_build_block = false
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(inst, "position", task_block_pos[i], 0.2)
		i += 1
	dragging_disabled = false
		

func make_build_block() -> void:
	dragging_disabled = true
	var i := 0
	for inst: Block in block_inst:
		inst.collision_layer = 1
		inst.collision_mask = 1 | 2
		inst.is_task_block = false
		inst.is_build_block = true
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(inst, "position", build_block_pos[i], 0.2)
		i += 1
	dragging_disabled = false
	

func instantiate_block() -> void:
	dragging_disabled = true
	# Task Block
	update_task_valid_pos()
	var instance: Block = block_scene.instantiate()
	instance.visible = false
	instance.get_child(0).get_child(0).scale = Vector3(0.001, 0.001, 0.001)
	instance.collision_layer = 4
	instance.collision_mask = 4 | 2
	instance.is_task_block = true
	instance.is_build_block = false
	instance.position = current_inst_pos
	self.add_child(instance)
	instance.visible = true
	block_inst.append(instance)
	current_inst = instance
	dragging_disabled = false
	

func remove_block() -> void:
	for inst: Block in block_inst:
		inst.queue_free()
	block_inst.clear()

	
func spawn_animation() -> void:
	dragging_disabled = true
	var current_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	current_tween.tween_property(current_inst.block_mesh, "scale", Vector3(1, 1, 1), 0.15)
	dragging_disabled = false
		
		
func despawn_animation() -> void:
	for inst: Block in block_inst:
		dragging_disabled = true
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		current_tween.tween_property(inst.block_mesh, "scale", Vector3(0, 0, 0), 0.15)
		dragging_disabled = false
			

func create_block_pos() -> void:
	var new_task_pos: Vector3 = task_valid_pos.pick_random()
	task_block_pos.append(new_task_pos)
	current_inst_pos = new_task_pos
	task_valid_pos.clear()
	update_task_valid_pos()
	
	var new_build_pos: Vector3 = build_valid_pos.pick_random()
	build_block_pos.append(new_build_pos)
	build_valid_pos.clear()
	update_build_valid_pos()
	

func update_task_block_pos(new_pos: Vector3, old_pos: Vector3 = Vector3()) -> void:
	if not task_block_pos.has(new_pos):
		task_block_pos.erase(old_pos)
		task_block_pos.append(new_pos)
	update_task_valid_pos()
	print(" --- Task Blocks --- ")
	for pos in task_block_pos:
		print(pos)
		
	
func update_build_block_pos(new_pos: Vector3, old_pos: Vector3 = Vector3()) -> void:
	if not build_block_pos.has(new_pos):
		build_block_pos.erase(old_pos)
		build_block_pos.append(new_pos)
	update_build_valid_pos()
	print(" --- Build Blocks --- ")
	for pos in build_block_pos:
		print(pos)
		

func update_task_valid_pos() -> void:
	for pos in task_block_pos:
		task_valid_pos.erase(pos)
		var neighbors: Array = [
		pos - Vector3(1, 0, 0), pos + Vector3(1, 0, 0),
		pos + Vector3(0, 1, 0),
		pos - Vector3(0, 0, 1), pos + Vector3(0, 0, 1)
		]
		for n_pos in neighbors:
			if n_pos.x >= -1 and n_pos.x <= 1 and n_pos.z >= -1 and n_pos.z <= 1:
				var below_pos := Vector3(n_pos.x, n_pos.y - 1, n_pos.z)
				if n_pos.y == 1 or below_pos in task_block_pos:
					if n_pos not in task_block_pos:
						task_valid_pos.append(n_pos)
			

func update_build_valid_pos() -> void:
	build_valid_pos = [
		Vector3(0, 1, 0),
		Vector3(-1, 1, 0), Vector3(1, 1, 0),
		Vector3(0, 1, -1), Vector3(0, 1, 1),
		Vector3(-1, 1, -1), Vector3(1, 1, 1),
		Vector3(1, 1, -1), Vector3(-1, 1, 1)
	]
	for pos in build_block_pos:
		build_valid_pos.erase(pos)
		var neighbor: Vector3 = pos + Vector3(0, 1, 0)
		build_valid_pos.append(neighbor)
			

func save_data() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	dir.make_dir("saves")
		
	var save_file = FileAccess.open("user://saves/block_data.dat", FileAccess.WRITE)
	save_file.store_var(task_block_pos)
	save_file.store_var(build_block_pos)
	
	save_file.close()
	emit_signal("data_saved")
	

func load_data() -> void:
	var save_file = FileAccess.open("user://saves/block_data.dat", FileAccess.READ)
	task_block_pos = save_file.get_var()
	build_block_pos = save_file.get_var()
	save_file.close()
	emit_signal("data_loaded")
	

func _on_timer_timeout() -> void:
	pass


func _on_custom_timer_timeout() -> void:
	timer_timeout = true
	

func _on_swipe_detector_swipe_up() -> void:
	swipe_up = true


func _on_swipe_detector_swipe_down() -> void:
	swipe_down = true
