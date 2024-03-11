class_name PowerUp
extends CharacterBody3D
## PowerUp

@export var DRAG_COEFF: float = 0.98

## You need to create an Area3D named "ContactArea" as a child of this node.
var contact_area: Area3D
var floor_raycast: RayCast3D

## Use this for items that shouldn't damage their parent (homing, mine)
var parent_kart 

func _ready():
	contact_area = $ContactArea
	if contact_area == null:
		printerr("ERROR: Couldn't find contact area for powerup: ", self)
	
	floor_raycast = $FloorRayCast3D
	if floor_raycast == null:
		printerr("ERROR: Couldn't find floor raycast for powerup: ", self)
	else:
		floor_raycast.set_collision_mask_value(1, true) # ground is layer 1

func _physics_process(delta):
	if not check_is_on_floor():
		velocity += Vector3.DOWN * 10 * delta;
	do_movement(delta)
	

func check_is_on_floor() -> bool:
	floor_raycast.force_raycast_update()
	return floor_raycast.is_colliding()

## standard movement: bounce on walls and floor and lose velocity over time.
func do_movement(delta) -> KinematicCollision3D:
	velocity *= 0.98 # drag
	var collision_info = move_and_collide(velocity*delta)
	if collision_info:
		if velocity.length() > 5: # bounce                      # restitution
			velocity = velocity.bounce(collision_info.get_normal()) * 0.6
		elif check_is_on_floor():
			velocity.y = 0
	return collision_info


## virtual.
func on_touched(kart_balance_component: KartBalanceComponent) -> void:
	pass
