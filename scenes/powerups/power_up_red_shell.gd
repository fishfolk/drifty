extends PowerUp

@export var accel := 90.0
@export var max_speed := 30.0

#unused
#@export var max_ricochets := 0
#var ricochet_counter = 0
#/unused

var item_path : Path3D = null
var target : Node3D = null


func _ready():
	super()
	_debug_start_random_direction()
	
	# find track to home onto
	await get_tree().create_timer(0.5, false, true)
	if RaceManager.item_path:
		item_path = RaceManager.item_path


func _debug_start_random_direction():
	#velocity = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized() * max_speed/2
	velocity = Vector3(-1, 0, 1)


## special movement: don't bounce on floor, but ricochet horizontally
func do_movement(delta) -> KinematicCollision3D:
	velocity = velocity.move_toward(Vector3.ZERO, 60*delta)
	#velocity *= 0.9 # drag
	# length squared to decrease processor load?
	# heading direction is probably more expensive anyway...
	if get_horizontal_velocity().length_squared() < max_speed * max_speed:
		velocity += get_heading_direction() * accel * delta
	
	move_and_slide()
	
	#print(velocity.length())
	
	var collision_info = move_and_collide(velocity*delta, true) #test only!
	if collision_info:
		if absf(collision_info.get_normal().y) < 0.5: # vertical limit for ricochet is 45°
			queue_free() # put destroy func with animations here
	return collision_info


func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)


func get_heading_direction() -> Vector3:
	if not target: # if no other driver was found
		if not item_path:
			return get_horizontal_velocity().normalized()
		var closest_offset = item_path.curve.get_closest_offset(item_path.to_local(self.global_position))
		closest_offset += 4 # always look forward 2 meters
		var target_position: Vector3 = item_path.curve.sample_baked(closest_offset, true)
		var target_direction = (target_position - global_position)
		target_direction.y = 0
		target_direction = target_direction.normalized()
		return target_direction
	else: # if a driver has entered the detection radius.
		#TODO
		var target_direction = (target.global_position - global_position)
		target_direction.y = 0
		target_direction = target_direction.normalized()
		return target_direction


func on_touched(kart_balance_component: KartBalanceComponent):
	kart_balance_component.balance = 0 #-= 50
	
	var car = kart_balance_component.car
	car.linear_velocity += Vector3.UP * 4
	
	queue_free()  # put destroy func with animations here


func _on_kart_detection_area_body_entered(body):
	print("body entered!")
	if target: return
	if body is SimpleRaycastCar:
		if body != parent_kart:
			target = body # Replace with function body.
			print("target acquired!")
