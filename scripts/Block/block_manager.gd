extends Node3D
class_name BlockManager


var state_machine: CallableStateMachine = CallableStateMachine.new()

@export var camera: Camera3D

@export var counter: Counter
var multiplier: int = 1
@export var build_timer: CustomTimer
var reduce_time_correct: float = 1
var reduce_time_new_block: float = 1
var timer_timeout := false
var swipe_up := false
var swipe_down := false
var play_add_task_button_down := false
var play_add_task_button_up := false
var play_add_task_button_pressed := false

signal data_saved
signal data_loaded

var number_of_blocks: int = 1

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
	pass
	

func state_new_block() -> void:
	pass
	
	
func leave_state_new_block() -> void:
	pass
	
	
func enter_state_build() -> void:
	pass

	

func state_build() -> void:
	pass
	

func leave_state_build() -> void:
	# Disable dragging
	Global.dragging_disabled = true
	
	# Change camera
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "size", 6, 0.3)
	

func enter_state_show_task() -> void:
	# Change to task blocks
	var i := 0
	for inst: Block in block_inst:
		inst.collision_layer = 4
		inst.collision_mask = 4 | 2
		inst.is_task_block = true
		inst.is_build_block = false
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(inst, "position", task_block_pos[i], 0.2)
		i += 1
	

func state_show_task() -> void:
	if play_add_task_button_up == true:
		play_add_task_button_up = false
		state_machine.change_state(state_build)
	
	
func leave_state_show_task() -> void:
	pass


func enter_state_win() -> void:
	build_timer.pause()
	build_timer.set_elapsed_time(build_timer.elapsed_time - reduce_time_correct * number_of_blocks)
	if reduce_time_correct > 0.25:
		reduce_time_correct -= 0.15
	
	remove_block(number_of_blocks)
	counter.add_to_counter(block_inst.size(), multiplier)


func state_win() -> void:
	if Input.is_action_just_pressed("drag"):
		state_machine.change_state(state_new_block)
	
	
func leave_state_win() -> void:
	pass
	
	
func enter_state_loose() -> void:
	build_timer.stop()
	remove_block(number_of_blocks)
	counter.reset_counter()
	
	
func state_loose() -> void:
	if Input.is_action_just_pressed("drag"):
		state_machine.change_state(state_new_block)
	

func leave_state_loose() -> void:
	number_of_blocks = 1
	








# Functions

func custom_sorter(a, b) -> bool:
	if a < b:
		return true
	return false



func instantiate_block(number: int) -> void:
	for i in number:
		create_block_pos()
		var instance: Block = block_scene.instantiate()
		instance.visible = false
		instance.scale = Vector3(0.001, 0.001, 0.001)
		instance.collision_layer = 4
		instance.collision_mask = 4 | 2
		instance.is_task_block = true
		instance.is_build_block = false
		instance.position = current_inst_pos
		self.add_child(instance)
		block_inst.append(instance)
		instance.visible = true
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		current_tween.tween_property(instance, "scale", Vector3(1, 1, 1), 0.2)
		
	

func remove_block(number) -> void:
	for i in number:
		var inst = block_inst.pick_random()
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		current_tween.tween_property(inst, "scale", Vector3(0.001, 0.001, 0.001), 0.2)
		await current_tween.finished
		block_inst.erase(inst)
		inst.queue_free()
		

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
	for pos in build_block_pos:
		build_valid_pos.erase(pos)
		var neighbors: Array = [
		pos - Vector3(1, 0, 0), pos + Vector3(1, 0, 0),
		pos + Vector3(0, 1, 0),
		pos - Vector3(0, 0, 1), pos + Vector3(0, 0, 1)
		]
		for n_pos in neighbors:
			if n_pos.x >= -1 and n_pos.x <= 1 and n_pos.z >= -1 and n_pos.z <= 1:
				var below_pos := Vector3(n_pos.x, n_pos.y - 1, n_pos.z)
				if n_pos.y == 1 or below_pos in task_block_pos:
					if n_pos not in build_block_pos:
						build_valid_pos.append(n_pos)
	
	#build_valid_pos = [
	#	Vector3(0, 1, 0),
	#	Vector3(-1, 1, 0), Vector3(1, 1, 0),
	#	Vector3(0, 1, -1), Vector3(0, 1, 1),
	#	Vector3(-1, 1, -1), Vector3(1, 1, 1),
	#	Vector3(1, 1, -1), Vector3(-1, 1, 1)
	#]
	#for pos in build_block_pos:
	#	build_valid_pos.erase(pos)
	#	var neighbor: Vector3 = pos + Vector3(0, 1, 0)
	#	build_valid_pos.append(neighbor)
			

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
	

func _on_play_add_task_button_down() -> void:
	play_add_task_button_down = true


func _on_play_add_task_button_up() -> void:
	play_add_task_button_up = true


func _on_play_add_task_pressed() -> void:
	play_add_task_button_pressed = true
