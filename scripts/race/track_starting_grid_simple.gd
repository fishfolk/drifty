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
	var markers = get_children()
	var drivers_list = RaceManager.current_race.drivers.duplicate()
	var position_count = min(drivers_list.size(), markers.size())
	
	for current_position in range(position_count):
		#var car_instance : SimpleRaycastCar = karts_list[current_position].instantiate()
		var car_instance : SimpleRaycastCar = kart_packed.instantiate()
		car_instance.global_transform = markers[current_position].global_transform
		
		if drivers_list[current_position] == "AI":
			var ai_input = SimpleAIKartInput.new()
			car_instance.set_input_node(ai_input)
			# nerf AI drivers
			car_instance.top_speed *= 0.95
			car_instance.engine_power *= 0.9
		
		if drivers_list[current_position] == "PLAYER":
			car_instance.get_node("ChaseCamRoot").set_current(true)
		
		# test race types
		# parts to add to player cars, maybe not here, but somewhere?
		#var time_tracker = CarTimeTracker.new()
		#var check_tracker = CarCheckpointTracker.new()
		#car_instance.add_child(time_tracker)
		#car_instance.add_child(check_tracker)
		
		# change to add to viewports
		get_tree().current_scene.add_child.call_deferred(car_instance)
		print("spawned", car_instance)
