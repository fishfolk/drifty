class_name KartBalanceComponent
extends Node3D

signal balance_lost(balance)
signal balance_lost_completely

@export var collision_area : Area3D

## Balance works like a health bar would. Maxes out at 100.
## If it reaches 0, the balance breaks and the kart spins out.
## Regens over time.
var balance : float = 100 :
	set(value):
		balance = clampf(value, 0, 100)
		balance_lost.emit(balance)
		if balance == 0:
			_on_balance_lost_completely()
			balance_lost_completely.emit()

var balance_regen_speed : float = 100.0 / 3.0 # regen 100 in three seconds.

var hud_packed = preload("res://scenes/vehicles/hud/hud_balance.tscn")
var hud

@onready var car : SimpleRaycastCar = get_parent()

func _ready():
	hud = hud_packed.instantiate()
	add_child(hud)


func _physics_process(delta):
	balance += balance_regen_speed * delta
	hud.set_balance(balance)


func _on_balance_lost_completely() -> void:
	#car.spin_out()
	pass

#### DEBUG
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and not event.is_echo() and event.pressed:
			balance -= 40
