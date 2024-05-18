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
		var old_value = balance
		balance = clampf(value, 0, 100)
		if old_value > balance:
			balance_lost.emit(balance)
		if balance == 0:
			_on_balance_lost_completely()
			balance_lost_completely.emit()
		if hud:
			hud.set_balance(balance)

var balance_regen_speed : float = 100.0 / 3.0 # regen 100 in three seconds.

var hud_packed = preload("res://scenes/vehicles/hud/hud_balance.tscn")
var hud

@onready var car : SimpleRaycastCar = get_parent()

func _ready():
	hud = hud_packed.instantiate()
	add_child(hud)
	
	if collision_area:
		collision_area.area_entered.connect(_on_item_area_entered)


func _physics_process(delta):
	balance += balance_regen_speed * delta

# will also be used for melee
func _on_item_area_entered(area: Area3D) -> void:
	var p = area.get_parent()
	if p is PowerUp:
		var powerup = p as PowerUp
		powerup.on_touched(self)
	else:
		if area is Hitbox:
			var hitbox = area as Hitbox
			hitbox.on_touched(self)


func _on_balance_lost_completely() -> void:
	car.spin_out()
	pass

#### DEBUG
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and not event.is_echo() and event.pressed:
			balance -= 40
