class_name ManualBool extends BoolValue
## Returns a given Bool

@export var response:bool = true

func value() -> bool:
	return response

func make_false(): response = false
func make_true(): response = true
