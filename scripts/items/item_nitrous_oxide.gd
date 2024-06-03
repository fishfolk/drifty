class_name ItemNitrousOxide
extends Item

func use_item(item_component:KartItemUseComponent) -> void:
	var car = item_component.car
	car.boost(2.4, 8)
	
	queue_free()
