class_name Hitbox
extends Area3D

signal lifetime_expired

## This variable will count down, until it hits zero, 
## then the hitbox is deleted and sends a signal
## A lifetime of -1 will never expire.
@export var lifetime : float = 0.5

@export var balance_damage : float = 70.0 # 0 to 100

@export var knockback_power : float = 2.0

@export var destroy_on_contact : bool = true
# melee hitbox has destroy_on_contact set to false

@export var parent_car : SimpleRaycastCar


func on_lifetime_expired():
	lifetime_expired.emit()
	destroy_hitbox()


func destroy_hitbox():
	queue_free()


func on_touched(kart_balance_component: KartBalanceComponent):
	var car = kart_balance_component.car
	if car == parent_car: return
	
	print("hit!")
	kart_balance_component.balance -= balance_damage
	
	# apply knockback                     # extra up direction?
	var direction = (car.global_position  + Vector3.UP*0.5 - global_position).normalized()
	#var direction = (car.global_position - global_position).normalized()
	if kart_balance_component.balance <= 0:
		direction *= 3 # extra powerful hit
	car.linear_velocity += direction * knockback_power

	
	if destroy_on_contact:
		destroy_hitbox()


func _physics_process(delta):
	if lifetime > 0:
		lifetime -= delta
	#print(lifetime)
	
	if lifetime != 1 and lifetime <= 0:
		on_lifetime_expired()


