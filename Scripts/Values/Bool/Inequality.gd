class_name InequalityBool extends BoolValue
## Returns whether a FloatValue meets an inequality

## The value to compare in the inequality
@export var value_a:FloatValue

enum inequalities{
	LESS_THAN, ## If A is less than B
	LESS_THAN_OR_EQUAL, ## If A is less than B, or equal to it.
	GREATER_THAN, ## If A is greater than B
	GREATER_THAN_OR_EQUAL_TO, ## If A is greater than B, or equal to it.
	EQUAL, ## If A is equal to B
}
## The comparison to make between the two values
@export var inequality := inequalities.EQUAL

## The value to make the comparison to.
@export var value_b:FloatValue

func _ready() -> void:
	for child in get_children():
		if child is FloatValue:
			if value_a == null:
				value_a = child
			elif value_b == null:
				value_b = child

func value() -> bool:
	if value_a != null and value_b != null:
		var a = value_a.value()
		var b = value_b.value()
		
		match inequality:
			inequalities.LESS_THAN:
				return a < b
			inequalities.LESS_THAN_OR_EQUAL:
				return a <= b
			inequalities.GREATER_THAN:
				return a > b
			inequalities.GREATER_THAN_OR_EQUAL_TO:
				return a >= b
			inequalities.EQUAL:
				return a == b
	
	return false
