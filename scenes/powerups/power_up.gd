class_name PowerUp
extends CharacterBody3D
## PowerUp

@export var DRAG_COEFF: float = 0.98

## You need to create an Area3D named "ContactArea" as a child of this node.
var contact_area: Area3D

func _ready():
	contact_area = get_node_or_null("ContactArea")
	if contact_area == null:
		printerr("ERROR: Couldn't find contact area for powerup: ", self)
	else:
		pass

func _physics_process(delta):
	velocity += Vector3.DOWN * 10 * delta;
	do_movement(delta)

## standard movement: bounce on walls and floor and lose velocity over time.
func do_movement(delta):
	velocity *= 0.98 # drag
	var collision_info = move_and_collide(velocity*delta)
	if collision_info:
		if velocity.length() > 5: # bounce
			velocity.bounce(collision_info.get_normal())
			velocity *= 0.6


## virtual.
func on_touched(kart_balance_component: KartBalanceComponent) -> void:
	pass
