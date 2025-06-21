extends Node3D
class_name BlockManager


signal data_saved
signal data_loaded

var block_pos_ready := false

@export var number_of_blocks: int = 3

@export var swipe_detector: SwipeDetector

@export var task_blocks: Node3D
@export var build_blocks: Node3D

@onready var block_scene: PackedScene = preload("res://scenes/Block/block.tscn")

var task_block_inst: Array = []
var build_block_inst: Array = []
var task_block_pos: Array = []
var build_block_pos: Array = []
var task_valid_pos: Array = []
var build_valid_pos: Array = []


func _ready() -> void:
	if get_tree().current_scene.name == "Task":
		create_block_pos(number_of_blocks)
		instantiate_task_block(number_of_blocks)
		task_spawn_animation()
		save_data()
		task_blocks.visible = true
		build_blocks.visible = false
	else:
		load_data()
		instantiate_build_block(number_of_blocks)
		build_spawn_animation()
		instantiate_task_block(number_of_blocks)
		task_spawn_animation()
		task_blocks.visible = false
		build_blocks.visible = true
	task_valid_pos = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
	]
	build_valid_pos = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
	]
		

func _process(_delta: float) -> void:
	# Check if task- and build block positions are equal
	task_block_pos.sort_custom(custom_sorter)
	build_block_pos.sort_custom(custom_sorter)
	if build_block_pos == task_block_pos:
		build_despawn_animation()
		await build_despawn_animation()
		get_tree().change_scene_to_file("res://scenes/task.tscn")
		

func custom_sorter(a,b) ->bool:
	if a < b:
		return true
	return false


func instantiate_task_block(amount: int) ->void:
	if block_pos_ready:
		for i in amount:
			# Task Block
			update_task_valid_pos()
			var task_instance: Block = block_scene.instantiate()
			task_blocks.add_child(task_instance)
			task_instance.dragging_disabled = true
			task_instance.collision_layer = 4
			task_instance.collision_mask = 4 | 2
			task_instance.dragging_disabled = true
			task_instance.is_task_block = true
			task_instance.is_build_block = false
			task_instance.name = "TaskBlock"+str(i)
			task_instance.block_mesh.scale = Vector3(0,0,0)
			task_instance.global_position = task_block_pos[i]
			task_block_inst.append(task_instance)
			update_task_block_pos(task_instance.global_position)


func instantiate_build_block(amount: int) ->void:
	if block_pos_ready:
		for i in amount:
			# Build Block
			update_build_valid_pos()
			var build_instance: Block = block_scene.instantiate()
			build_blocks.add_child(build_instance)
			build_instance.collision_layer = 1
			build_instance.collision_mask = 1 | 2
			build_instance.dragging_disabled = false
			build_instance.is_task_block = false
			build_instance.is_build_block = true
			build_instance.name = "BuildBlock"+str(i)
			build_instance.block_mesh.scale = Vector3(0,0,0)
			build_instance.global_position = build_block_pos[i]
			build_block_inst.append(build_instance)
			update_build_block_pos(build_instance.global_position)
			
	
func task_spawn_animation() ->void:
	for inst:Block in task_block_inst:
		inst.dragging_disabled = true
		var current_task_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		current_task_tween.tween_property(inst.block_mesh,"scale",Vector3(1,1,1),0.15)
		await current_task_tween.finished
		current_task_tween.kill()
		inst.dragging_disabled = false
		
		
func build_spawn_animation() ->void:
	for inst:Block in build_block_inst:
		inst.dragging_disabled = true
		var current_build_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		current_build_tween.tween_property(inst.block_mesh,"scale",Vector3(1,1,1),0.15)
		await current_build_tween.finished
		current_build_tween.kill()
		inst.dragging_disabled = false
			
		
func build_despawn_animation() ->void:
	for inst:Block in build_block_inst:
		inst.dragging_disabled = true
		var current_build_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		current_build_tween.tween_property(inst.block_mesh,"scale",Vector3(0,0,0),0.15)
		inst.dragging_disabled = false
			

func create_block_pos(amount:int) ->void:
	task_valid_pos = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
		]
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
	for pos in build_block_pos:
		build_valid_pos.erase(pos)
		var neighbors: Array = [
		pos-Vector3(1,0,0), pos+Vector3(1,0,0),
		pos+Vector3(0,1,0),
		pos-Vector3(0,0,1), pos+Vector3(0,0,1)
		]
		for n_pos in neighbors:
			if n_pos.x >= -1 and n_pos.x <= 1 and n_pos.z >= -1 and n_pos.z <= 1:
				var below_n_pos:= Vector3(n_pos.x,n_pos.y-1,n_pos.z)
				if n_pos.y == 1 or below_n_pos in build_block_pos:
					if n_pos not in build_block_pos:
						build_valid_pos.append(n_pos)
			

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
	block_pos_ready = true
	

func _on_swipe_detector_swipe_up() -> void:
	if get_tree().current_scene.name == "Game":
		task_blocks.visible = true
		build_blocks.visible = false


func _on_swipe_detector_swipe_down() -> void:
	if get_tree().current_scene.name == "Game":
		task_blocks.visible = false
		build_blocks.visible = true
