extends Control


var track_file_dict := {
	"sunken_boat": "res://scenes/tracks/paulo_3/paulo_3.tscn"
}


# Called when the node enters the scene tree for the first time.
func _ready():
	%ButtonReturn.pressed.connect(_on_button_pressed.bind("return"))
	for button:Button in %ButtonsVBox.get_children():
		## make the nodes named like the dict keys
		button.pressed.connect(make_race.bind(button.name))
	%ButtonsVBox.get_child(0).grab_focus()


func make_race(chosen_track_entry:String):
	#print(chosen_track_entry)
	var race_data := RaceData.new()
	# defaults: type=normal, laps=3
	race_data.track_file = track_file_dict[chosen_track_entry]
	# TODO: change strings to RaceDriver object.
	## assuming we have 3 AI drivers and one player driver,
	for i in range(7):
		var data = DriverData.new() # defaults to AI
		data.make_random_driver()
		race_data.drivers.append(data)
	race_data.drivers.append(MenuManager.player_driver_data)
	
	RaceManager.setup_race(race_data)


func _on_button_pressed(type):
	match type:
		"return":
			get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")
