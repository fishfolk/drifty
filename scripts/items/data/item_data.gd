class_name ItemData
extends Resource

## Name used in UI and info.
@export var name : String

## Image to display in UI.
@export var texture : Texture2D

## Script containing the item class to be given.
## The implemented class must be child of Item
@export var item_script : GDScript

#func get_item() -> Item:
	#var item : Item = ClassDB.instantiate(item_class_name)
	#assert(item is Item)
	#return item

func get_item() -> Item:
	var item := item_script.new() as Item
	assert(item is Item)
	item.item_data = self
	return item
