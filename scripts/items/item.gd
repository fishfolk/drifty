class_name Item
extends Node
## These are the items you collect into your inventory.
## They can include weapons and boosters.

#virtual
func get_item_name() -> String:
	assert(false, "This method must be overriden.")
	return "Item"

#virtual
func get_item_image() -> Texture2D:
	assert(false, "This method must be overriden.")
	return null

#virtual
func use_item(item_component:KartItemUseComponent) -> void:
	assert(false, "This method must be overriden.")
	pass
