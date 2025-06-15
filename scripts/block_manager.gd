extends Node3D
class_name BlockManager


@export var swipe_detector: SwipeDetector


@export var build_blocks: Node3D
@export var task_blocks: Node3D

@onready var block_scene: PackedScene = preload("res://scenes/Block/block.tscn")

var build_block_positions: Dictionary = {}
var task_block_positions: Dictionary = {}
var valid_pos: Array = []
var valid_inst_pos: Array = [Vector3i(0,1,0)]

@onready var block_colors: Dictionary = {
	"red_block": Color(1,0,0),
	"green_block": Color(0,1,0),
	"blue_block": Color(0,0,1),
	"yellow_block": Color(1,1,0)
}


func _ready() -> void:
	find_valid_pos()
	add_block(2)
	print(build_block_positions,"\n", task_block_positions)
	if build_blocks:
		build_blocks.visible = true
	if task_blocks:
		task_blocks.visible = false

func _physics_process(_delta: float) -> void:
	update_valid_pos()
	if build_block_positions.recursive_equal(task_block_positions,1):
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
		

func add_block(amount: int) ->void:
	for i in amount:
		var color = block_colors.values().pick_random()
		
		# task instance
		if task_blocks:	
			
			var task_instance: BlockController = block_scene.instantiate()
			task_blocks.add_child(task_instance)
			
			# set color
			var og_material: Material = task_instance.get_child(0).get_material_override()
			var new_material: Material = og_material.duplicate()
			new_material.albedo_color = color
			task_instance.get_child(0).set_material_override(new_material)
			
			# set random position	
			var new_pos = valid_inst_pos.pick_random()
			if valid_pos.has(new_pos):
				task_instance.position = new_pos
			
			valid_pos.erase(task_instance.position)
			var last_pos = task_instance.position
			update_valid_inst_pos(last_pos)
			print(valid_inst_pos)
			
			# add to task_block_positions array
			if task_block_positions.has(block_colors.find_key(color)):
				task_block_positions.get(block_colors.find_key(color)).append(task_instance.position)
			else:
				task_block_positions[block_colors.find_key(color)] = [task_instance.position]
			task_instance.collision_layer = 4
			
			# restrict drag and drop
			task_instance.dragging_disabled = true
		
		# build instance
		if build_blocks:
			
			var build_instance: BlockController  = block_scene.instantiate()
			build_blocks.add_child(build_instance)
			
			# set color
			var og_material: Material = build_instance.get_child(0).get_material_override()
			var new_material: Material = og_material.duplicate()
			new_material.albedo_color = color
			build_instance.get_child(0).set_material_override(new_material)
			
			# set random position	
			var new_pos = valid_inst_pos.pick_random()
			if valid_pos.has(new_pos):
				build_instance.position = new_pos
			valid_pos.erase(build_instance.position)
			var last_pos = build_instance.position
			update_valid_inst_pos(last_pos)
			print(valid_inst_pos)
			
			# add to build_block_positions array
			if build_block_positions.has(block_colors.find_key(color)):
				build_block_positions.get(block_colors.find_key(color)).append(build_instance.position)
			else:
				build_block_positions[block_colors.find_key(color)] = [build_instance.position]
			
			# change collision layer
			build_instance.collision_layer = 1


func find_valid_pos() ->void:
	for x in range(-1,2):
		for y in range(1,4):
			for z in range(-1,2):
				valid_pos.append(Vector3i(x,y,z))


func update_valid_pos() ->void:
	for pos in valid_pos:
		if pos in build_block_positions or pos in task_block_positions:
			valid_pos.erase(pos)


func update_valid_inst_pos(last_pos:Vector3i) ->void:	
	valid_inst_pos.clear()
	valid_inst_pos = [
		last_pos+Vector3i(-1,0,0), last_pos+Vector3i(1,0,0),
		last_pos+Vector3i(0,1,0),
		last_pos+Vector3i(0,0,-1), last_pos+Vector3i(0,0,1)
	]


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

# - add block scene instance to build- and task block
# - choose random color from array for build- and task block instance
# - random position for build- and task block instance (stored in dict)
# - change collision layer for build- and task block
# - restrict drag and drop for task_block

# - with stored pos in dict, store all neighbour pos as valid instancing pos
# - with stored pos in dict, store all other pos as valid droping pos

# - check if build- and task block positions are equal

# - add more blocks if positions are equal
