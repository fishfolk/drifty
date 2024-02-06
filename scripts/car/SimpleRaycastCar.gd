class_name SimpleRaycastCar
extends RigidBody3D

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
## Drag all your wheels here.
@export var wheels : Array[SimpleWheel] = []

var can_input : bool = true

var input_throttle : float = 0
var input_brakes : float = 0
var input_steer : float = 0
var input_drift : float = 0
var input_drift_just_pressed : bool = false

var engine_throttle : float = 0.0
var braking_force : float = 0.0
var steer_axis : float = 0.0

var is_drifting := false
var drift_dir : float = 0.0 #1.0 or -1.0
var drift_angle : float = 0
var drift_charge : float = 0

var is_grounded := false

func _ready():
	if Engine.is_editor_hint(): 
		return
	
	for wheel in wheels:
		wheel.car = self




func _process(delta):
	if Engine.is_editor_hint(): return



func _physics_process(delta):
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
	
	
	_update_input()
	
	var speed = get_speed()
	## interpret inputs
	engine_throttle = input_throttle * engine_power * mass
	if speed > top_speed: engine_throttle = 0.0
	if speed < 0.1 : engine_throttle *= 2
	
	if linear_velocity.length_squared() < 0.2:
		angular_damp = 100
	else:
		angular_damp = 10
	
	braking_force = input_brakes * engine_power*1.5 * mass
	if speed < -8: braking_force = 0.0
	
	var temp_steer = input_steer
	temp_steer *= clampf(abs(speed)/5, -1, 1) #TODO: improve turning while stopped
	steer_axis = lerp(steer_axis, temp_steer, delta*5)
	if abs(speed) < 2: steer_axis = 0.0
	
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
		#apply_central_force(global_transform.basis.y * mass * 500)
		pass
	
	
	## drift steer
	drift_angle = 0
	
	if (not is_drifting) and input_drift != 0.0 and input_steer != 0 and speed > 15.0:
		is_drifting = true
		drift_dir = sign(input_steer) * 0.1
	
	if is_drifting and not is_grounded: #lose drift, dont lose charge
		is_drifting = false
		drift_dir = 0.0
	
	if is_drifting and (input_throttle == 0.0 or speed < 0.01): #lose drift, lose charge
		is_drifting = false
		drift_dir = 0.0
		drift_charge = 0.0
	
	if is_drifting and input_drift == 0.0: #lose drift, release charge
		is_drifting = false
		drift_dir = 0.0
		
		release_drift_charge(delta)
	
	
	if is_drifting:
		drift_dir = lerp(drift_dir, sign(drift_dir), delta * speed/5.0)
		
		global_rotate(global_transform.basis.y, -drift_dir * PI * handling_factor * 1.2 * delta)
		var ground_velocity = linear_velocity - linear_velocity*global_transform.basis.y
		var drift_slip = ground_velocity.normalized().dot(-global_transform.basis.z)
		drift_angle = acos(clamp(drift_slip, -1, 1))
		add_drift_charge(delta * min(1.1-drift_slip, 0.35) * 6)
	else:
		add_drift_charge(-delta * 2)
	#add_drift_charge(delta * 2)
	
	
	
	## simple steering
	var d = 0.8 if is_drifting else 1 #steer less when drifting
	var r = -2 if get_speed() < 0 else 1
	global_rotate(global_transform.basis.y, -steer_axis*d*r * PI * handling_factor * delta)
	if not is_drifting:
		linear_velocity *= (1 - 0.1*delta*abs(steer_axis)*handling_factor)
	#apply_torque(global_transform.basis.y * -steer_axis * mass)
	
	
	## update wheels
	for child in get_children():
		if not child is SimpleWheel: continue
		var wheel : SimpleWheel = child
		
		wheel._update_physics(delta)


# TODO: tie with custom input node to detect both player, AI and set inputs.
func _update_input():
	if can_input:
		input_throttle = Input.get_action_strength("throttle")
		input_brakes = Input.get_action_strength("brake")
		input_steer = Input.get_axis("steer_left", "steer_right")
		input_drift = Input.get_action_strength("drift")
		input_drift_just_pressed = Input.is_action_just_pressed("drift")
		
		#if Input.is_action_just_pressed("pause"):
		#	Pause.pause()
	else:
		input_throttle = 0
		input_brakes = 0
		input_steer = 0
		input_drift = 0
		input_drift_just_pressed = false



func _align_up_while_airborne(delta):
	rotation_degrees.x = lerp(rotation_degrees.x, 0.0, delta*2)
	rotation_degrees.z = lerp(rotation_degrees.z, 0.0, delta*2)
	#var new_basis : Basis = Basis
	pass


func add_drift_charge(amount):
	drift_charge += amount
	drift_charge = clamp(drift_charge, 0, 3.5)

func release_drift_charge(dt):
	#print("a")
	if drift_charge >= 1: 
		var final_power = boost_power * (1.5+floor(drift_charge)*1) / 100.0
		apply_central_force(-global_transform.basis.z * mass * final_power / dt)
	drift_charge = 0


func get_speed() -> float :
	return linear_velocity.dot(-global_transform.basis.z)


func _on_contact_area_area_entered(area):
	area_entered.emit(area)
