extends Control

@export var kart_preview : Node3D
var kart_animation_component : KartAnimationComponent


var fish_model_list = [
	load("res://scenes/vehicles/models/Pilotos/Piloto 1 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 2 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 3 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 4 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 5 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 6 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 7 .glb"),
	load("res://scenes/vehicles/models/Pilotos/Piloto 8 .glb"),
]
var fish_index : int = 0

var bike_model_list = [
	load("res://scenes/vehicles/models/Motos/moto 1 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 2 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 3 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 4 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 5 .glb"),
	load("res://scenes/vehicles/models/Motos/moto 6 .glb"),
]
var bike_index : int = 0


func _ready():
	kart_animation_component = kart_preview.get_node("KartAnimationComponent")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		fish_index = clamp(fish_index - 1, 0, fish_model_list.size()-1)
		change_fish(fish_index)
	elif Input.is_action_just_pressed("ui_right"):
		fish_index = clamp(fish_index + 1, 0, fish_model_list.size()-1)
		change_fish(fish_index)
	if Input.is_action_just_pressed("ui_up"):
		bike_index = clamp(bike_index - 1, 0, bike_model_list.size()-1)
		change_bike(bike_index)
	elif Input.is_action_just_pressed("ui_down"):
		bike_index = clamp(bike_index + 1, 0, bike_model_list.size()-1)
		change_bike(bike_index)

func change_fish(index:int):
	var model_packed = fish_model_list[fish_index]
	kart_animation_component.set_model_fish(model_packed)

func change_bike(index:int):
	var model_packed = bike_model_list[bike_index]
	kart_animation_component.set_model_bike(model_packed)
