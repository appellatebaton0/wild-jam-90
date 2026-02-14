class_name InputValue extends BoolValue
## Returns whether an input is currently down.

@export var input_name:StringName

func value() -> bool: return Input.is_action_pressed(input_name)
