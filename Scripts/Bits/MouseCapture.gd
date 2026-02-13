class_name MouseCapturerBit extends Bit
## Allows for updating the Input.mouse_mode with an AnimationPlayer.

## The mouse_mode to set to.
@export var update_mouse_mode := Input.MOUSE_MODE_MAX
## If true, updates on the next frame.
@export var update := false

func _process(_delta: float) -> void:
	if update:
		Input.mouse_mode = update_mouse_mode
		update = false
