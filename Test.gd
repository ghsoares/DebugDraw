tool
extends Spatial

func _process(delta: float) -> void:
	Gizmo.add_line(Vector3.ZERO, Vector3.RIGHT * 32.0, Color.red, 16.0)
	Gizmo.add_point(Vector3.ZERO, Color.blue, 16.0)
