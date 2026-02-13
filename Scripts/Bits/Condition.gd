class_name ConditionBit extends Bit
## Emits a signal if the given BoolValue is true.

signal condition_true

## The condition to check.
@export var condition:BoolValue
## Whether to only emit the signal once.
@export var single := false	
var done = false

func _ready() -> void:
	if condition == null:
		for child in get_children():
			if child is BoolValue:
				condition = child
				break

func _process(_delta: float) -> void:
	if not done:
		var this_val := false
		if condition != null:
			this_val = condition.value()
		
		if this_val:
			condition_true.emit()
			if single:
				done = true	
