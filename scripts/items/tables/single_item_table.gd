class_name SingleItemTable
extends ItemTable
## can only return a single item

@export var item : ItemData

func roll() -> ItemData:
	return item
