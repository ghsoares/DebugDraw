tool
extends Spatial

func _process(delta: float) -> void:
	Gizmo.add_line(Vector3.ZERO, Vector3.RIGHT * 128.0, Color.red, 60.0)
	Gizmo.add_point(Vector3.ZERO, Color.green, 64.0)
