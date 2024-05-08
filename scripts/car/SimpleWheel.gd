@tool
class_name SimpleWheel
extends ShapeCast3D

const ROAD_MATERIALS := preload("res://scripts/car/RoadMaterialGroups.tres")

#@export var simple_steering : bool = true

## cosmetic: is the wheel used for steering?
@export var is_steer : bool = false

@export var wheel_radius : float = 0.2 :
	get:
		return wheel_radius
	set(new_value):
		new_value = max(0.001, new_value)
		wheel_radius = new_value
		_update_shape()

@export var spring_length : float = 0.3 :
	get:
		return spring_length
	set(new_value):
		new_value = max(0.001, new_value)
		spring_length = new_value
		target_position = Vector3(0,-1,0) * new_value
		_update_children_positions()


@export var spring_stiffness : float = 10
@export var damping : float = 1
#@export var rebound_damping : float = 0.7

var car : SimpleRaycastCar
var contact_material : RoadMaterial = null

var deform : float = 0 # 0 to 1
var last_deform : float = 0 # 0 to 1


@export var smoke_particle : GPUParticles3D = null
@export var wheel_mesh : Node3D = null

# Called when the node is instantiated, before it enters the scene tree.
func _init():
	wheel_radius = wheel_radius # update shape
	spring_length = spring_length # update children


func _ready():
	pass # Replace with function body.


func get_deform() -> float:
	return 1 - get_closest_collision_unsafe_fraction()



func _process(delta):
	_update_children_positions()


# to be called from the parent Car node
func _update_physics(dt):
	#var car : SimpleRaycastCar = get_parent()
	_update_suspension(dt)
	_update_movement(dt)
	_update_drag(dt)
	# finish up
	_update_children_positions()
	_update_particles(dt)
	_update_mesh_rotation(dt)


func _update_suspension(dt):
	deform = get_deform()
	
	if not is_colliding():
		last_deform = 0
		contact_material = null
		return
	
	if deform == 0: #colliding, yet deform is 0
		if _get_collision_result() != []: #bugged collisions
			deform = 1 #continue
		else: # (not is_colliding())
			last_deform = 0
			contact_material = null
			return
	
	#### material ####
	var contact_obj := get_collider(0) #only test the first collision.
	#print_debug(contact_obj)
	var surface_name := ""
	if contact_obj.get_groups().size() > 0:
		surface_name = contact_obj.get_groups()[0] #only test the first group.
	#TODO: test all groups, find the one with most grip
	contact_material = ROAD_MATERIALS.get_material(surface_name)
	#print_debug(contact_material.group_name)
	
	#### springs ####
	var spring_force = spring_stiffness * deform
	
	var delta_deform = (last_deform - deform)
	var up_or_down = sign(delta_deform)
	var damp_force = damping * delta_deform/dt# * 120*120 * dt
	
	#var damp_clamp = car.mass / 100
	#damp_force = clampf(damp_force, -damp_clamp, damp_clamp)
	#damp_force = 0
	#if up_or_down == 1:
	#	damp_force *= rebound_damping
	#elif up_or_down == -1:
	#	damp_force *= compress_damping
	
	var final_force = car.mass * (spring_force - damp_force) # force is length-independent, mass-independent
	var force_pos = global_position - car.global_position
	force_pos -= (1-deform)*transform.basis.y*spring_length
	
	#var force_clamp = car.mass * dt * 1000
	#final_force = clampf(final_force, -force_clamp, force_clamp)
	
	car.apply_force(global_transform.basis.y * final_force, force_pos)
	
	#### bumpiness ####
	var bumpiness := contact_material.bumpiness
	if bumpiness > 0:
		var terrain_push = car.mass * min(20, car.linear_velocity.length()/2.0)
		#terrain_push *= min(0, randf_range(-1,1)) * bumpiness
		terrain_push *= max(-0.5, randf_range(-1,1)) * bumpiness
		car.apply_force(global_transform.basis.y * terrain_push, force_pos)
	
	last_deform = deform


