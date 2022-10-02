tool
extends Spatial

func _process(delta: float) -> void:
	Gizmo.add_line(Vector3.ZERO, Vector3.RIGHT * 32.0, Color.red, 16.0)
