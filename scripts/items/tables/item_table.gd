class_name ItemTable
extends Resource
## List of items which can be pooled randomly, like a loot table.
## Used in item boxes; child classes can have conditions.

# virtual - override with the actual result
func roll() -> ItemData:
	return null
