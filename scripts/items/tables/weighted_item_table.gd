class_name WeightedItemTable
extends ItemTable

#class WeightedTableEntry:
	#@export var item : ItemData
	#@export var weight : float
#
#@export var entries : Array[WeightedTableEntry] = []

@export var items : Array[ItemData] = []
@export var weights : Array[float] = []


func roll() -> ItemData:
	assert(items != [] and weights != [])
	assert(items.size() == weights.size())
	
	return pick_weighted_random()


func pick_weighted_random() -> ItemData:
	var cumulative_weights = []
	for i in range(weights.size()):
		if i == 0:
			cumulative_weights.append(weights[0])
		else:
			cumulative_weights.append(weights[i] + cumulative_weights[i-1])
	
	var random = cumulative_weights.back() * randf()
	for i in range(cumulative_weights.size()):
		if random < cumulative_weights[i]:
			return items[i]
	
	return items.back()
