class_name InputBit extends Bit
## Emits a signal when an input is just_pressed. Supports conditions.

signal just_pressed ## Emitted when the input's just pressed.
signal just_true ## Emitted when input's pressed and condition's true
signal just_false ## Emitted when input's pressed and condition's true

## The name of the input to look for.
@export var input:String

## (Optional) The condition to modify the signal with.
@export var condition:BoolValue

func _ready() -> void:
	if condition == null:
		for child in get_children():
			if child is BoolValue:
				condition = child
				break

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(input):
		## If the condition exists, do what is required.
		if condition != null:
			var value := condition.value()
			if value:
				just_true.emit()
			else:
				just_false.emit()
		
		just_pressed.emit()
