class_name RoundedFloat extends FloatValue
## Rounds a float to a certain place.

## The float to round.
@export var input:FloatValue

## The places to round it to.
@export var places:int

func value() -> float:
	if input != null:
		var place_value := pow(10, places)
		
		return round(input.value() * place_value) / place_value
	
	return -16777216
