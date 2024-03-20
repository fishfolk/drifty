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



## Public function to gather input. It's best called every physics frame.
func query_input(delta) -> void:
	if not enabled:
		throttle = 0
		brakes = 0
		steering = 0
		drift = 0
		item = 0
		
		return
	_update_input(delta)


## Private function. This is the function to override in subclasses.
func _update_input(delta) -> void:
	throttle = Input.get_action_strength("throttle")
	brakes = Input.get_action_strength("brakes")
	steering = Input.get_axis("ui_left", "ui_right")
	drift = Input.get_action_strength("drift")
	item = Input.get_action_strength("item")
	#print_debug(car.get_speed())
	#print_debug("turning diameter: ", 2*car.get_turning_radius())
