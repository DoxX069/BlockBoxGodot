extends Node3D
class_name BlockManager


# Block Manager:

# - switch between showing Build- or TaskBlocks - done

# - add block scene instance to build- and task block - done 
# - choose random color from array for build- and task block instance - done
# - random position for build- and task block instance (stored in dict) - done
# - change collision layer for build- and task block - done
# - restrict drag and drop for task_block - done

# - with stored pos in dict, store all neighbour pos as valid instancing pos - done
# - with stored pos in dict, store all other pos as valid droping pos - done

# - check if build- and task block positions are equal - done
# - update build block positions when changed - done

# - add more blocks if positions are equal


signal data_saved
signal data_loaded

@export var number_of_blocks: int = 3

@export var swipe_detector: SwipeDetector

@export var task_blocks: Node3D
@export var build_blocks: Node3D

@onready var block_scene: PackedScene = preload("res://scenes/Block/block.tscn")

var task_block_data: Array = []
var build_block_data: Array = []
var taken_task_pos: Array = []
var taken_build_pos: Array = []
var valid_task_pos: Array = [
	Vector3(0,1,0),
	Vector3(-1,1,0),Vector3(1,1,0),
	Vector3(0,1,-1),Vector3(0,1,1),
	Vector3(-1,1,-1),Vector3(1,1,1),
	Vector3(1,1,-1),Vector3(-1,1,1)
]
var valid_build_pos: Array = [
	Vector3(0,1,0),
	Vector3(-1,1,0),Vector3(1,1,0),
	Vector3(0,1,-1),Vector3(0,1,1),
	Vector3(-1,1,-1),Vector3(1,1,1),
	Vector3(1,1,-1),Vector3(-1,1,1)
]
@onready var colors: Dictionary = {
	"White": Color(1,1,1),
	#"Red": Color(1,0,0),
	#"Green": Color(0,1,0),
	#"Blue": Color(0,0,1),
	#"Yellow": Color(1,1,0)
}


func _ready() -> void:
	task_block_data.sort()
	build_block_data.sort()
	print(get_tree().current_scene.name)
	update_valid_pos()
	if get_tree().current_scene.name == "Task":
		create_block_data(number_of_blocks)
		instantiate_block()
		save_data()
		task_blocks.visible = true
		build_blocks.visible = false
	else:
		load_data()
		instantiate_block()
		task_blocks.visible = false
		build_blocks.visible = true
		

func _process(_delta: float) -> void:
	# Check if task- and build block positions are equal
	update_valid_pos()
	# print sorted task block data
	task_block_data.sort_custom(custom_sorter)
	#for i in task_block_data:
	#	print(i["Color"], "    ", i["Position"])
	# print sorted build block data
	build_block_data.sort_custom(custom_sorter)
	#for i in build_block_data:
	#	print(i["Color"], "    ", i["Position"])
	if build_block_data == task_block_data:
		get_tree().change_scene_to_file("res://scenes/task.tscn")
	

func custom_sorter(a,b) ->bool:
	if a["Color"] == b["Color"]:
		if a["Position"] > b["Position"]:
			return true
	elif a["Color"] < b["Color"]:
		return true
	return false


func instantiate_block() ->void:
	for dict in task_block_data:
		var counter: int = 0
		counter += 1
		#var dict: Dictionary = task_block_data[key]
		# instance block
		var instance: BlockController = block_scene.instantiate()
		# add instance to scene tree
		task_blocks.add_child(instance)
		# set collision layer
		instance.collision_layer = 4
		# set collision mask
		instance.collision_mask = 4 | 2
		# restrict drag and drop and identify as task
		instance.dragging_disabled = true
		instance.is_task_block = true
		instance.is_build_block = false
		# change name
		instance.name = "TaskBlock"+str(counter)
		# set position
		instance.global_position = dict["Position"]
		# set color
		var og_material: Material = instance.get_child(0).get_material_override()
		var new_material: Material = og_material.duplicate()
		new_material.albedo_color = dict["Color"]
		instance.get_child(0).set_material_override(new_material)
		
	for dict in build_block_data:
		var counter: int = 0
		counter += 1
		#var dict: Dictionary = build_block_data[key]
		# instance block
		var instance: BlockController = block_scene.instantiate()
		# add instance to scene tree
		build_blocks.add_child(instance)
		# set collision layer
		instance.collision_layer = 1
		# set collision mask
		instance.collision_mask = 1 | 2
		# restrict drag and drop and identify as task
		instance.dragging_disabled = false
		instance.is_task_block = false
		instance.is_build_block = true
		# configure resource
		instance.name = "BuildBlock"+str(counter)
		# set position
		instance.global_position = dict["Position"]
		# set color
		var og_material: Material = instance.get_child(0).get_material_override()
		var new_material: Material = og_material.duplicate()
		new_material.albedo_color = dict["Color"]
		instance.get_child(0).set_material_override(new_material)
		


