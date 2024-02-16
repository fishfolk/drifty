extends RigidBody3D

@export var input: KartInput

@export var wheels: Array[RayCast3D]

var ENGINE_ACCEL = 20 # meters per second squared
var MAX_SPEED = 20


var is_on_floor: bool = false


func check_is_on_floor() -> bool:
	var all_wheels_colliding = true
	for wheel : RayCast3D in wheels:
		if not wheel.is_colliding():
			all_wheels_colliding = false
			break
	return all_wheels_colliding

func get_floor_normal() -> Vector3:
	var wheel_normal_sum = Vector3.ZERO
	var wheel_contact_count : float = 0
	for wheel : RayCast3D in wheels:
		if wheel.is_colliding():
			wheel_contact_count += 1
			wheel_normal_sum += wheel.get_collision_normal()
	if wheel_contact_count == 0:
		return Vector3.ZERO
	return wheel_normal_sum / wheel_contact_count

func get_speed() -> float:
	return self.linear_velocity.dot(-self.global_transform.basis.z)





# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	is_on_floor = check_is_on_floor()
	_align_body_with_ground(delta)
	
	#friction
	if is_on_floor:
		linear_velocity *= 0.98
	
	#gravity
	if is_on_floor:
		gravity_scale = 0.5
	else:
		gravity_scale = 1.0
	
	if input:
		input.query_input(delta)
		if is_on_floor:
			_update_steer(delta)
			_update_drive(delta)


func _update_steer(delta) -> void:
	var steer_amount = 4 * delta * input.steering
	rotate(-global_basis.y, steer_amount)


func _update_drive(delta) -> void:
	var engine_force = ENGINE_ACCEL * mass * (input.throttle - input.brakes)
	apply_central_force(-global_transform.basis.z * engine_force)


func _align_body_with_ground(delta):
	#rotation.z = 0
	#angular_velocity -= angular_velocity * global_basis.z
	if is_on_floor:
		var floor_normal = get_floor_normal()
		if floor_normal != Vector3.ZERO:
			global_basis = _align_up(global_basis, floor_normal)
	else:
		rotation_degrees.x = lerp(rotation_degrees.x, 0.0, delta*5)
		rotation_degrees.z = lerp(rotation_degrees.z, 0.0, delta*5)


func _align_up(node_basis, normal):
	var result = Basis()
	var scale = node_basis.get_scale() # Only if your node might have a scale other than (1,1,1)
	
	result.x = normal.cross(node_basis.z)
	result.y = normal
	result.z = node_basis.x.cross(normal)
	
	result = result.orthonormalized()
	result.x *= scale.x 
	result.y *= scale.y 
	result.z *= scale.z 
	
	return result
