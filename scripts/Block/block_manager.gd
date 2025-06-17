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
	"white": Color(1,1,1),
	#"red": Color(1,0,0),
	#"green": Color(0,1,0),
	#"blue": Color(0,0,1),
	#"yellow": Color(1,1,0)
}


func _ready() -> void:
	sort_dicts()
	update_valid_pos()
	add_block(block_count)
	if build_blocks:
		build_blocks.visible = true
	if task_blocks:
		task_blocks.visible = false

func _physics_process(_delta: float) -> void:
	# Check if task- and build block positions are equal
	if build_block_positions.recursive_equal(task_block_positions,1):
		get_tree().change_scene_to_file("res://scenes/task.tscn")
		

func add_block(amount: int) ->void:
	var color_pool = colors.duplicate()
	for i in amount:
		# restore color pool
		if color_pool.is_empty():
			color_pool = colors.duplicate()
		# pick and remove random color
		var color = color_pool.values().pick_random()
		color_pool.erase(color_pool.find_key(color))
		print("available colors:",color_pool)
		
		# task instance
		if task_blocks:	
			# instance block
			var task_instance: BlockController  = block_scene.instantiate()
			task_instance.name = "TaskBlock"+str(i)
			task_blocks.add_child(task_instance)
			# set collision layer
			task_instance.collision_layer = 4
			# set collision mask
			task_instance.collision_mask = 4 | 2
			# set random position
			var new_task_pos: Vector3
			if valid_task_pos.is_empty():
				break
			else:
				new_task_pos = valid_task_pos.pick_random()
				task_instance.position = new_task_pos
			# add to build_block_positions array
			if task_block_positions.has(colors.find_key(color)):
				task_block_positions.get(colors.find_key(color)).append(new_task_pos)
			else:
				task_block_positions[colors.find_key(color)] = [new_task_pos]
			# set color
			var og_material: Material = task_instance.get_child(0).get_material_override()
			var new_material: Material = og_material.duplicate()
			new_material.albedo_color = color
			task_instance.get_child(0).set_material_override(new_material)
			# restrict drag and drop and identify as task
			task_instance.dragging_disabled = true
			task_instance.is_task_block = true
			
		# build instance
		if build_blocks:
			# instance block
			var build_instance: BlockController  = block_scene.instantiate()
			build_instance.name = "BuildBlock"+str(i)
			build_blocks.add_child(build_instance)
			# set collision layer
			build_instance.collision_layer = 1
			# set collision mask
			build_instance.collision_mask = 1 | 2
			# set random position
			var new_build_pos: Vector3
			if valid_build_pos.is_empty():
				break
			else:
				new_build_pos = valid_build_pos.pick_random()
				build_instance.position = new_build_pos
			# add to build_block_positions array
			if build_block_positions.has(colors.find_key(color)):
				build_block_positions.get(colors.find_key(color)).append(new_build_pos)
			else:
				build_block_positions[colors.find_key(color)] = [new_build_pos]
			# set color
			var og_material: Material = build_instance.get_child(0).get_material_override()
			var new_material: Material = og_material.duplicate()
			new_material.albedo_color = color
			build_instance.get_child(0).set_material_override(new_material)
			# identify as build
			build_instance.is_build_block = true
			
		# update the valid positions
		valid_task_pos.clear()
		valid_build_pos.clear()
		update_valid_pos()
	var build_start_pos:Array = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
	]
	for pos in build_start_pos:
		if pos not in taken_build_pos and pos not in valid_build_pos:
			valid_build_pos.append(pos)
	var task_start_pos:Array = [
		Vector3(0,1,0),
		Vector3(-1,1,0),Vector3(1,1,0),
		Vector3(0,1,-1),Vector3(0,1,1),
		Vector3(-1,1,-1),Vector3(1,1,1),
		Vector3(1,1,-1),Vector3(-1,1,1)
	]
	for pos in task_start_pos:
		if pos not in taken_task_pos and pos not in valid_task_pos:
			valid_task_pos.append(pos)
	update_valid_pos()
	

func update_taken_pos() ->void:
	# task
	taken_task_pos.clear()
	for pos_arrays in task_block_positions.values():	
		taken_task_pos.append_array(pos_arrays)
	# build
	taken_build_pos.clear()
	for pos_arrays in build_block_positions.values():
		taken_build_pos.append_array(pos_arrays)
	

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
					
	
func sort_dicts() ->void:
	for key in task_block_positions.keys():
			var array_value = task_block_positions[key]
			array_value.sort()
	for key in build_block_positions.keys():
			var array_value = build_block_positions[key]
			array_value.sort()


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
# - update build block positions when changed - done

# - add more blocks if positions are equal
