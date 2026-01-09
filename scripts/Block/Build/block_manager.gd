extends BlockManager
class_name BuildBlockManager


signal blocks_matching
signal blocks_removed
@onready var build_block_scene: PackedScene = preload("res://scenes/Block/build_block.tscn")


func _ready() -> void:
	print("Number of Blocks:", Global.number_of_blocks)
	initial_pos(Global.build_block)
	instantiate_block(Global.build_block, build_block_scene, Global.number_of_blocks)


func process() -> void:
	 # Check if task- and build block positions are equal	
	Global.task_block.block_pos.sort_custom(custom_sorter)
	Global.build_block.block_pos.sort_custom(custom_sorter)
	if Global.build_block.block_pos == Global.task_block.block_pos:
		print("MATCH!!!")
		emit_signal("blocks_matching")

	if Global.build_block.recursive_equal(Global.task_block, 1):
		print("MATCH!!!")
		emit_signal("blocks_matching")



func _on_blocks_matching() -> void:
	remove_block(Global.build_block, Global.number_of_blocks)
	


func _on_custom_timer_timeout() -> void:
	await remove_block(Global.build_block, Global.number_of_blocks)
	await get_tree().create_timer(0.5).timeout
	emit_signal("blocks_removed")


func _on_show_task_button_down() -> void:
	# Change to task blocks
	var i := 0
	for inst: Block in Global.build_block.block_inst:
		inst.dragging_disabled = true
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(inst, "position", Global.task_block.block_pos[i], 0.2)
		i += 1


func _on_show_task_button_up() -> void:
	# Change to task blocks
	var i := 0
	for inst: Block in Global.build_block.block_inst:
		inst.dragging_disabled = false
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		current_tween.tween_property(inst, "position", Global.build_block.block_pos[i], 0.2)
		i += 1



# Functions

func custom_sorter(a, b) -> bool:
	if a < b:
		return true
	return false
