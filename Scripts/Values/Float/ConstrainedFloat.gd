class_name ConstrainedFloat extends FloatValue
## Constrains a float to a minimum and maximum.

## The value to constrain.
@export var input:FloatValue
## The minimum value to constain to (optional).
@export var minimum:FloatValue
## The maximum value to constrain to (optional).
@export var maximum:FloatValue

func value() -> float:
	if input != null:
		var i_value:float = input.value()
		
		# Apply any existing constraints.
		if minimum != null:
			i_value = maxf(float(i_value), float(minimum.value()))
		if maximum != null:
			i_value = minf(float(i_value), float(maximum.value()))
		
		return i_value # Return the final result.
	return -16777216
