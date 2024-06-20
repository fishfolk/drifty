class_name SimpleRaycastCar
extends RigidBody3D

signal input_node_changed(new_input_node:KartInput)
signal area_entered(area:Area3D)

@export_group("Stats")
@export var engine_power : float = 7
@export var top_speed : float = 27
@export var handling_factor : float = 0.3 #how fast the car turns (0.25 - 0.4)
@export var grip_factor : float = 0.7 #how well it sticks to the track for turns (0.3 - 1)
@export var drift_grip_factor : float = 0.7 #how well it sticks to the track for drift turns (0.3 - 1)
@export var drift_speed : float = 2#how fast the car goes sideways, 0.7 - 4
@export var boost_power : float = 500

@export_group("Node References")

@export var input : KartInput

## Drag all your wheels here.
@export var wheels : Array[SimpleWheel] = []

var can_input : bool = true

var input_throttle : float = 0
var input_brakes : float = 0
var input_steer : float = 0
var input_drift : float = 0
var input_drift_just_pressed : bool = false
var input_item : float = 0
var input_item_just_pressed : bool = false

var engine_throttle : float = 0.0
var braking_force : float = 0.0
var steer_axis : float = 0.0

var is_drifting := false
var drift_dir : float = 0.0 #1.0 or -1.0
var drift_angle : float = 0
var drift_charge : float = 0

var boost_extra_speed : float = 0 # to add to your top speed
var boost_timer : float = 0

var is_grounded := false
var spun_out_timer: float = 0.0 #


func _ready():
	if Engine.is_editor_hint(): 
		return
	
	for wheel in wheels:
		wheel.car = self


func _process(_delta):
	if Engine.is_editor_hint(): return


func _physics_process(delta):
	if spun_out_timer > 0: spun_out_timer -= delta
	
	if boost_timer > 0: boost_timer -= delta
	else: #reset_boost()
		boost_extra_speed = lerpf(boost_extra_speed, 0, delta*1)
	
	
	## update if car is grounded or not
	#only not grounded if all 4 wheels aren't grounded
	#only grounded if all 4 wheels are grounded
	var wheel_not_grounded_count = 0
	for wheel in wheels:
		if wheel.deform == 0: wheel_not_grounded_count += 1
	
	if wheel_not_grounded_count == wheels.size():
		is_grounded = false
	if wheel_not_grounded_count == 0:
		is_grounded = true
	
	
	if not is_grounded:
		_align_up_while_airborne(delta)
	else:
		_align_up_with_floor(delta)
	
	
	_update_input(delta)
	if spun_out_timer > 0: 
		input_throttle = 0
		input_brakes = 0
		var falling_velocity = Vector3(0,linear_velocity.y,0)
		linear_velocity = (linear_velocity - falling_velocity) * 0.98 + falling_velocity
	
	var speed = get_speed()
	## interpret inputs
	engine_throttle = input_throttle * engine_power * mass
	if speed > get_top_speed(): engine_throttle = 0.0
	if speed < 0.1 : engine_throttle *= 2
	if boost_timer > 0: engine_throttle *= 2
	
	if linear_velocity.length_squared() < 0.2:
		angular_damp = 100
	else:
		angular_damp = 10
	
	braking_force = input_brakes * engine_power*1.5 * mass
	if speed < -8: braking_force = 0.0
	
	
	var temp_steer = input_steer
	#temp_steer *= clampf(abs(speed)/5, -1, 1) #TODO: improve turning while stopped
	steer_axis = lerp(steer_axis, temp_steer, delta*5)
	if abs(speed) < 1: steer_axis = 0.0
	
	# complex brakes
	#var force_pos = global_transform.basis.z*0.2 -global_transform.basis.y*0.1
	#if input_brakes > 0:
	#	apply_force(global_transform.basis.z * mass * 10 * input_brakes, force_pos)
	
	## how mario kart drift works
	## press the button while -on land- to jump.
	## if you -land- while holding the button, start the drift
	## you can start the drift while landing from a ramp as well
	## if you -land- without holding the button, nothing happens.
	## release the button or the accelerator, and the drift ends
	## drift charges with 1.time 2.angle. speed doesn't change charge.
	## there's a minimum speed for drift; if you go lower than that speed,
	## end the drift AND lose the charge.
	
	## how nfs unbound grip boost works
	## detect if the steering is held over 0 (or 0.1, 0.3) in a direction
	## detect if speed is not significantly lost over this time (slide drag or bad cornering)
	## also detect if the car doesn't go sideways too much
	## if so, reward more charge with corner speed and time held and total corner angle
	## if you change directions, you lose the charge, if you drift or slide you lose the charge.
	
	
	
	#jump
	if input_drift_just_pressed and is_grounded:
		apply_central_force(global_transform.basis.y * mass * 50)
		pass
	
	## drift steer
	drift_angle = 0
	
	if (not is_drifting) and input_drift != 0.0 and input_steer != 0 and speed > 5.0:
		is_drifting = true
		drift_dir = sign(input_steer) * 0.1
	
	#if is_drifting and not is_grounded: #lose drift, dont lose charge
		#is_drifting = false
		#drift_dir = 0.0
	
	#if is_drifting and (input_throttle == 0.0 or speed < 0.01): #lose drift, lose charge
		#is_drifting = false
		#drift_dir = 0.0
		#drift_charge = 0.0
	
	if is_drifting and input_drift == 0.0: #lose drift, release charge
		is_drifting = false
		drift_dir = 0.0
		
		release_drift_charge(delta)
	
	
	if is_drifting:
		drift_dir = lerp(drift_dir, sign(drift_dir), delta * speed/5.0)
		var tightening_factor = 0.4
		global_rotate(global_transform.basis.y, -drift_dir * PI * deg_to_rad(handling_factor) * tightening_factor * delta)
		var ground_velocity = linear_velocity - linear_velocity*global_transform.basis.y
		var drift_slip = ground_velocity.normalized().dot(-global_transform.basis.z)
		drift_angle = acos(clamp(drift_slip, -1, 1))
		add_drift_charge(delta * min(1.1-drift_slip, 0.35) * 6)
	else:
		add_drift_charge(-delta * 2)
	#add_drift_charge(delta * 2)
	
	
	
	## simple steering
	var b = 1.2 if boost_timer > 0 else 1.0 # extra steering from boost
	var d = 0.8 if is_drifting else 1.0 # steer less when drifting
	var r = -2 if get_speed() < 0 else 1.0 # better steering on reverse
	global_rotate(global_transform.basis.y, -steer_axis*b*d*r * deg_to_rad(handling_factor) * delta)
	if not is_drifting and is_grounded:
		linear_velocity *= (1 - 0.01*delta*abs(steer_axis)*deg_to_rad(handling_factor))
	#apply_torque(global_transform.basis.y * -steer_axis * mass)
	
	## update wheels
	for child in get_children():
		if not child is SimpleWheel: continue
		var wheel := child as SimpleWheel
		
		wheel._update_physics(delta)


