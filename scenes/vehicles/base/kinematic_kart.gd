extends CharacterBody3D


@export var input: KartInput = null


@export var FRICTION_CURVE: Curve

#const SPEED = 5.0
const MAX_SPEED = 10.0 # meters per second
const ACCEL = 4.0 # (meters per second) per second 

const STEER_SPEED = 4.0 # radians per second

const DECELERATION = 10.0 # meters per second

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")




## Returns the speed along strictly the forward / backward axis of the vehicle.
## Sideways movement and falling movement is ignored.
func get_speed() -> float:
	return velocity.dot(-global_transform.basis.z)

func get_ground_velocity() -> Vector3:
	return velocity - velocity * global_transform.basis.y


func set_input(new_input: KartInput) -> void:
	if input:
		remove_child(input)
		input.queue_free()
	
	input = new_input
	add_child(new_input)





func _physics_process(delta):
	# Natural deceleration
	
	# 1 if moving forward, -1 if moving backward, 0 is completely sideways.
	var sideways_factor = 1 - abs(velocity.normalized().dot(-global_transform.basis.z))
	var friction_multiplier = FRICTION_CURVE.sample(sideways_factor)
	#print(sideways_factor)
	print(30*friction_multiplier*delta)
	#velocity.move_toward(Vector3.ZERO, 300 * friction_multiplier * delta)
	var friction_power = DECELERATION * friction_multiplier * delta
	#velocity -= global_transform.basis.x * sign(get_sideways_velocity()) * friction_power
	var ground_velocity = get_ground_velocity()
	var new_ground_velocity = ground_velocity.move_toward(-get_speed()*global_transform.basis.y, 1*delta)
	velocity = velocity * global_transform.basis.y + new_ground_velocity
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#print(velocity.y)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if input:
		input.query_input()
		_update_drive(delta)
		_update_steer(delta)
	
	move_and_slide()


func _update_drive(delta) -> void:
	var engine_accel : float = 0
	if get_speed() < MAX_SPEED:
		engine_accel = input.throttle * ACCEL * delta
	velocity += -global_transform.basis.z * engine_accel


func _update_steer(delta) -> void:
	var steer = input.steering * STEER_SPEED * delta
	global_rotate(-global_transform.basis.y, steer)
	var rotated_velocity = velocity.rotated(-global_transform.basis.y, steer)

