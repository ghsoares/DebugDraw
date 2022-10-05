tool
extends Spatial

var t: float = 0.0

func _ready() -> void:
	Gizmo.connect("draw_gizmo", self, "on_draw_gizmo")

func _process(delta: float) -> void:
	t += delta

func on_draw_gizmo() -> void:
	for i in 16:
		var a: float = (i / 16.0) * TAU
		a += t * TAU * ((1 + i) / 16.0)
		var c: float = cos(a) * 16.0
		var s: float = sin(a) * 16.0

		var p: Vector3 = Vector3(c, 0.0, s) 

		Gizmo.add_point(p, Color.red,  8.0)
