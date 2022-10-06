tool
extends Node

# Current draw state
var state: int

# Current aabb
var aabb: AABB

# The line geometry
var line_geo: ImmediateGeometry

# The point geometry
var point_geo: ImmediateGeometry

# The mesh geometry
var mesh_geo: ImmediateGeometry

# Signal called to draw gizmo
signal draw_gizmo()

# Called when entering the tree
func _enter_tree() -> void:
	# Create the geometries
	line_geo = ImmediateGeometry.new()
	point_geo = ImmediateGeometry.new()
	mesh_geo = ImmediateGeometry.new()

	# Load the shaders
	var line_shader: Shader = ResourceLoader.load("res://addons/DebugDraw/Shaders/DebugLine.tres")
	var point_shader: Shader = ResourceLoader.load("res://addons/DebugDraw/Shaders/DebugPoint.tres")
	var mesh_shader: Shader = ResourceLoader.load("res://addons/DebugDraw/Shaders/DebugMesh.tres")

	# Create the materials
	var line_mat: ShaderMaterial = ShaderMaterial.new()
	var point_mat: ShaderMaterial = ShaderMaterial.new()
	var mesh_mat: ShaderMaterial = ShaderMaterial.new()
	line_mat.shader = line_shader
	point_mat.shader = point_shader
	mesh_mat.shader = mesh_shader

	# Set the material
	line_geo.material_override = line_mat
	point_geo.material_override = point_mat
	mesh_geo.material_override = point_mat
	
	# Add the geometries
	add_child(line_geo)
	add_child(point_geo)
	add_child(mesh_geo)

	# Connect pre and post render
	VisualServer.connect("frame_pre_draw", self, "_on_before_render")
	VisualServer.connect("frame_post_draw", self, "_on_after_render")

	# Set draw state
	state = 0

# Called when exiting the tree
func _exit_tree() -> void:
	# Disconnect pre and post render
	VisualServer.disconnect("frame_pre_draw", self, "_on_before_render")
	VisualServer.disconnect("frame_post_draw", self, "_on_after_render")

	# Is drawing
	if state == 1:
		# Finish drawing
		line_geo.end()
		point_geo.end()
		mesh_geo.end()

		state = 0
	
	# Free geometries
	line_geo.queue_free()
	point_geo.queue_free()
	mesh_geo.queue_free()

# Called before rendering
func _on_before_render() -> void:
	# Is drawing
	if state == 1:
		# Emit signal
		emit_signal("draw_gizmo")

		# Finish drawing
		line_geo.end()
		point_geo.end()
		mesh_geo.end()

		# line_geo.set_custom_aabb(aabb)
		# point_geo.set_custom_aabb(aabb)
		# mesh_geo.set_custom_aabb(aabb)

		line_geo.extra_cull_margin = 99999
		point_geo.extra_cull_margin = 99999
		mesh_geo.extra_cull_margin = 99999

		state = 0

# Called after rendering
func _on_after_render() -> void:
	# Finished drawing
	if state == 0:
		# Clear drawing
		line_geo.clear()
		point_geo.clear()
		mesh_geo.clear()

		line_geo.set_custom_aabb(AABB())
		point_geo.set_custom_aabb(AABB())
		mesh_geo.set_custom_aabb(AABB())

		# Start drawing
		line_geo.begin(Mesh.PRIMITIVE_TRIANGLES)
		point_geo.begin(Mesh.PRIMITIVE_TRIANGLES)
		mesh_geo.begin(Mesh.PRIMITIVE_TRIANGLES)

		# Initial aabb
		aabb = AABB(Vector3.ZERO, Vector3.ONE * -1)

		state = 1

# Add a point
func add_point(point: Vector3, color: Color, radius: float = 1.0) -> void:
	if state != 1: return

	point_geo.set_color(color)
	point_geo.set_uv2(Vector2(radius, 0.0))

	point_geo.set_uv(Vector2(-1.0, -1.0))
	point_geo.add_vertex(point)

	point_geo.set_uv(Vector2( 1.0,  1.0))
	point_geo.add_vertex(point)

	point_geo.set_uv(Vector2(-1.0,  1.0))
	point_geo.add_vertex(point)

	point_geo.set_uv(Vector2( 1.0,  1.0))
	point_geo.add_vertex(point)

	point_geo.set_uv(Vector2(-1.0, -1.0))
	point_geo.add_vertex(point)

	point_geo.set_uv(Vector2( 1.0, -1.0))
	point_geo.add_vertex(point)

	var point_aabb: AABB = AABB(
		point - Vector3.ONE * radius, Vector3.ONE * radius * 2.0
	)
	if aabb.size.x == -1:
		aabb = point_aabb
	else:
		aabb = aabb.merge(point_aabb)

