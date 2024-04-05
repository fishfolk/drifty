class_name ItemGreenShell
extends Item


var powerup_greenshell_packed = preload("res://scenes/powerups/power_up_green_shell.tscn")


func use_item(item_component:KartItemUseComponent):
	var car = item_component.car
	var spawn_position = item_component.item_spawn_front.global_position
	
	var powerup : PowerUp = powerup_greenshell_packed.instantiate()
	car.get_tree().current_scene.add_child(powerup)
	powerup.parent_kart = car
	powerup.global_position = spawn_position
	powerup.velocity = car.linear_velocity
	powerup.velocity -= car.global_basis.z * 10
	#powerup.velocity.y = 5
	queue_free()
