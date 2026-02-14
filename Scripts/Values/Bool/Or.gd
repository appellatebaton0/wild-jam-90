class_name OrBool extends BoolValue
## Returns whether any of the given bools are true.

## The bools to OR.
@export var inputs:Array[BoolValue]

func _ready() -> void:
	for child in get_children():
		if child is BoolValue and not inputs.has(child):
			inputs.append(child)

func value() -> bool:
	for input in inputs: if input:
		if input.value():
			return true
	
	return false
	
