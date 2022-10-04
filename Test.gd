tool
extends Spatial

func _process(delta: float) -> void:
	Gizmo.add_line(Vector3.RIGHT * -128.0, Vector3.RIGHT * 128.0, Color.red, 32.0)
	#Gizmo.add_point(Vector3.ZERO, Color.green, 64.0)
