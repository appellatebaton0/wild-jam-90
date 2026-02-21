class_name CastString extends StringValue
## REturns another value casted to a string

@export var input:Value

func _ready() -> void: if not input:
	for child in get_children(): if child is Value:
		input = child
		break

func value() -> String:
	return str(input.value()) if input else ""
