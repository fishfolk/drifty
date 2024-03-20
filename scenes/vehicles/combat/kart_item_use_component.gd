class_name KartItemUseComponent
extends Node3D



var current_item = null
var current_item_charges = 0

@export var melee_cooldown_time : float = 0.5 # seconds
var melee_timer : float = 0.0

## If the next melee should be a punch or kick. Purely visual.
var melee_variant_count : int = 0

var melee_hitbox_packed = preload("res://scenes/vehicles/combat/melee_hitbox.tscn")
var melee_hitbox : Hitbox = null
var melee_sideways_direction : int = 1 # -1 left, 1 right
@onready var car : SimpleRaycastCar = get_parent()


func use_melee() -> void:
	#spawn hitbox
	melee_hitbox = melee_hitbox_packed.instantiate()
	melee_hitbox.scale.x *= melee_sideways_direction
	melee_hitbox.parent_car = car
	add_child(melee_hitbox)
	print(melee_hitbox)


func use_item() -> void:
	pass


func _physics_process(delta):
	if melee_timer > 0:
		melee_timer -= delta
	
	if car.input_steer > 0: melee_sideways_direction = 1
	if car.input_steer < 0: melee_sideways_direction = -1
	
	if melee_timer <= 0 and car.input_item_just_pressed:
		if not current_item:
			use_melee()
			melee_timer = melee_cooldown_time
		else:
			use_item()
