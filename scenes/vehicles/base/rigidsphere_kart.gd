extends Node3D

@export var input: KartInput
@export var ball_position_offset: Vector3

@onready var model = $Model
@onready var sphere = $Sphere

var ENGINE_ACCEL = 30

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#model.transform.origin = sphere.transform.origin + ball_position_offset
	global_position = sphere.global_position + ball_position_offset
	sphere.transform.origin = Vector3.ZERO - ball_position_offset
	
	
	if input:
		input.query_input()
		_update_drive(delta)
		_update_steer(delta)


func _update_drive(delta):
	var engine_force = ENGINE_ACCEL * sphere.mass * input.throttle
	sphere.apply_central_force(-model.global_basis.z * engine_force)


func _update_steer(delta):
	var steer = 2 * input.steering * delta
	rotate(-global_basis.y, steer)
	
	pass
