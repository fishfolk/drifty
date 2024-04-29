extends Node

var pause_in_race_packed = preload("res://scenes/menus/pause_in_race.tscn")

var screen_in_race = null

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_in_race = pause_in_race_packed.instantiate()
	add_child(screen_in_race)
	pass # Replace with function body.


func _unhandled_input(event:InputEvent):
	if Input.is_action_just_pressed("pause"):
		_handle_pause_input(event)


func _handle_pause_input(_event:InputEvent):
	# if in race
	if RaceManager.current_race:
		if not screen_in_race.visible:
			screen_in_race.open()
		else:
			screen_in_race.close()
		get_viewport().set_input_as_handled()
