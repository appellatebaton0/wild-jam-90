class_name LerpVector2 extends Vector2Value
## Lerps between two Vector2Values, with another for the weight.

@export var position_a:Vector2Value ## The first node to use.
@export var position_b:Vector2Value ## The second node to use.
@export var lerp_amounts:Vector2Value ## The lerp values for the x and y. Lock between 0.0 and 1.0

## Returns the lerp locked between (0,0) and (1,1)
func locked_lerp():
	var lerp_value = lerp_amounts.value()
	return Vector2(1,1).min(Vector2(0,0).max(lerp_value))

func _ready() -> void:
	## Look for the values in the children.
	for child in get_children():
		if child is Vector2Value:

			if position_a == null:
				position_a = child
			elif position_b == null:
				position_b = child
			elif lerp_amounts == null:
				lerp_amounts = child

func value() -> Vector2:
	if position_a != null and position_b != null:
		var a = position_a.value()
		var b = position_b.value()
		var l = locked_lerp()
		
		return Vector2(lerp(a.x, b.x, l.x), lerp(a.y, b.y, l.y))
		
	return Vector2.ZERO
