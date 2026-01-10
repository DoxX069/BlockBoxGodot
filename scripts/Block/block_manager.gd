@abstract
extends Node3D
class_name BlockManager


func initial_pos(block_type: Dictionary) -> void:
	block_type.block_pos.clear()
	block_type.valid_pos.clear()
	block_type.valid_pos = [
		Vector3(0, 1, 0),
		Vector3(-1, 1, 0), Vector3(1, 1, 0),
		Vector3(0, 1, -1), Vector3(0, 1, 1),
		Vector3(-1, 1, -1), Vector3(1, 1, 1),
		Vector3(1, 1, -1), Vector3(-1, 1, 1)
	]


func instantiate_block(block_type: Dictionary, scene: PackedScene, number: int) -> void:
	for i:int in number:
		if block_type.valid_pos.is_empty():
			return
		# create block position
		var new_pos: Vector3 = block_type.valid_pos.pick_random()
		
		#block_type.valid_pos.clear()
		# Add block position
		update_pos(block_type, new_pos)
		
		# instantiate block
		var instance: StaticBody3D = scene.instantiate() 
		
		instance.visible = false
		instance.scale = Vector3(0.001, 0.001, 0.001)
		instance.position = new_pos
		self.add_child(instance)
		block_type.block_inst.append(instance)
		instance.visible = true
		var current_tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		current_tween.tween_property(instance, "scale", Vector3(1, 1, 1), 0.2)
		
		# Add to number of Blocks
		Global.number_of_blocks += 1
	print("Number of Blocks:", Global.number_of_blocks)


func remove_block(block_type: Dictionary, number: int) -> void:
	for i:int in number:
		if block_type.block_inst.is_empty():
			return
			
		# Get random instance
		var inst = block_type.block_inst.pick_random()
		
		# Remove block position
		update_pos(block_type, Vector3(), inst.position)
		
		# Animate scale
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(inst, "scale", Vector3(0.001, 0.001, 0.001), 0.2)
		await tween.finished
		
		# Remove block
		block_type.block_inst.erase(inst)
		inst.queue_free()
		
		# Remove from number of Blocks
		Global.number_of_blocks -= 1
	print("Number of Blocks:", Global.number_of_blocks)


func update_pos(block_type: Dictionary, new_pos: Vector3 = Vector3(), old_pos: Vector3 = Vector3()) -> void:
	# Old position
	if not old_pos == Vector3():
		block_type.block_pos.erase(old_pos)
		block_type.valid_pos.append(old_pos)
		var old_pos_neighbors: Array = [
		old_pos + Vector3(-1, 0, 0), old_pos + Vector3(1, 0, 0),
		old_pos + Vector3(0, 1, 0), old_pos + Vector3(0, -1, 0),
		old_pos + Vector3(0, 0, -1), old_pos + Vector3(0, 0, 1)
		]
		for n_pos in old_pos_neighbors:
			block_type.valid_pos.erase(n_pos)
	
	# New position
	if not new_pos == Vector3():
		block_type.block_pos.append(new_pos)
		block_type.valid_pos.erase(new_pos)
		var new_pos_neighbors: Array = [
		new_pos + Vector3(-1, 0, 0), new_pos + Vector3(1, 0, 0),
		new_pos + Vector3(0, 1, 0), new_pos + Vector3(0, -1, 0),
		new_pos + Vector3(0, 0, -1), new_pos + Vector3(0, 0, 1)
		]
		for n_pos in new_pos_neighbors:
			if n_pos.x >= -1 and n_pos.x <= 1 and n_pos.z >= -1 and n_pos.z <= 1:
				if n_pos.y == 1 or block_type.block_pos.has(Vector3(n_pos.x, n_pos.y - 1, n_pos.z)):
					if  not block_type.block_pos.has(n_pos):
						if not block_type.valid_pos.has(n_pos):
							block_type.valid_pos.append(n_pos)
	
	# Print updated pos
	print(" --- Block Pos --- ")
	for pos in block_type.block_pos:
		print(pos)
	print(" --- Valid Pos --- ")
	for pos in block_type.valid_pos:
		print(pos)
	
