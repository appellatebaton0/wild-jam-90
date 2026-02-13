class_name NotBool extends BoolValue
## Returns the given bool, NOTted

## The bool to not.
@export var input:BoolValue

func _ready() -> void:
	if input == null:
		for child in get_children():
			if child is BoolValue:
				input = child
				break

func value() -> bool:
	
	if input != null:
		return not input.value()
	
	return false
