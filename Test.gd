tool
extends Spatial

func _process(delta: float) -> void:
	Gizmo.add_line(
		Vector3(-128.0, 0.0, 32.0), 
		Vector3( 128.0, 0.0, 32.0),
		Color.red, 
		8.0
	)
	#Gizmo.add_point(Vector3.ZERO, Color.green, 64.0)
