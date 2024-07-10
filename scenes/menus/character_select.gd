extends Control

@export var kart_preview : Node3D
var kart_animation_component : KartAnimationComponent

func _ready():
	kart_animation_component = kart_preview.get_node("KartAnimationComponent")
	
	%ButtonNext.pressed.connect(_on_button_pressed.bind("next"))
	
	%SliderFish.max_value = DriverData.fish_model_list.size()-1
	%SliderBike.max_value = DriverData.bike_model_list.size()-1
	
	load_fish_from_configs()
	
	await get_tree().create_timer(.1).timeout
	%SliderFish.grab_focus()


func load_fish_from_configs():
	if not MenuManager.player_driver_data:
		MenuManager.player_driver_data = DriverData.new()
		MenuManager.player_driver_data.driver_type = DriverData.DriverType.PLAYER
	
	var fish = MenuManager.player_driver_data.fish_type
	var bike = MenuManager.player_driver_data.bike_type
	%SliderFish.value = fish
	change_fish(fish)
	%SliderBike.value = bike
	change_bike(bike)


func change_fish(index:int):
	MenuManager.player_driver_data.fish_type = index
	var model_packed = MenuManager.player_driver_data.get_model_fish()
	kart_animation_component.set_model_fish(model_packed)

func change_bike(index:int):
	MenuManager.player_driver_data.bike_type = index
	var model_packed = MenuManager.player_driver_data.get_model_bike()
	kart_animation_component.set_model_bike(model_packed)


func _on_slider_fish_value_changed(value):
	change_fish(value)


func _on_slider_bike_value_changed(value):
	change_bike(value)


func _on_button_pressed(type):
	match type:
		"next":
			get_tree().change_scene_to_file("res://scenes/menus/track_select.tscn")
