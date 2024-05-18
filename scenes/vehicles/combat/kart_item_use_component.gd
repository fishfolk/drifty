class_name KartItemUseComponent
extends Node3D

signal used_melee_attack(direction)
signal used_item(item)

var current_item : Item = null
#var current_item_charges = 0

@export var melee_cooldown_time : float = 0.5 # seconds
var melee_timer : float = 0.0

@export var collision_area : Area3D

@export var item_spawn_front : Node3D
@export var item_spawn_behind : Node3D

## If the next melee should be a punch or kick. Purely visual.
var melee_variant_count : int = 0

var melee_hitbox_packed = preload("res://scenes/vehicles/combat/melee_hitbox.tscn")
var melee_hitbox : Hitbox = null
var melee_sideways_direction : int = 1 # -1 left, 1 right
@onready var car : SimpleRaycastCar = get_parent()
@onready var input : KartInput = car.input


func _ready():
	collision_area.area_entered.connect(_on_collision_area_area_entered)
	current_item = ItemRedShell.new()


func use_melee() -> void:
	#spawn hitbox
	melee_hitbox = melee_hitbox_packed.instantiate()
	var direction = 1
	if input.melee_left and !input.melee_right:
		direction = -1
	melee_hitbox.scale.x = direction
	melee_hitbox.parent_car = car
	add_child(melee_hitbox)
	#print(melee_hitbox)
	used_melee_attack.emit(direction)


func use_current_item() -> void:
	#check if can actually use item
	used_item.emit(current_item)
	current_item.use_item(self)
	
	pass


func _physics_process(delta):
	if melee_timer > 0:
		melee_timer -= delta
	
	if car.input_steer > 0: melee_sideways_direction = 1
	if car.input_steer < 0: melee_sideways_direction = -1
	
	if melee_timer <= 0 and (input.melee_left or input.melee_right):
		if not current_item:
			use_melee()
			melee_timer = melee_cooldown_time
		else:
			use_current_item()
			melee_timer = melee_cooldown_time


func _on_collision_area_area_entered(area:Area3D):
	pass
