extends Node



signal race_begun
signal race_finished

signal intro_flydown_started
signal intro_flydown_finished

## use current_race.lap_count for max laps instead.
signal car_completed_lap(car, new_lap)#, max_laps)



## Dict with data of everything needed to setup a race scene.
## Includes race type, map, laps, opponents.
var current_race : RaceData = null


## Countdown will only start after all these
## steps have been checked.
var race_setup_checks = {
	"checkpoints": false,
	"cameras": false,
	"starting_grid": false,
}


## AI Drivers will refer to this.
## Ideally, there should be a custom system for multiple paths.
var race_path : RacePath3D
## Homing items will refer to this.
#var item_path : Path3D


## racers, stored by position order, then id order (?)
## in the future, make driver and kart different objects
var driver_karts : Array[SimpleRaycastCar] = []


func setup_race(race_data:RaceData):
	driver_karts = []
	current_race = race_data
	for value in race_setup_checks.values():
		value = false
	get_tree().change_scene_to_file(current_race.track_file)


func get_kart_rank(kart:SimpleRaycastCar) -> int:
	if driver_karts == []:
		#print_debug("No karts to rank!")
		return 1
	return driver_karts.find(kart) + 1


func rank_karts():
	if driver_karts == []:
		print("No karts to rank!")
		return
	match current_race.race_type:
		RaceData.RACE_TYPE.NORMAL:
			driver_karts = rank_karts_by_position(driver_karts)


func rank_karts_by_position(array_to_sort:Array[SimpleRaycastCar]) -> Array[SimpleRaycastCar]:
	var result_array := array_to_sort.duplicate()
	result_array.sort_custom(func(kart_a:SimpleRaycastCar, kart_b:SimpleRaycastCar):
		var tracker_a = kart_a.get_node("KartTrackProgressComponent")
		var tracker_b = kart_b.get_node("KartTrackProgressComponent")
		if not tracker_a or not tracker_b: return false
		
		if not tracker_a.invalid_lap and tracker_b.invalid_lap: return true
		if tracker_a.invalid_lap and not tracker_b.invalid_lap: return false
		
		if tracker_a.current_lap > tracker_b.current_lap: return true
		elif tracker_a.current_lap < tracker_b.current_lap: return false
		else:
			if tracker_a.progress_offset > tracker_b.progress_offset: return true
			else: return false
	)
	#print_debug(result_array)
	return result_array


func _physics_process(delta):
	rank_karts()
