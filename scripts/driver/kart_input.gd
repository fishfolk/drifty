extends Node3D
class_name KartInput
## Base input handler for controlling karts.
## [br]
## In the future, this class spans subclasses for AI and player controlled karts;
## For now, it takes input from the global Input system.

## This variable can turn on or off the handler
@export var enabled := true

@onready var car: SimpleRaycastCar = get_parent()

var throttle: float = 0.0
var brakes: float = 0.0
var drift: float = 0.0 # or handbrake
var item: float = 0.0

## ranging from -1.0 for left to 1.0 for right.
var steering: float = 0.0 

var melee_left: bool = false
var melee_right: bool = false

var emote: bool = false

## Public function to gather input. It's best called every physics frame by the parent.
func query_input(delta) -> void:
	if not enabled:
		throttle = 0
		brakes = 0
		steering = 0
		drift = 0
		item = 0
		melee_left = false
		melee_right = false
		emote = false
		
		return
	_update_input(delta)


## Private function. This is the function to override in subclasses.
func _update_input(delta) -> void:
	return

