extends Node3D
class_name BlockManager


var state_machine: CallableStateMachine = CallableStateMachine.new()

@export var counter: Counter
var multiplier: int = 1
@export var build_timer: Timer
var timer_timeout := false
var swipe_up := false
var swipe_down := false
var dragging_disabled: bool = false

signal data_saved
signal data_loaded

var block_pos_ready := false

@export var number_of_blocks: int = 5

@export var task_blocks: Node3D
@export var build_blocks: Node3D

@onready var block_scene: PackedScene = preload("res://scenes/Block/block.tscn")

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

func enter_state_new_block() ->void:
	create_block_pos(number_of_blocks)
	instantiate_block(number_of_blocks)
	make_task_block()
	spawn_animation()


func state_new_block() ->void:
	if swipe_down:
		state_machine.change_state(state_build)
		swipe_down = false
	
	
func leave_state_new_block() ->void:
	build_timer.start()
	
	
func enter_state_build() ->void:
	make_build_block()
	build_valid_pos = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
	]
	

func state_build() ->void:
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
	

func leave_state_build() ->void:
	pass
	

func enter_state_show_task() ->void:
	pass
	

func state_show_task() ->void:
	pass
	
	
func leave_state_show_task() ->void:
	pass


func enter_state_win() ->void:
	build_timer.set_paused(true)
	despawn_animation()
	counter.add_to_counter(block_inst.size(), multiplier)
	
	
func state_win() ->void:
	if Input.is_action_just_pressed("drag"):
		state_machine.change_state(state_new_block)
	
	
func leave_state_win() ->void:
	build_timer.set_paused(false)
	build_timer.stop()
	remove_block()
	
	
func enter_state_loose() ->void:
	build_timer.stop()
	despawn_animation()
	counter.reset_counter()
	
	
func state_loose() ->void:
	if Input.is_action_just_pressed("drag"):
		state_machine.change_state(state_new_block)	
	

func leave_state_loose() ->void:
	remove_block()
	

# Functions

func custom_sorter(a,b) ->bool:
	if a < b:
		return true
	return false


func make_task_block() ->void:
	dragging_disabled = true
	var counter := 0
	for inst:Block in block_inst:
		inst.collision_layer = 4
		inst.collision_mask = 4 | 2
		inst.is_task_block = true
		inst.is_build_block = false
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(inst,"position",task_block_pos[counter],0.2)
		counter += 1
	dragging_disabled = false
		

func make_build_block() ->void:
	dragging_disabled = true
	var counter := 0
	for inst:Block in block_inst:
		inst.collision_layer = 1
		inst.collision_mask = 1 | 2
		inst.is_task_block = false
		inst.is_build_block = true
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(inst,"position",build_block_pos[counter],0.2)
		counter += 1
	dragging_disabled = false
	

func instantiate_block(amount: int) ->void:
	if block_pos_ready:
		for i in amount:
			# Task Block
			update_task_valid_pos()
			var instance: Block = block_scene.instantiate()
			self.add_child(instance)
			instance.name = "Block"+str(i)
			instance.block_mesh.scale = Vector3(0,0,0)
			block_inst.append(instance)
			

func remove_block() ->void:
	for inst: Block in block_inst:
		inst.queue_free()
	block_inst.clear()

	
func spawn_animation() ->void:
	for inst:Block in block_inst:
		dragging_disabled = true
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
		current_tween.tween_property(inst.block_mesh,"scale",Vector3(1,1,1),0.1)
		await current_tween.finished
		current_tween.kill()
		dragging_disabled = false
		
		
func despawn_animation() ->void:
	for inst:Block in block_inst:
		dragging_disabled = true
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)
		current_tween.tween_property(inst.block_mesh,"scale",Vector3(0,0,0),0.075)
		await current_tween.finished
		current_tween.kill()
		dragging_disabled = false
			

func create_block_pos(amount:int) ->void:
	task_block_pos.clear()
	task_valid_pos = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
		]
	build_block_pos.clear()
	build_valid_pos = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
	]
	for i in range(amount):
		var new_task_pos: Vector3 = task_valid_pos.pick_random()
		var new_build_pos: Vector3 = build_valid_pos.pick_random()
		task_block_pos.append(new_task_pos)
		build_block_pos.append(new_build_pos)
		
		task_valid_pos.clear()
		build_valid_pos.clear()
		update_task_valid_pos()
		update_build_valid_pos()
	print(" --- Task Blocks --- ")
	for pos in task_block_pos:
		print(pos)
	print(" --- Build Blocks --- ")
	for pos in build_block_pos:
		print(pos)
	block_pos_ready = true
		

func update_task_block_pos(new_pos: Vector3, old_pos: Vector3 = Vector3()) ->void:
	if not task_block_pos.has(new_pos):
		task_block_pos.erase(old_pos)
		task_block_pos.append(new_pos)
	update_task_valid_pos()
	print(" --- Task Blocks --- ")
	for pos in task_block_pos:
		print(pos)
		
	
func update_build_block_pos(new_pos: Vector3, old_pos: Vector3 = Vector3()) ->void:
	if not build_block_pos.has(new_pos):
		build_block_pos.erase(old_pos)
		build_block_pos.append(new_pos)
	update_build_valid_pos()
	print(" --- Build Blocks --- ")
	for pos in build_block_pos:
		print(pos)
		

func update_task_valid_pos() ->void:
	for pos in task_block_pos:
		task_valid_pos.erase(pos)
		var neighbors: Array = [
		pos-Vector3(1,0,0), pos+Vector3(1,0,0),
		pos+Vector3(0,1,0),
		pos-Vector3(0,0,1), pos+Vector3(0,0,1)
		]
		for n_pos in neighbors:
			if n_pos.x >= -1 and n_pos.x <= 1 and n_pos.z >= -1 and n_pos.z <= 1:
				var below_pos:= Vector3(n_pos.x,n_pos.y-1,n_pos.z)
				if n_pos.y == 1 or below_pos in task_block_pos:
					if n_pos not in task_block_pos:
						task_valid_pos.append(n_pos)
			

func update_build_valid_pos() ->void:
	build_valid_pos = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
	]
	for pos in build_block_pos:
		build_valid_pos.erase(pos)
		var neighbor: Vector3 = pos+Vector3(0,1,0)
		build_valid_pos.append(neighbor)
			

func save_data() ->void:
	var dir: DirAccess = DirAccess.open("user://")
	dir.make_dir("saves")
		
	var save_file = FileAccess.open("user://saves/block_data.dat", FileAccess.WRITE)
	save_file.store_var(task_block_pos)
	save_file.store_var(build_block_pos)
	
	save_file.close()
	emit_signal("data_saved")
	

func load_data() ->void:
	var save_file = FileAccess.open("user://saves/block_data.dat", FileAccess.READ)
	task_block_pos = save_file.get_var()
	build_block_pos = save_file.get_var()
	save_file.close()
	emit_signal("data_loaded")
	

func _on_timer_timeout() -> void:
	timer_timeout = true


func _on_swipe_detector_swipe_up() -> void:
	swipe_up = true


func _on_swipe_detector_swipe_down() -> void:
	swipe_down = true
	
