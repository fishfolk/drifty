class_name RacePath3D
extends Path3D

func _ready():
	RaceManager.race_path = self


## reminder: it's on local space, so use racepath.to_local(object.global_position)
func get_closest_offset(to_point: Vector3):
	return curve.get_closest_offset(to_point)


func get_offset_length() -> float:
	return curve.get_baked_length()


func sample_looping(offset:float, cubic:bool=false) -> Vector3:
	var length = curve.get_baked_length()
	# looping clamp
	while offset < 0:
		offset += length
	while offset > length:
		offset -= length
	
	return curve.sample_baked(offset, cubic)

