class_name CastBool extends BoolValue
## Casts a value to a bool.

## The bool to cast.
@export var input:Value

func _ready() -> void:
	if input == null:
		for child in get_children():
			if child is Value:
				input = child
				break

func value() -> bool:
	if input != null:
		var response = input.value()
		
		if response == null: return false
		
		if response is int or response is bool or response is float:
			return bool(response)
		return true
	
	return false