func _update_movement(dt):
	#if deform == 0: return # lets do air movement.
	
	var factor = 1.0 / car.wheels.size()
	var forward = -car.global_transform.basis.z
	if car.is_drifting:
		forward = (forward - car.global_transform.basis.x * car.drift_dir * 2).normalized()
		forward *= car.drift_speed
		
		#forward = forward - car.global_transform.basis.x * car.drift_dir * car.drift_speed
		#forward *= 0.5
	
	var throttle_force = forward * car.engine_throttle * factor
	# if in air
	if deform == 0:
		throttle_force *= 0.5
	
	car.apply_central_force(throttle_force)
	
	##braking
	#var braking_drag = 1 * car.input_brakes
	#car.linear_velocity *= 1.0 - dt * braking_drag * factor
	forward = -car.global_transform.basis.z
	#print("throttle: ", car.engine_throttle)
	var braking_force = -forward * car.braking_force * factor
	# if in air
	if deform == 0:
		braking_force *= 0.5
	car.apply_central_force(braking_force)


func _update_drag(dt):
	var factor = 1.0 / car.wheels.size()
	
	#### standard linear drag ####
	
	if deform == 0 or contact_material == null: #air
		#var air_drag = 0
		#car.linear_velocity *= 1.0 - dt * air_drag * factor
		#print("in air")
		return #no slip drag
	#print("not in air")
	#not air
	var drag = contact_material.drag
	#car.linear_velocity *= 1.0 - dt * drag * factor
	
	#### steering drag ####
	var slide_drag = contact_material.slide_drag
	var sideways_velocity = car.linear_velocity.dot(car.global_transform.basis.x)
	if car.is_drifting:
		slide_drag *= 0.6
	var grip_factor = car.drift_grip_factor if car.is_drifting else car.grip_factor
	var sideways_counterforce = car.mass * sideways_velocity * slide_drag * grip_factor
	car.apply_central_force(-car.global_transform.basis.x  * sideways_counterforce * factor)
	
	#### stopping drag ####
	var abs_speed = abs(car.get_speed())
	if abs_speed < 5.0 and not (car.engine_throttle != 0.0 or car.braking_force != 0.0):
		var stopping_drag = max(0, 5 - abs_speed)
		car.linear_velocity *= 1.0 - dt * stopping_drag * factor
		
		sideways_velocity = car.linear_velocity * global_transform.basis.x
		if sideways_velocity.length() < 0.5:
			car.linear_velocity -= global_transform.basis.x*sideways_velocity


func _update_particles(dt) -> void:
	if smoke_particle:
		if deform == 0:
			smoke_particle.emitting = false
		else:
			var speed = abs(car.get_speed())
			var plane_velocity = car.linear_velocity - car.linear_velocity.project(global_transform.basis.y)
			var slip_angle = abs(global_transform.basis.x.dot(plane_velocity.normalized()))
			#print(slip_angle)
			if slip_angle < 0.1 or speed < 1:
				smoke_particle.emitting = false
			else:
				smoke_particle.emitting = true
				smoke_particle.process_material.color.a = min(1, 0.5*slip_angle + 0.0001*speed)
				
				smoke_particle.process_material.initial_velocity_min = 0.95 * speed
				smoke_particle.process_material.initial_velocity_max = 1.05 * speed
				smoke_particle.process_material.direction += 0.5 * dt * car.linear_velocity * global_transform.basis
				#smoke_particle.process_material.direction += Vector3(0,0,1) * 0.3
				smoke_particle.process_material.direction = smoke_particle.process_material.direction.normalized()


func _update_mesh_rotation(dt) -> void:
	if not wheel_mesh: return
	var speed = car.get_speed()
	
	# as the wheel points downwards, rotations are swapped
	# x for rolling axis, y for steering
	
	var rotation_vector = Vector3.ZERO
	
	
	#rolling
	var roll_angle = - speed * dt / (PI * wheel_radius)
	wheel_mesh.rotate_x(roll_angle)
	

	#steer
	if is_steer:
		var last_angle = self.rotation.y
		var steer_angle = -car.steer_axis * PI/10.0
		var steer_speed = 20
		if car.is_drifting: 
			steer_angle *= 2
			steer_speed /= 2
		
		steer_angle = lerp_angle(last_angle, steer_angle, dt*steer_speed)
		
		self.rotate_y(-self.rotation.y)
		self.rotate_y(steer_angle)








func _update_children_positions() -> void:
	for child in self.get_children():
		if not (child is Node3D): continue
		if (child.name.begins_with("@")): continue #debug mesh
		
		var child3d : Node3D = child as Node3D
		child3d.position = (1 - get_deform()) * self.target_position






func _update_shape() -> void:
	if not (shape is SphereShape3D):
		shape = SphereShape3D.new()
	
	shape.radius = wheel_radius
	shape.margin = 0.0001
