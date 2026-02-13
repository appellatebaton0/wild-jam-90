@abstract class_name MoveBit3D extends MoveBit
## A MoveBit that's specifically 3D.

## The state machine this belongs to.
@onready var master:MoveMasterBit3D = get_master()
func get_master() -> MoveMasterBit3D:
	var parent = get_parent()
	
	if parent is MoveMasterBit3D:
		return parent
	
	for child in parent.get_children():
		if child is MoveMasterBit3D:
			return child
	
	return null

func vec3_move_towards(from:Vector3, to:Vector3, delta:float):
	return Vector3(move_toward(from.x, to.x, delta), move_toward(from.y, to.y, delta), move_toward(from.z, to.z, delta))
