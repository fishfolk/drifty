class_name KartTrackProgressComponent
extends Node

signal lap_changed(new_lap)

@onready var kart : SimpleRaycastCar = get_parent()

var current_lap : int = 1
var progress_offset : float = 0

var invalid_lap : bool = true

const update_frequency := 0.01
var update_timer := 0.0


func _ready():
	name = "KartTrackProgressComponent"


func _physics_process(delta):
	# we're updating every few ms to not overwhelm the system for now.
	# TODO: test if this optimization is needed
	update_timer += delta
	if update_timer > update_frequency:
		update_timer -= update_frequency
		update_progress()


func update_progress():
	var old_progress_offset = progress_offset
	
	var race_path : RacePath3D = RaceManager.race_path
	var kart_pos = kart.global_position
	progress_offset = race_path.get_closest_offset(race_path.to_local(kart_pos))
	
	# detect lap change...
	_detect_lap_changes(old_progress_offset, progress_offset)


func _detect_lap_changes(old_offset, new_offset):
	# TODO: consider need for finish line bounding boxes.
	var finishline_threshold := 5.0
	var skip_threshold := 0.3
	var length = RaceManager.race_path.get_offset_length()
	
	# went reverse, invalidates lap
	if new_offset > length-finishline_threshold and old_offset < finishline_threshold:
		invalid_lap = true
		return
		
	# moved up a lap
	if old_offset > length-finishline_threshold and new_offset < finishline_threshold:
		if not invalid_lap:
			current_lap += 1
			lap_changed.emit(current_lap)
		else:
			invalid_lap = false # no lap change
		return
		
	# sudden skip of 30% of the track forwards, invalidates lap
	# inspired by mario kart double dash
	if old_offset < new_offset and old_offset + length*skip_threshold < new_offset:
		invalid_lap = true
		return


