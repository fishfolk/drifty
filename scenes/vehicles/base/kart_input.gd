extends Node
class_name KartInput
## Base input handler for controlling karts.
## [br]
## In the future, this class spans subclasses for AI and player controlled karts;
## For now, it takes input from the global Input system.

## This variable can turn on or off the handler
@export var enabled := true

var throttle: float = 0.0
var brakes: float = 0.0
var drift: float = 0.0 # or handbrake

## ranging from -1.0 for left to 1.0 for right.
var steering: float = 0.0 



## Public function to gather input. It's best called every physics frame.
func query_input() -> void:
	if not enabled:
		throttle = 0
		brakes = 0
		drift = 0
		steering = 0
		
		return
	_update_input()


## Private function. This is the function to override in subclasses.
func _update_input() -> void:
	throttle = Input.get_action_strength("ui_up")
	brakes = Input.get_action_strength("ui_down")
	drift = Input.get_action_strength("drift")
	steering = Input.get_axis("ui_left", "ui_right")
