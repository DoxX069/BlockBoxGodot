extends BlockManager
class_name TaskBlockManager



@onready var task_block_scene: PackedScene = preload("res://scenes/Block/Task/block.tscn")



func _ready() -> void:
	initial_pos(Global.task_block)
	instantiate_block(Global.task_block, task_block_scene, Global.number_of_blocks)
	

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/build.tscn")



func _on_remove_pressed() -> void:
	# Remove from number of Blocks
	Global.number_of_blocks -= 1
	remove_block(Global.task_block, 1)


func _on_add_pressed() -> void:
	# Add to number of Blocks
	Global.number_of_blocks += 1
	instantiate_block(Global.task_block, task_block_scene, 1)
