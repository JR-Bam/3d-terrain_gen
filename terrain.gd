@tool
extends StaticBody3D

@export var generate: bool = false:
	set(value):
		generate = value
		if Engine.is_editor_hint():
			generate_terrain()

@export var size = 200
@export var subdivisions = 128
@export var amplitude = 40

# Base noise for large mountain structures
@export var base_noise = FastNoiseLite.new():
	set(new_noise):
		base_noise = new_noise
		if Engine.is_editor_hint():
			generate_terrain()
# Ridge noise for sharp peaks
@export var ridge_noise = FastNoiseLite.new():
	set(new_noise):
		ridge_noise = new_noise
		if Engine.is_editor_hint():
			generate_terrain()

@onready var mesh_instance = $MeshInstance3D


func generate_terrain():
	# Configure plane mesh
	var plane = PlaneMesh.new()
	plane.size = Vector2(size, size)
	plane.subdivide_width = subdivisions
	plane.subdivide_depth = subdivisions
	
	# Prepare mesh data
	var data_tool = MeshDataTool.new()
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane.get_mesh_arrays())
	data_tool.create_from_surface(array_mesh, 0)
	
	# Generate heights
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		var x = vertex.x
		var z = vertex.z
		
		# Base height with fractal noise
		var base_height = base_noise.get_noise_2d(x, z)
		
		# Ridge effect using absolute noise
		var ridge = 1.0 - abs(ridge_noise.get_noise_2d(x, z))
		ridge = pow(ridge, 3) * 0.5 # Sharpen ridges
		
		# combine and scale heights
		var total_height = base_height + ridge
		total_height = pow(total_height * 0.5 + 0.5, 4) * amplitude # Amplify peaks
		
		vertex.y = total_height
		data_tool.set_vertex(i, vertex)
		
	# Commit changes to mesh
	array_mesh.clear_surfaces()
	data_tool.commit_to_surface(array_mesh)
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(array_mesh, 0)
	surface_tool.generate_normals()
	mesh_instance.mesh = surface_tool.commit()
