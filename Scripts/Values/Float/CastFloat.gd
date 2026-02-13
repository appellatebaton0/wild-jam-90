class_name CastFloat extends FloatValue
## Casts a Value to a float, if possible.

@export var input:Value

func _ready():
	if input == null:
		for child in get_children():
			if child is Value:
				input = child 
				break

func value() -> float:
	if input != null:
		var val = input.value()
		if val is int or val is float or val is bool:
			return float(val)
	return -16777216
