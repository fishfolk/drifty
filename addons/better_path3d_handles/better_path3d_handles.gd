@tool
extends EditorPlugin


const Path3DHandlesGizmoPlugin = preload("res://addons/better_path3d_handles/path3d_handles_gizmo_plugin.gd")

var gizmo_plugin = Path3DHandlesGizmoPlugin.new()

func _enter_tree():
	print("Registering gizmo plugin node")
	add_node_3d_gizmo_plugin(gizmo_plugin)


func _exit_tree():
	print("Removing gizmo plugin node")
	remove_node_3d_gizmo_plugin(gizmo_plugin)