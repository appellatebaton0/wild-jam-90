class_name AndBool extends BoolValue
## Returns whether all the given bools are true.

## The bools to AND.
@export var inputs:Array[BoolValue]

func _ready() -> void:
	for child in get_children():
		if child is BoolValue:
			inputs.append(child)

func value() -> bool:
	var valid = true
	
	for input in inputs:
		if not input.value():
			valid = false
	
	return valid
