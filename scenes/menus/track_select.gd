extends Control


var track_file_dict := {
	"sunken_boat": "res://scenes/tracks/paulo_3/paulo_3.tscn"
}


# Called when the node enters the scene tree for the first time.
func _ready():
	for button:Button in %ButtonsVBox.get_children():
		## make the nodes named like the dict keys
		button.pressed.connect(make_race.bind(button.name))


func make_race(chosen_track_entry:String):
	#print(chosen_track_entry)
	var race_data := RaceData.new()
	# defaults: type=normal, laps=3
	race_data.track_file = track_file_dict[chosen_track_entry]
	# TODO: change strings to RaceDriver object.
	## assuming we have 3 AI drivers and one player driver,
	for i in range(7):
		race_data.drivers.append("AI")
	race_data.drivers.append("PLAYER")
	
	RaceManager.setup_race(race_data)