# TODO: tie with custom input node to detect both player, AI and set inputs.
func _update_input(delta):
	if input and can_input:
		input.query_input(delta)
		
		input_throttle = input.throttle
		input_brakes = input.brakes
		input_steer = input.steering
		#Input.get_action_strength("drift")
		input_drift_just_pressed = input_drift == 0 and input.drift != 0 #Input.is_action_just_pressed("drift")
		input_drift = input.drift
		#if input_drift_just_pressed:
		#	print_debug("jump!")
		input_item_just_pressed = input_item == 0 and input.item != 0 #Input.is_action_just_pressed("drift")
		input_item = input.item
		#if input_item_just_pressed:
		#	print_debug("hit!")
		#print(input.brakes, input_brakes)
		#if Input.is_action_just_pressed("pause"):
		#	Pause.pause()
	else:
		input_throttle = 0
		input_brakes = 0
		input_steer = 0
		input_drift = 0
		input_drift_just_pressed = false
		input_item = 0
		input_item_just_pressed = false



func _align_up_while_airborne(delta):
	rotation_degrees.x = lerp(rotation_degrees.x, 0.0, delta*2)
	rotation_degrees.z = lerp(rotation_degrees.z, 0.0, delta*2)
	#var new_basis : Basis = Basis
	pass

func _align_up_with_floor(delta):
	var floor_normal = get_floor_normal()
	if floor_normal != Vector3.ZERO:
		var new_up = lerp(-global_basis.y, floor_normal, delta*2)
		basis.looking_at(-global_basis.z, new_up)
	else:
		_align_up_while_airborne(delta)
		#global_basis = _align_up(global_basis, floor_normal)

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

func boost(duration:float, speed_increase:float = 7) -> void:
	boost_extra_speed = max(boost_extra_speed, speed_increase)
	boost_timer = max(boost_timer, duration)
	# add extra impulse for fun :)
	apply_central_impulse(-global_transform.basis.z * mass * 10)

#func reset_boost():
#	boost_extra_speed = 0

func add_drift_charge(amount):
	drift_charge += amount
	drift_charge = clamp(drift_charge, 0, 3.5)

func release_drift_charge(dt):
	#print("a")
	#if drift_charge >= 1: 
	#	var final_power = boost_power * (1.5+floor(drift_charge)*1) / 100.0
	#	apply_central_force(-global_transform.basis.z * mass * final_power / dt)
	#drift_charge = 0
	if drift_charge >= 1: 
		var charge_level = floor(drift_charge)
		var extra_speed = 0 + 3 + charge_level
		var duration = 1 + 0.5 * (charge_level-1)
		boost(duration, extra_speed)
	drift_charge = 0

func get_floor_normal() -> Vector3:
	var wheel_normal_sum = Vector3.ZERO
	var wheel_contact_count : float = 0
	for wheel : SimpleWheel in wheels:
		if wheel.is_colliding():
			wheel_contact_count += 1
			var local_normal_sum = Vector3.ZERO
			for i in range(wheel.get_collision_count()):
				local_normal_sum += wheel.get_collision_normal(i)
			local_normal_sum /= wheel.get_collision_count()
			wheel_normal_sum += local_normal_sum
	if wheel_contact_count == 0:
		return Vector3.ZERO
	return wheel_normal_sum / wheel_contact_count


func get_speed() -> float :
	return linear_velocity.dot(-global_transform.basis.z)

func get_top_speed() -> float:
	return top_speed + boost_extra_speed

## As the formula for steering used is simply "rotate x degrees every second", ignoring drag,
## the turn radius for the vehicle can be derived from the turning speed and the current velocity
## circumference = 2PI*R = get_speed() / (deg_to_rad(handling_factor)/2*PI)
## => R = get_speed() / deg_to_rad(handling_factor)
func get_turning_radius() -> float:
	return get_speed() / deg_to_rad(handling_factor)

func spin_out():
	spun_out_timer = 2.0
	#play animation from anim tree
	pass

func set_input_node(input_node:KartInput):
	remove_child(input)
	input = input_node
	if input: #not input is null
		add_child(input, true)
		input_node_changed.emit(input_node)


func _on_contact_area_area_entered(area):
	area_entered.emit(area)