# Add a line
func add_line(
	point_a: Vector3, point_b: Vector3,
	color_a: Color, color_b: Color,
	radius_a: float = 1.0,
	radius_b: float = 1.0
) -> void:
	if state != 1: return

	var off: Vector3 = point_b - point_a

	line_geo.set_uv2(Vector2(radius_a, radius_b))
	line_geo.set_tangent(Plane(off, 0.0))
	line_geo.set_normal(off)
	
	line_geo.set_uv(Vector2(-2.0, -1.0))
	line_geo.set_color(color_a)
	line_geo.add_vertex(point_a)

	line_geo.set_uv(Vector2( 2.0,  1.0))
	line_geo.set_color(color_b)
	line_geo.add_vertex(point_b)

	line_geo.set_uv(Vector2(-2.0,  1.0))
	line_geo.set_color(color_a)
	line_geo.add_vertex(point_a)

	line_geo.set_uv(Vector2( 2.0,  1.0))
	line_geo.set_color(color_b)
	line_geo.add_vertex(point_b)

	line_geo.set_uv(Vector2(-2.0, -1.0))
	line_geo.set_color(color_a)
	line_geo.add_vertex(point_a)

	line_geo.set_uv(Vector2( 2.0, -1.0))
	line_geo.set_color(color_b)
	line_geo.add_vertex(point_b)

	var a: Vector3 = point_a - Vector3.ONE * radius_a
	var b: Vector3 = point_b + Vector3.ONE * radius_b

	var line_aabb: AABB = AABB(
		a, b - a
	)
	if aabb.size.x == -1:
		aabb = line_aabb
	else:
		aabb = aabb.merge(line_aabb)

# Add a polyline
func add_polyline(
	points: PoolVector3Array, 
	colors: PoolColorArray, 
	radius: PoolRealArray = PoolRealArray([1.0])
) -> void:
	if state != 1: return

	# Get number of points
	var point_count: int = points.size()

	# Get number of colors
	var color_count: int = colors.size()

	# Get number of radius
	var radius_count: int = radius.size()
	
	# Assert that have at least two points
	assert(point_count > 1)

	# For each line
	for i in point_count - 1:
		# Get the two points
		var p0: Vector3 = points[i + 0]
		var p1: Vector3 = points[i + 1]

		# Get the two colors
		var c0: Color = colors[i + 0] if i + 0 < color_count else colors[color_count - 1]
		var c1: Color = colors[i + 1] if i + 1 < color_count else colors[color_count - 1]

		# Get the two radius
		var r0: float = radius[i + 0] if i + 0 < radius_count else radius[radius_count - 1]
		var r1: float = radius[i + 1] if i + 1 < radius_count else radius[radius_count - 1]

		# Add the line
		add_line(p0, p1, c0, c1, r0, r1)

# Add a mesh
func add_mesh(
	vertices: PoolVector3Array,
	colors: PoolColorArray,
	indices: PoolIntArray
) -> void:
	if state != 1: return

	# Get number of vertices
	var vert_count: int = vertices.size()

	# Get number of colors
	var color_count: int = colors.size()

	# Get number of indices
	var id_count: int = indices.size()

	# Must have multiple of 3 indices
	assert(id_count % 3 == 0)
	
	# Mesh aabb
	var mesh_aabb: AABB

	# For each indice
	for i in id_count:
		# Get indice
		var id: int = indices[i]

		# Assert that indice is valid
		assert(id >= 0 and id < vert_count)

		# Get vertice
		var vert: Vector3 = vertices[id]

		# Get color
		var color: Color = colors[id] if id < color_count else colors[color_count - 1]

		# Add vertex
		mesh_geo.set_color(color)
		mesh_geo.add_vertex(vert)

		# Add the vertice to aabb
		if i == 0:
			mesh_aabb = AABB(vert, Vector3.ZERO)
		else:
			mesh_aabb = mesh_aabb.expand(vert)

	# Merge mesh aabb
	if aabb.size.x == -1:
		aabb = mesh_aabb
	else:
		aabb = aabb.merge(mesh_aabb)

# # Add a box
# func add_box(
# 	center: Vector3, size: Vector3, color: Color
# ) -> void:
# 	if state != 1: return

# 	# Get corners
# 	var c000: Vector3 = Vector3(center.x - size.x, center.y - size.y, center.z - size.z)

# 	# Add box mesh
# 	add_mesh(
# 		PoolVector3Array([
# 			Vector3()
# 		])
# 	)




