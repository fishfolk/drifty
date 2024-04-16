extends Node3D

@onready var anim_player = $AnimationPlayer

signal end_intro_camera_flydown

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Camera3D:
			child.clear_current()
	
	RaceManager.start_intro_camera_flydown.connect(_on_intro_camera_flydown)
	end_intro_camera_flydown.connect(RaceManager._on_end_intro_camera_flydown)
	RaceManager.ready_cameras = true



func _on_intro_camera_flydown() -> void:
	if not anim_player or (not anim_player.has_animation("intro1")):
		await get_tree().create_timer(0.5, false).timeout
		end_intro_camera_flydown.emit()
		return
	
	#TODO: change for multiple viewports
	#var current_camera = get_viewport().get_camera_3d()
	anim_player.play("intro1")
	anim_player.queue("intro2")
	anim_player.queue("intro3")
	anim_player.queue("RESET")
	await anim_player.animation_finished
	
	end_intro_camera_flydown.emit()
	return


