tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("Gizmo", "res://addons/DebugDraw/Gizmo.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("Gizmo")
