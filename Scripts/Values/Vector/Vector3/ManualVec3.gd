class_name ManualVector3 extends Vector3Value
## Returns a given Vector3

## The Vector3 to return.
@export var response := Vector3.ZERO

func value() -> Vector3:
	return response
