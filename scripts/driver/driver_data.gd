class_name DriverData
extends Resource
## Used for initial setup of racers


enum DriverType { PLAYER, SIMPLE_AI }

@export var driver_type : DriverType = DriverType.SIMPLE_AI
@export var fish_type : int = 0
@export var bike_type : int = 0

static var fish_model_list = [
	load("res://scenes/vehicles/models/Pilotos/Piloto 3 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 2 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 1 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 4 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 5 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 6 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 7 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 8 .glb"),
]

static var bike_model_list = [
	load("res://scenes/vehicles/models/Motos/moto 1 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 2 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 3 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 4 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 5 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 6 .glb"),
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
