class_name CastNode extends NodeValue

@export var input:Value

func _ready() -> void:
	if not input:
		for child in get_children(): if child is Value:
			input = child
			break

func value() -> Node:
	
	var val = input.value() if input else null
	
	if val is Node: return val
	
	return null
