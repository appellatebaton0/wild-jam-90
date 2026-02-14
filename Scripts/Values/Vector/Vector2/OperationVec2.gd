class_name OperationVector2 extends Vector2Value
## Returns the result of an operation between two Vector2Values

## The first value in the operation.
@export var value_a:Vector2Value
## The second value in the operation
@export var value_b:Vector2Value

enum operations{
	ADD, ## Adds the values together.
	SUBTRACT, ## Subtracts b from a.
	DIVIDE, ## Divides a by b.
	MULTIPLY, ## Multiplies the values by each other.
}
@export var operation := operations.ADD

func _ready() -> void:
	for child in get_children():
		if child is Vector2Value:
			if value_a == null:
				value_a = child
			elif value_b == null:
				value_b = child

func value() -> Vector2:
	if value_a != null and value_b != null:
		var a := value_a.value()
		var b := value_b.value()
		
		match operation:
			operations.ADD:
				return a + b
			operations.SUBTRACT:
				return a - b
			operations.DIVIDE:
				return a / b
			operations.MULTIPLY:
				return a * b
	return Vector2.ZERO
