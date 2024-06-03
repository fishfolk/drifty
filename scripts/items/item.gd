class_name Item
extends Node
## These are the items you collect into your inventory.
## They can include weapons and boosters.

## Original info for this item; filled when this node is created.
var item_data : ItemData = null

#virtual
#func get_item_data() -> ItemData:
	#assert(false, "This method must be overriden.")
	#return null

func get_item_data() -> ItemData:
	return item_data

##virtual
func use_item(item_component:KartItemUseComponent) -> void:
	assert(false, "This method must be overriden.")
	pass
