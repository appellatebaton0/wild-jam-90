class_name ModifiedFloat extends FloatValue
## Modifies a FloatValue using another via a given operation, and returns the result

## The value to modify
@export var value_a:FloatValue
## The value to modify it with
@export var value_b:FloatValue

enum operations{
	ADD, ## Add b to a
	SUBTRACT, ## Subtract b from a
	DIVIDE, ## Divide a by b
	MULTIPLY, ## Multiply a by b
}

@export var operation := operations.ADD

func _ready() -> void:
	for child in get_children():
		if child is FloatValue:
			if value_a == null:
				value_a = child
			elif value_b == null:
				value_b = child

func value() -> float:
	if value_a != null and value_b != null:
		var real_a = value_a.value()
		var real_b = value_b.value()
		
		match operation:
			operations.ADD:
				return real_a + real_b
			operations.SUBTRACT:
				return real_a - real_b
			operations.MULTIPLY:
				return real_a * real_b
			operations.DIVIDE:
				return real_a / real_b
	return -1.0
