extends PowerUp

@export var accel := 20.0
@export var max_speed := 30.0
@export var max_ricochets := 5
var ricochet_counter = 0

func _ready():
	super()
	_debug_start_random_direction()

func _debug_start_random_direction():
	#velocity = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized() * max_speed/2
	velocity = Vector3(-1, 0, 1)

## special movement: don't bounce on floor, but ricochet horizontally
func do_movement(delta) -> KinematicCollision3D:
	velocity *= 0.98 # drag
	
	if get_horizontal_velocity().length_squared() < max_speed * max_speed:
		velocity += get_heading_direction() * accel * delta
	
	move_and_slide()
	var collision_info = move_and_collide(velocity*delta, true) #test only!
	if collision_info:
		if absf(collision_info.get_normal().y) < 0.5: # vertical limit for ricochet is 45°
			if ricochet_counter < max_ricochets:
				ricochet_counter += 1
				#print("shell ricochet!")
				velocity = velocity.bounce(collision_info.get_normal())
				velocity *= 0.6
			else:
				queue_free() # put destroy func with animations here
	return collision_info


func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)

func get_heading_direction() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z).normalized()

func on_touched(kart_balance_component: KartBalanceComponent):
	kart_balance_component.balance = 0 #-= 50
	
	var car = kart_balance_component.car
	car.linear_velocity += Vector3.UP * 4
	
	queue_free()  # put destroy func with animations here
