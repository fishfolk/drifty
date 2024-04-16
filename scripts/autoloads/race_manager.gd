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
var race_path : Path3D
## Homing items will refer to this.
#var item_path : Path3D


## racers, stored by position order, then id order (?)
## in the future, make driver and kart different objects
var driver_karts : Array[SimpleRaycastCar] = []


func setup_race(race_data:RaceData):
	current_race = race_data
	for value in race_setup_checks.values():
		value = false
	get_tree().change_scene_to_file(current_race.track_file)
