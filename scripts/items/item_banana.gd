class_name ItemBanana
extends Item


var powerup_banana_packed = preload("res://scenes/powerups/power_up_banana.tscn")

#func get_item_data() -> ItemData:
	#return preload("res://scenes/powerups/item_data/sea_mine.tres")

func use_item(item_component:KartItemUseComponent) -> void:
	var car = item_component.car
	var spawn_position = item_component.item_spawn_behind.global_position
	
	var powerup : PowerUp = powerup_banana_packed.instantiate()
	car.get_tree().current_scene.add_child(powerup)
	powerup.parent_kart = car
	powerup.global_position = spawn_position
	powerup.velocity += car.global_basis.z * 5
	powerup.velocity.y = 5
	
	queue_free()
