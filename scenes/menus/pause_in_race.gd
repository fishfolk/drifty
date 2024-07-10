extends CanvasLayer


func _ready():
	visible = false
	#AudioManager.install_ui(get_child(0))


func open():
	get_tree().paused = true
	visible = true
	%btn_continue.grab_focus()


func close():
	get_tree().paused = false
	visible = false


func _on_btn_continue_pressed():
	#%btn_continue.release_focus()
	print("continue")
	close()


func _on_btn_restart_pressed():
	RaceManager.setup_race(RaceManager.current_race)
	close()


func _on_btn_exit_pressed():
	RaceManager.clear_race()
	close()
	get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")
	
