@abstract
extends Node3D
class_name BlockManager


func initial_pos(block_type: Dictionary) -> void:
	block_type.block_pos.clear()
	block_type.valid_pos = [
		Vector3(0, 1, 0),
		Vector3(-1, 1, 0), Vector3(1, 1, 0),
		Vector3(0, 1, -1), Vector3(0, 1, 1),
		Vector3(-1, 1, -1), Vector3(1, 1, 1),
		Vector3(1, 1, -1), Vector3(-1, 1, 1)
	]


func instantiate_block(block_type: Dictionary, scene: PackedScene, number: int) -> void:
	for i in number:
		# create block position
		var new_pos: Vector3 = block_type.valid_pos.pick_random()
		block_type.block_pos.append(new_pos)
		block_type.valid_pos.clear()
		update_valid_pos(block_type)
		
		# instantiate block
		var instance := scene.instantiate()
		
		instance.visible = false
		instance.scale = Vector3(0.001, 0.001, 0.001)
		instance.position = new_pos
		self.add_child(instance)
		block_type.block_inst.append(instance)
		instance.visible = true
		var current_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		current_tween.tween_property(instance, "scale", Vector3(1, 1, 1), 0.2)
		
		
	print("Number of Blocks:", Global.number_of_blocks)
	print(" --- Block Pos --- ")
	print(block_type.block_pos)


func remove_block(block_type: Dictionary, number: int) -> void:
	for i in number:
		var inst = block_type.block_inst.pick_random()
		if inst:
			var current_tween := get_tree().create_tween().bind_node(inst).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
			current_tween.tween_property(inst, "scale", Vector3(0.001, 0.001, 0.001), 0.2)
			await current_tween.finished
			block_type.block_inst.erase(inst)
			inst.queue_free()
			
	print("Number of Blocks:", Global.number_of_blocks)
	print(" --- Block Pos --- ")
	print(block_type.block_pos)


func update_block_pos(block_type: Dictionary, new_pos: Vector3, old_pos: Vector3 = Vector3()) -> void:
	block_type.block_pos.erase(old_pos)
	block_type.block_pos.append(new_pos)
	update_valid_pos(block_type)
	print(" --- Build Blocks --- ")
	for pos in block_type.block_pos:
		print(pos)


func update_valid_pos(block_type: Dictionary) -> void:
	for pos in block_type.block_pos:
		block_type.valid_pos.erase(pos)
		var neighbors: Array = [
		pos - Vector3(1, 0, 0), pos + Vector3(1, 0, 0),
		pos + Vector3(0, 1, 0),
		pos - Vector3(0, 0, 1), pos + Vector3(0, 0, 1)
		]
		for n_pos in neighbors:
			if n_pos.x >= -1 and n_pos.x <= 1 and n_pos.z >= -1 and n_pos.z <= 1:
				var below_pos := Vector3(n_pos.x, n_pos.y - 1, n_pos.z)
				if n_pos.y == 1 or below_pos in block_type.block_pos:
					if n_pos not in block_type.block_pos:
						block_type.valid_pos.append(n_pos)
	
	#block_type.valid_pos = [
	#	Vector3(0, 1, 0),
	#	Vector3(-1, 1, 0), Vector3(1, 1, 0),
	#	Vector3(0, 1, -1), Vector3(0, 1, 1),
	#	Vector3(-1, 1, -1), Vector3(1, 1, 1),
	#	Vector3(1, 1, -1), Vector3(-1, 1, 1)
	#]
	#for pos in block_type.block_pos:
	#	block_type.valid_pos.erase(pos)
	#	var neighbor: Vector3 = pos + Vector3(0, 1, 0)
	#	block_type.valid_pos.append(neighbor)
