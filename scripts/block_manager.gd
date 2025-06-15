extends Node3D


@export var swipe_detector: SwipeDetector

var build_blocks: Dictionary = {}
var task_blocks: Dictionary = {}

@onready var build_block := $BuildBlocks

@onready var red_build_block_scene: PackedScene = preload("res://scenes/blocks/block_red.tscn")
@onready var blue_build_block_scene: PackedScene = preload("res://scenes/blocks/block_blue.tscn")
@onready var green_build_block_scene: PackedScene = preload("res://scenes/blocks/block_green.tscn")
@onready var orange_build_block_scene: PackedScene = preload("res://scenes/blocks/block_orange.tscn")

@onready var build_block_scenes: Array = [
	red_build_block_scene,
	blue_build_block_scene,
	green_build_block_scene,
	orange_build_block_scene
]

@onready var task_block := $TaskBlocks

@onready var red_task_block_scene: PackedScene = preload("res://scenes/task blocks/block_red.tscn")
@onready var blue_task_block_scene: PackedScene = preload("res://scenes/task blocks/block_blue.tscn")
@onready var green_task_block_scene: PackedScene = preload("res://scenes/task blocks/block_green.tscn")
@onready var orange_task_block_scene: PackedScene = preload("res://scenes/task blocks/block_orange.tscn")

var start_pos: Vector2
var mouse_pos: Vector2
var delta_pos: Vector2
var swipe_distance := 125
var swiping := false
	
@onready var camera := $"../CameraRig/Camera3D"
var ray_length := 100	

func _ready() -> void:
	add_block(build_block_scenes,build_blocks,1)
	var red_task_block_instance = red_task_block_scene.instantiate()
	task_block.add_child(red_task_block_instance)
	red_task_block_instance.global_position = Vector3(0,1,0)
	var red_build_block_instance = red_build_block_scene.instantiate()
	build_block.add_child(red_build_block_instance)
	red_build_block_instance.global_position = Vector3(0,1,0)

#	build_blocks = {
#		"red_block" =  red_build_block.global_position,
#		"blue_block" = blue_build_block.global_position,
#		"green_block" = green_build_block.global_position,
#		"orange_block" = orange_build_block.global_position
#	}
#	task_blocks = {
#		"blue_block": blue_task_block.global_position,
#		"red_block": red_task_block.global_position,
#		"green_block": green_task_block.global_position,
#		"orange_block": orange_task_block.global_position
#	}
#	for i in task_blocks:
#		task_blocks.get(i).x = randi_range(0,1)
#		task_blocks.get(i).y = 1
#		task_blocks.get(i).z = randi_range(0,1)
#		print(task_blocks.get(i))
	
	build_block.visible = true
	#task_blocks.visible = false
	task_block.visible = false

func _physics_process(_delta: float) -> void:
	pass
#	build_blocks = {
#		"red_block": red_build_block.global_position,
#		"blue_block": blue_build_block.global_position,
#		"green_block": green_build_block.global_position,
#		"orange_block": orange_build_block.global_position
#	}
#	if build_blocks.recursive_equal(task_blocks,1):
#		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")

		
		

func add_block(from:Array,to:Dictionary,amount: int) ->void:
	for i in amount:
		print(from.pick_random())


# Block Manager:

# - switch between showing Build- or TaskBlocks

# - store BuildBlock / TaskBlock in arrays
# - pick random Block
# - instantiate blocks at random neighbour positions stored in array

# - store BuildBlock / TaskBlock positions in array
# - check if they are matching


func _on_swipe_detector_swipe_up() -> void:
	build_block.visible = false
	task_block.visible = true


func _on_swipe_detector_swipe_down() -> void:
	build_block.visible = true
	task_block.visible = false
