extends Node3D


# singleton, accessible by race and checkpoint trackers.
#var race_progress = preload("res://systems/checkpoints/RaceProgressSingleton.res")

var kart_packed = preload("res://scenes/vehicles/raycast/SimpleRaycastKart.tscn")

func _ready():
	if not Engine.is_editor_hint():
		if not RaceManager.current_race: return
		print("heyyy")
		spawn_cars() # TODO: spawn all cars
		RaceManager.race_setup_checks["starting_grid"] = true

func spawn_cars() -> void:
	for kart in RaceManager.driver_karts:
		kart.queue_free()
	
	var markers = get_children()
	var drivers_list = RaceManager.current_race.drivers.duplicate()
	var position_count = min(drivers_list.size(), markers.size())
	
	for current_position in range(position_count):
		#var car_instance : SimpleRaycastCar = karts_list[current_position].instantiate()
		var car_instance : SimpleRaycastCar = kart_packed.instantiate()
		car_instance.global_transform = markers[current_position].global_transform
		
		# change this in the future to add to viewports for multiplayer
		get_tree().current_scene.add_child.call_deferred(car_instance)
		RaceManager.driver_karts.append(car_instance)
		
		var driver_data : DriverData = drivers_list[current_position]
		
		# set models
		var kart_animation_component = car_instance.get_node("KartAnimationComponent")
		kart_animation_component.set_model_fish(driver_data.get_model_fish())
		kart_animation_component.set_model_bike(driver_data.get_model_bike())
		
		## parts to add to player cars, maybe not here, but somewhere?
		#var time_tracker = CarTimeTracker.new()
		#var check_tracker = CarCheckpointTracker.new()
		#car_instance.add_child(time_tracker)
		#car_instance.add_child(check_tracker)
		## test race types
		if RaceManager.current_race.race_type == RaceData.RACE_TYPE.NORMAL:
			var progress_component = KartTrackProgressComponent.new()
			car_instance.add_child(progress_component, true)
		
		# set driver types
		if driver_data.driver_type == DriverData.DriverType.SIMPLE_AI:
			var ai_input = SimpleAIKartInput.new()
			car_instance.set_input_node(ai_input)
			# nerf AI drivers
			car_instance.top_speed *= randf_range(0.9, 1.0)
			car_instance.engine_power *= randf_range(0.9, 1.0)
		
		if driver_data.driver_type == DriverData.DriverType.PLAYER:
			var player_input = PlayerKartInput.new()
			car_instance.set_input_node(player_input)
			car_instance.get_node("ChaseCamRoot").set_current(true)
		
		print("spawned and added to rank", car_instance)



func _clear_previous_components(kart:SimpleRaycastCar):
	for child in kart.get_children():
		if child is KartInput: child.free()
		if child is KartTrackProgressComponent: child.free()
