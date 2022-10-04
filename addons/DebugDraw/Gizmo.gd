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
		# Finish drawing
		line_geo.end()
		point_geo.end()
		mesh_geo.end()

		line_geo.set_custom_aabb(aabb)
		point_geo.set_custom_aabb(aabb)
		mesh_geo.set_custom_aabb(aabb)

		line_geo.extra_cull_margin = 999
		point_geo.extra_cull_margin = 999
		mesh_geo.extra_cull_margin = 999

		state = 0

# Called after rendering
func _on_after_render() -> void:
	# Finished drawing
	if state == 0:
		# Clear drawing
		line_geo.clear()
		point_geo.clear()
		mesh_geo.clear()

		# Start drawing
		line_geo.begin(Mesh.PRIMITIVE_TRIANGLES)
		point_geo.begin(Mesh.PRIMITIVE_TRIANGLES)
		mesh_geo.begin(Mesh.PRIMITIVE_TRIANGLES)

		# Initial aabb
		aabb = AABB(Vector3.ZERO, Vector3.ONE * -1)

		state = 1

# Add a line
func add_line(point_a: Vector3, point_b: Vector3, color: Color, radius: float = 1.0) -> void:
	if state != 1: return

	line_geo.set_color(color)

	var off: Vector3 = point_b - point_a
	line_geo.set_normal(off)
	line_geo.set_uv2(Vector2(0.0, 0.0))

	line_geo.set_uv(Vector2(-1.0, -1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)
	line_geo.set_uv(Vector2(-1.0,  1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)
	line_geo.set_uv(Vector2( 1.0, -1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)

	line_geo.set_uv(Vector2( 1.0, -1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)
	line_geo.set_uv(Vector2(-1.0,  1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)
	line_geo.set_uv(Vector2( 1.0,  1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)

	line_geo.set_uv2(Vector2(1.0, 0.0))
	
	line_geo.set_uv(Vector2(-1.0, -1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)
	line_geo.set_uv(Vector2(-1.0,  1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)
	line_geo.set_uv(Vector2( 1.0, -1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)

	line_geo.set_uv(Vector2( 1.0, -1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)
	line_geo.set_uv(Vector2(-1.0,  1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)
	line_geo.set_uv(Vector2( 1.0,  1.0) * radius * 0.5)
	line_geo.add_vertex(point_a)

	var line_aabb: AABB = AABB(
		point_a - Vector3.ONE * radius, off + Vector3.ONE * radius
	)
	if aabb.size.x == -1:
		aabb = line_aabb
	else:
		aabb = aabb.merge(line_aabb)

# Add a point
func add_point(point: Vector3, color: Color, radius: float = 1.0) -> void:
	if state != 1: return

	point_geo.set_color(color)

	point_geo.set_uv(Vector2(-1.0, -1.0) * radius)
	point_geo.add_vertex(point)
	point_geo.set_uv(Vector2(-1.0,  1.0) * radius)
	point_geo.add_vertex(point)
	point_geo.set_uv(Vector2( 1.0, -1.0) * radius)
	point_geo.add_vertex(point)

	point_geo.set_uv(Vector2( 1.0, -1.0) * radius)
	point_geo.add_vertex(point)
	point_geo.set_uv(Vector2(-1.0,  1.0) * radius)
	point_geo.add_vertex(point)
	point_geo.set_uv(Vector2( 1.0,  1.0) * radius)
	point_geo.add_vertex(point)

	var point_aabb: AABB = AABB(
		point - Vector3.ONE * radius, Vector3.ONE * radius * 2.0
	)
	if aabb.size.x == -1:
		aabb = point_aabb
	else:
		aabb = aabb.merge(point_aabb)

# Add a triangle
func add_triangle(
	vertex1: Vector3, vertex2: Vector3, vertex3: Vector3, 
	color1: Color, color2: Color, color3: Color
) -> void:
	if state != 1: return

	mesh_geo.set_color(color1)
	mesh_geo.add_vertex(vertex1)
	mesh_geo.set_color(color2)
	mesh_geo.add_vertex(vertex2)
	mesh_geo.set_color(color3)
	mesh_geo.add_vertex(vertex3)

	var triangle_aabb: AABB = AABB(
		vertex1, Vector3.ZERO
	)
	triangle_aabb = triangle_aabb.expand(vertex2)
	triangle_aabb = triangle_aabb.expand(vertex3)
	if aabb.size.x == -1:
		aabb = triangle_aabb
	else:
		aabb = aabb.merge(triangle_aabb)

# Add a box
func add_box(
	center: Vector3, size: Vector3, color: Color
) -> void:
	if state != 1: return

	mesh_geo.set_color(color)

	var x0: float = center.x - size.x * 0.5
	var y0: float = center.y - size.y * 0.5
	var z0: float = center.z - size.z * 0.5

	var x1: float = center.x + size.x * 0.5
	var y1: float = center.y + size.y * 0.5
	var z1: float = center.z + size.z * 0.5

	# -X face
	mesh_geo.add_vertex(Vector3(x0, y0, z0))
	mesh_geo.add_vertex(Vector3(x0, y1, z0))
	mesh_geo.add_vertex(Vector3(x0, y0, z1))
	mesh_geo.add_vertex(Vector3(x0, y0, z1))
	mesh_geo.add_vertex(Vector3(x0, y1, z0))
	mesh_geo.add_vertex(Vector3(x0, y1, z1))

	# +X face
	mesh_geo.add_vertex(Vector3(x1, y0, z1))
	mesh_geo.add_vertex(Vector3(x1, y1, z1))
	mesh_geo.add_vertex(Vector3(x1, y0, z0))
	mesh_geo.add_vertex(Vector3(x1, y0, z0))
	mesh_geo.add_vertex(Vector3(x1, y1, z1))
	mesh_geo.add_vertex(Vector3(x1, y1, z0))

	# -Y face
	mesh_geo.add_vertex(Vector3(x0, y0, z0))
	mesh_geo.add_vertex(Vector3(x0, y0, z1))
	mesh_geo.add_vertex(Vector3(x1, y0, z0))
	mesh_geo.add_vertex(Vector3(x1, y0, z0))
	mesh_geo.add_vertex(Vector3(x0, y0, z1))
	mesh_geo.add_vertex(Vector3(x1, y0, z1))

	# +Y face
	mesh_geo.add_vertex(Vector3(x0, y1, z1))
	mesh_geo.add_vertex(Vector3(x0, y1, z0))
	mesh_geo.add_vertex(Vector3(x1, y1, z1))
	mesh_geo.add_vertex(Vector3(x1, y1, z1))
	mesh_geo.add_vertex(Vector3(x0, y1, z0))
	mesh_geo.add_vertex(Vector3(x1, y1, z0))

	# -Z face
	mesh_geo.add_vertex(Vector3(x1, y0, z0))
	mesh_geo.add_vertex(Vector3(x1, y1, z0))
	mesh_geo.add_vertex(Vector3(x0, y0, z0))
	mesh_geo.add_vertex(Vector3(x0, y0, z0))
	mesh_geo.add_vertex(Vector3(x1, y1, z0))
	mesh_geo.add_vertex(Vector3(x0, y1, z0))

	# +Z face
	mesh_geo.add_vertex(Vector3(x0, y0, z1))
	mesh_geo.add_vertex(Vector3(x0, y1, z1))
	mesh_geo.add_vertex(Vector3(x1, y0, z1))
	mesh_geo.add_vertex(Vector3(x1, y0, z1))
	mesh_geo.add_vertex(Vector3(x0, y1, z1))
	mesh_geo.add_vertex(Vector3(x1, y1, z1))




