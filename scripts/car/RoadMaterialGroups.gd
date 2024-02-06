extends Resource

## Place all RoadMaterial resources here.
## Most common materials first.
@export var materials : Array[RoadMaterial] = []

## If no other material matches.
@export var default_material : RoadMaterial

func get_material(group_name : String) -> RoadMaterial:
	var selected_material = default_material
	
	for material in materials:
		if material.group_name == group_name:
			selected_material = material
			break
	
	return selected_material
