class_name RaceData
extends Resource

enum RACE_TYPE { NULL=0, NORMAL, TIME_ATTACK, }

@export var track_file : String = ""
#@export var track_name : String = ""

@export var race_type : RACE_TYPE = RACE_TYPE.NORMAL
@export var lap_count : int = 2

## starting grid goes here
@export var drivers : Array = []

#@export var race_results : RaceResults = null

func _init():
	pass

#func _init(
		#track_in:PackedScene, 
		#track_name_in:String,
		#race_type_in:RACE_TYPE, 
		#lap_count_in:int,
		#player_cars_in:Array
		#):
	#
	#track_packed = track_in
	#track_name = track_name_in
	#race_type = race_type_in
	#lap_count = lap_count_in
	#player_cars = player_cars_in.duplicate(false)
