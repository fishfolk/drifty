class_name MultipleItemTable
extends ItemTable

@export var items : Array[ItemData] = []

func roll() -> ItemData:
	assert(items != [])
	return items.pick_random()
