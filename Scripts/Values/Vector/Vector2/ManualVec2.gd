class_name ManualVector2 extends Vector2Value
## Returns a given Vector2

## The Vector2 to return.
@export var response := Vector2.ZERO

func value() -> Vector2:
	return response
