tool
extends Spatial

func _ready() -> void:
	Gizmo.connect("draw_gizmo", self, "on_draw_gizmo")

func on_draw_gizmo() -> void:
	Gizmo.add_polyline(
		PoolVector3Array([
			Vector3(0.0, 0.0, 0.0),
			Vector3(0.0, 0.0, 64.0),
			Vector3(64.0, 0.0, 64.0)
		]),
		PoolColorArray([Color.red, Color.green, Color.blue]),
		PoolRealArray([4.0, 16.0, 64.0])
	)
	# Gizmo.add_line(
	# 	Vector3(-256.0, 0.0, 0.0),
	# 	Vector3( 256.0, 0.0, 0.0),
	# 	Color.red, Color.red, 32.0, 32.0
	# )
