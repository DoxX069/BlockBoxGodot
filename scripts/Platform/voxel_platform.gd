extends Node3D

# Grid dimensions
@export_range (1,100) var width: int = 10
@export_range (1,100) var length: int = 10

# exported “public” properties
@export var cell_size: Vector2 = Vector2(1, 1)  # XZ size of each cell

# Atlas settings
@export var atlas_texture: Texture2D
@export_range(1,16) var atlas_cols: int = 2    # number of tiles horizontally
@export_range(1,16) var atlas_rows: int = 2    # number of tiles vertically

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D



func _ready():
	update_platform()

func update_platform():
	# Prepare material using the atlas
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = atlas_texture
	mat.uv1_scale = Vector3(1.0 / atlas_cols, 1.0 / atlas_rows, 1)
	mesh_instance.material_override = mat
	
	# Precompute UV‐tile size
	var uv_scale := Vector2(1.0 / atlas_cols, 1.0 / atlas_rows)
	
	# Build the mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color.WHITE)
	
	# Build a flat grid of quads on XZ-Plane
	for x in width: 
		for z in length:
			var x0 = x * cell_size.x
			var z0 = z * cell_size.y
			var x1 = x0 + cell_size.x
			var z1 = z0 + cell_size.y

			# vertices (y = 0)
			var v0 = Vector3(x0, 0, z0)
			var v1 = Vector3(x1, 0, z0)
			var v2 = Vector3(x1, 0, z1)
			var v3 = Vector3(x0, 0, z1)

			# Determine which tile this cell uses.
			# Replace this with your own logic (e.g. an array lookup).
			var tile_index := (x + z * width) % (atlas_cols * atlas_rows)
			var tx = tile_index % atlas_cols
			var ty = tile_index / atlas_cols

			# Compute UV offset in atlas
			var uv_offset = Vector2(tx, ty) * uv_scale


			var uv0 = Vector2(x / float(width), z / float(length))
			var uv1 = Vector2((x+1)/ float(width), z / float(length))
			var uv2 = Vector2((x+1)/ float(width), (z+1)/ float(length))
			var uv3 = Vector2(x/ float(width), (z+1)/ float(length))

			# First triangle
			st.set_uv(uv0); st.set_normal(Vector3.UP); st.add_vertex(v0)
			st.set_uv(uv1); st.set_normal(Vector3.UP); st.add_vertex(v1)
			st.set_uv(uv2); st.set_normal(Vector3.UP); st.add_vertex(v2)
			# Second triangle
			st.set_uv(uv2); st.set_normal(Vector3.UP); st.add_vertex(v2)
			st.set_uv(uv3); st.set_normal(Vector3.UP); st.add_vertex(v3)
			st.set_uv(uv0); st.set_normal(Vector3.UP); st.add_vertex(v0)
		

	# Commit mesh
	var array_mesh = st.commit()
	mesh_instance.set_mesh(array_mesh)
	mesh_instance.mesh = array_mesh

	# Update collision
	var concave = ConcavePolygonShape3D.new()
	concave.set_faces(array_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX])
	collision_shape.shape = concave
