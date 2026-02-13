class_name CastVector2 extends Vector2Value
## Casts a given value to a Vector2

@export var from:Value

func _ready() -> void:
	if from == null:
		for child in get_children():
			if child is Value:
				from = child
				break

func value() -> Vector2:
	if from != null:
		var response = from.value()
		if response is Vector2 or response is Vector2i:
			return Vector2(response)
	return Vector2.ZERO
