class_name ItemData
extends Resource

## Name used in UI and info.
@export var name : String

## Image to display in UI.
@export var image : Texture2D

## Name of the class the instantiated item object will be.
## Class must be child of Item.
@export var item_class_name : String


func get_item() -> Item:
	var item : Item = ClassDB.instantiate(item_class_name)
	assert(item is Item)
	return item
