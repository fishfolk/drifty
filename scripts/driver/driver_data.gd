class_name DriverData
extends Resource
## Used for initial setup of racers


enum DriverType { PLAYER, SIMPLE_AI }

@export var driver_type : DriverType = DriverType.SIMPLE_AI
@export var fish_type : int = 0
@export var bike_type : int = 0

static var fish_model_list = [
	load("res://scenes/vehicles/models/Fish/Fish_Clowny.gltf"),
	load("res://scenes/vehicles/models/Fish/Fish_Pescy.gltf"),
	load("res://scenes/vehicles/models/Fish/Fish_Sharky.gltf"),
	load("res://scenes/vehicles/models/Fish/Fish_Sluggy.gltf"),
	load("res://scenes/vehicles/models/Fish/Fish_Orcy.gltf"),
	load("res://scenes/vehicles/models/Fish/Fish_Puffy.gltf"),
	load("res://scenes/vehicles/models/Fish/Fish_Axy.gltf"),
	load("res://scenes/vehicles/models/Fish/Bird_Gully.gltf"),
]

static var bike_model_list = [
	load("res://scenes/vehicles/models/Bike/Fishi_Sword.gltf"),
	load("res://scenes/vehicles/models/Bike/Fishi_Exhaust.gltf"),
	load("res://scenes/vehicles/models/Bike/kraken.gltf"),
	load("res://scenes/vehicles/models/Bike/Octopus.gltf"),
	load("res://scenes/vehicles/models/Bike/Seahorse.gltf"),
	load("res://scenes/vehicles/models/Bike/Shark.gltf"),

]

func get_model_fish() -> PackedScene:
	return fish_model_list[fish_type]

func get_model_bike() -> PackedScene:
	return bike_model_list[bike_type]

func get_input_node() -> KartInput:
	match driver_type:
		DriverType.PLAYER:
			return PlayerKartInput.new()
		DriverType.SIMPLE_AI:
			return SimpleAIKartInput.new()
	return null

func make_random_driver():
	fish_type = randi_range(0, fish_model_list.size()-1)
	bike_type = randi_range(0, bike_model_list.size()-1)
