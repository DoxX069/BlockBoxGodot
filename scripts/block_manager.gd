extends Node3D
class_name BlockManager


@export var height: int = 50
@export var block_count: int = 4

@export var swipe_detector: SwipeDetector


@export var build_blocks: Node3D
@export var task_blocks: Node3D

@onready var block_scene: PackedScene = preload("res://scenes/Block/block.tscn")

var build_block_positions: Dictionary = {}
var task_block_positions: Dictionary = {}
var valid_task_pos: Array = []
var valid_build_pos: Array = []
var taken_task_pos: Array = []
var taken_build_pos: Array = []
var valid_inst_task_pos: Array = [
	Vector3i(0,1,0),
	Vector3i(-1,1,0),Vector3i(1,1,0),
	Vector3i(0,1,-1),Vector3i(0,1,-1),
	Vector3i(-1,1,-1),Vector3i(1,1,1),
	Vector3i(1,1,-1),Vector3i(-1,1,1)							
]
var valid_inst_build_pos: Array = [Vector3i(0,1,0),
	Vector3i(-1,1,0),Vector3i(1,1,0),
	Vector3i(0,1,-1),Vector3i(0,1,-1),
	Vector3i(-1,1,-1),Vector3i(1,1,1),
	Vector3i(1,1,-1),Vector3i(-1,1,1)]

@onready var block_colors: Dictionary = {
	"red_block": Color(1,0,0),
	"green_block": Color(0,1,0),
	"blue_block": Color(0,0,1),
	"yellow_block": Color(1,1,0)
}


func _ready() -> void:
	update_valid_pos()
	add_block(block_count)
	if build_blocks:
		build_blocks.visible = false
	if task_blocks:
		task_blocks.visible = true

func _physics_process(_delta: float) -> void:
	if build_block_positions.recursive_equal(task_block_positions,1):
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
		

func add_block(amount: int) ->void:
	var color_pool = block_colors.duplicate()
	for i in amount:
		# restore color pool
		if color_pool.is_empty():
			color_pool = block_colors.duplicate()
		# pick and remove random color
		var color = color_pool.values().pick_random()
		color_pool.erase(color_pool.find_key(color))
		print("available colors:",color_pool)
		
		var new_task_pos: Vector3i
		var new_build_pos: Vector3i
		
		# task instance
		if task_blocks:	
			# instance block
			var task_instance: BlockController  = block_scene.instantiate()
			task_blocks.add_child(task_instance)
			# set color
			var og_material: Material = task_instance.get_child(0).get_material_override()
			var new_material: Material = og_material.duplicate()
			new_material.albedo_color = color
			task_instance.get_child(0).set_material_override(new_material)
			# set random position
			if valid_inst_task_pos.is_empty():
				break
			else:
				new_task_pos = valid_inst_task_pos.pick_random()
				task_instance.position = new_task_pos
			# add to build_block_positions array
			if task_block_positions.has(block_colors.find_key(color)):
				task_block_positions.get(block_colors.find_key(color)).append(new_task_pos)
			else:
				task_block_positions[block_colors.find_key(color)] = [new_task_pos]
			# set collision layer
			task_instance.collision_layer = 8
			# set collision mask
			task_instance.collision_mask = 8
			# restrict drag and drop
			task_instance.dragging_disabled = true
			
		# build instance
		if build_blocks:
			# instance block
			var build_instance: BlockController  = block_scene.instantiate()
			build_blocks.add_child(build_instance)
			# set color
			var og_material: Material = build_instance.get_child(0).get_material_override()
			var new_material: Material = og_material.duplicate()
			new_material.albedo_color = color
			build_instance.get_child(0).set_material_override(new_material)
			# set random position
			if valid_inst_build_pos.is_empty():
				break
			else:
				new_build_pos = valid_inst_build_pos.pick_random()
				build_instance.position = new_build_pos
			# add to build_block_positions array
			if build_block_positions.has(block_colors.find_key(color)):
				build_block_positions.get(block_colors.find_key(color)).append(new_build_pos)
			else:
				build_block_positions[block_colors.find_key(color)] = [new_build_pos]
			# set collision layer
			build_instance.collision_layer = 1
			# set collision mask
			build_instance.collision_mask = 1
			
		# update the valid positions
		update_valid_pos()
		# update valid instancing positions
		update_valid_inst_pos(new_task_pos,new_build_pos)
		print("new taken task pos:",new_task_pos)
		print("new taken build pos:",new_build_pos)
	print(task_block_positions)
	print(build_block_positions)
		

func update_taken_pos() ->void:
	# task
	for pos_arrays in task_block_positions.values():	
		taken_task_pos.append_array(pos_arrays)
	# build
	for pos_arrays in build_block_positions.values():
		taken_build_pos.append_array(pos_arrays)
	

func update_valid_pos() ->void:
	update_taken_pos()
	
	# task
	valid_task_pos.clear()
	for x in range(-1,2):
		for y in range(1,height+1):
			for z in range(-1,2):
				var pos := Vector3i(x,y,z)
				if pos not in taken_task_pos:
					valid_task_pos.append(pos)
	
	# build
	valid_build_pos.clear()
	for x in range(-1,2):
		for y in range(1,height+1):
			for z in range(-1,2):
				var pos := Vector3i(x,y,z)
				if pos not in taken_build_pos:
					valid_build_pos.append(pos)


func update_valid_inst_pos(last_task_pos:Vector3i, last_build_pos:Vector3i) ->void:
	update_taken_pos()
	
	# task
	var task_neighbors: Array = []
	task_neighbors = [
		last_task_pos-Vector3i(1,0,0), last_task_pos+Vector3i(1,0,0),
		last_task_pos+Vector3i(0,1,0),
		last_task_pos-Vector3i(0,0,1), last_task_pos+Vector3i(0,0,1)
	]
	valid_inst_task_pos.clear()
	for pos in task_neighbors:
		if pos not in taken_task_pos and pos in valid_task_pos:
			valid_inst_task_pos.append(pos)
	
	# build
	var build_neighbors: Array = []
	build_neighbors = [
		last_build_pos-Vector3i(1,0,0), last_build_pos+Vector3i(1,0,0),
		last_build_pos+Vector3i(0,1,0),
		last_build_pos-Vector3i(0,0,1), last_build_pos+Vector3i(0,0,1)
	]
	valid_inst_build_pos.clear()
	for pos in build_neighbors:
		if pos not in taken_build_pos and pos in valid_build_pos:
			valid_inst_build_pos.append(pos)


func _on_swipe_detector_swipe_up() -> void:
	if build_blocks:
		build_blocks.visible = false
	if task_blocks:
		task_blocks.visible = true


func _on_swipe_detector_swipe_down() -> void:
	if build_blocks:
		build_blocks.visible = true
	if task_blocks:
		task_blocks.visible = false


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
# - update build block positions when changed

# - add more blocks if positions are equal
