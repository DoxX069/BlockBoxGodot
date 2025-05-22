extends Camera3D

const RAY_LENGTH = 1000

func _physics_process(_delta):
	# Raycast from camera to mouse
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = self.project_ray_origin(mousepos)
	var end = origin + self.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	if Global.dragged_block:
		query.exclude = [Global.dragged_block]
	query.collide_with_areas = true
	Global.intersection = space_state.intersect_ray(query)
	# Store last intersection except for the platform area
	if Global.intersection and Global.intersection.collider != $"../../platform/Area3D":
		Global.last_intersection = Global.intersection
		#print(Global.intersection.collider)