func create_block_data(amount:int) ->void:
	var new_amount = amount * 2
	var color_pool: Dictionary = {}
	var color: Color
	var new_pos: Vector3
	var start_pos:Array
	for i in range(new_amount):
		# create dict for saving data
		var single_block_data: Dictionary = {}
		# restore color pool
		if color_pool.is_empty():
			color_pool = colors.duplicate()
		
		if i <= 1: # only for first two loop calls
			start_pos = [
				Vector3(0,1,0),
				Vector3(-1,1,0),Vector3(1,1,0),
				Vector3(0,1,-1),Vector3(0,1,1),
				Vector3(-1,1,-1),Vector3(1,1,1),
				Vector3(1,1,-1),Vector3(-1,1,1)
			]
		else:
			start_pos = []
		
		if i % 2 == 0: # if i is even (task block)
			# store in array
			task_block_data.append(single_block_data)
			# pick and remove random color
			color = color_pool.values().pick_random()
			single_block_data["Color"] = colors.find_key(color)
			color_pool.erase(color_pool.find_key(color))
			# update the valid positions
			for pos in start_pos:
					if pos not in taken_task_pos and pos not in valid_task_pos:
						valid_task_pos.append(pos)
			# set random position
			new_pos = valid_task_pos.pick_random()
			single_block_data["Position"] = new_pos
			# clear the valid positions
			valid_task_pos.clear()
			
		else: # if i is uneven (build block)
			# store in dictionary
			build_block_data.append(single_block_data)
			# store color
			single_block_data["Color"] = colors.find_key(color)
			# update valid positions
			for pos in start_pos:
					if pos not in taken_build_pos and pos not in valid_build_pos:
						valid_build_pos.append(pos)
			# set random position
			new_pos = valid_build_pos.pick_random()
			single_block_data["Position"] = new_pos
			# clear the valid positions
			valid_build_pos.clear()
		# update valid positions		
		update_valid_pos()
			

func update_taken_pos() ->void:
	# task
	taken_task_pos.clear()
	for dict:Dictionary in task_block_data:	
		taken_task_pos.append(dict["Position"])
	print(" --- TAKEN TASK BLOCKS --- ")
	for i in taken_task_pos:
		print(i)
	# build
	taken_build_pos.clear()
	for dict:Dictionary in build_block_data:	
		taken_build_pos.append(dict["Position"])
	print(" --- TAKEN BUILD BLOCKS --- ")
	for i in taken_build_pos:
		print(i)
	

func update_valid_pos() ->void:
	update_taken_pos()
	# task
	for taken_pos in taken_task_pos:
		var task_neighbors: Array = [
		taken_pos-Vector3(1,0,0), taken_pos+Vector3(1,0,0),
		taken_pos+Vector3(0,1,0),
		taken_pos-Vector3(0,0,1), taken_pos+Vector3(0,0,1)
		]
		for pos in task_neighbors:
			if pos.x >= -1 and pos.x <= 1 and pos.z >= -1 and pos.z <= 1:
				var below_pos:= Vector3(pos.x,pos.y-1,pos.z)
				if pos.y == 1 or below_pos in taken_task_pos:
					if pos not in taken_task_pos:
						valid_task_pos.append(pos)
	
	# build
	for taken_pos in taken_build_pos:
		var build_neighbors: Array = [
		taken_pos-Vector3(1,0,0), taken_pos+Vector3(1,0,0),
		taken_pos+Vector3(0,1,0),
		taken_pos-Vector3(0,0,1), taken_pos+Vector3(0,0,1)
		]
		for pos in build_neighbors:
			if pos.x >= -1 and pos.x <= 1 and pos.z >= -1 and pos.z <= 1:
				var below_pos:= Vector3(pos.x,pos.y-1,pos.z)
				if pos.y == 1 or below_pos in taken_build_pos:
					if pos not in taken_build_pos:
						valid_build_pos.append(pos)


func update_block_data(block_data: Dictionary, old_pos:Vector3 ,new_pos: Vector3):
		for dict:Dictionary in block_data:
			if dict["Position"] == old_pos:
				dict["Position"] = new_pos


func save_data() ->void:
	var dir: DirAccess = DirAccess.open("user://")
	dir.make_dir("saves")
		
	var save_file = FileAccess.open("user://saves/block_data.dat", FileAccess.WRITE)
	save_file.store_var(task_block_data)
	save_file.store_var(build_block_data)
	
	save_file.close()
	emit_signal("data_saved")
	

func load_data() ->void:
	var save_file = FileAccess.open("user://saves/block_data.dat", FileAccess.READ)
	task_block_data = save_file.get_var()
	build_block_data = save_file.get_var()
	save_file.close()
	emit_signal("data_loaded")
	

func _on_swipe_detector_swipe_up() -> void:
	if get_tree().current_scene.name == "Game":
		task_blocks.visible = true
		build_blocks.visible = false


func _on_swipe_detector_swipe_down() -> void:
	if get_tree().current_scene.name == "Game":
		task_blocks.visible = false
		build_blocks.visible = true
