class_name ConcatString extends StringValue
## Combines given values into a custom string.

## The values to use.
@export var values:Array[Value]

## The string to return, replacing any {x} with that value in the array.
@export var string:String = "{0}"

func _ready() -> void:
	for child in get_children():
		if child is Value and not values.has(child):
			values.append(child)

var last_values:Array[Variant] = [0,0,0,0,0,0,0]
func value() -> String:
	var response:String = string
	
	for i in range(len(values)):
		if values[i] != null:
			var val = values[i].value()
			
			if val != null and val != -16777216: # Update the failsafe
				last_values[i] = val
				response = response.replace("{"+str(i)+"}", str(val))
			elif len(last_values) >= i: # Use the failsafe
					response = response.replace("{"+str(i)+"}", str(last_values[i]))
	
	
	return response 
