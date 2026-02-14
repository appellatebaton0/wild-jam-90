class_name CastVector3 extends Vector3Value
## Casts a given value to a Vector3

@export var from:Value

func _ready() -> void:
	if from == null:
		for child in get_children():
			if child is Value:
				from = child
				break

func value() -> Vector3:
	if from != null:
		var response = from.value()
		if response is Vector3 or response is Vector3i:
			return Vector3(response)
	return Vector3.ZERO
