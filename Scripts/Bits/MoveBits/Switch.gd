class_name SwitchMoveBit extends MoveBit
## Passes the functionality of one of two MoveBits on, based on a condition.

## The condition used to decide which bit is active.
@export var condition:BoolValue

@export var true_bit :MoveBit ## The bit to use when the condition is true.
@export var false_bit:MoveBit ## The bit to use when the condition is false.

func _ready() -> void: if not condition: for child in get_children(): if child is BoolValue: condition = child

## Wrap all the functions around an abstracted active_bit.
func on_active()   -> void: active_bit().on_active()
func on_inactive() -> void: active_bit().on_inactive()

func active(delta:float)   -> void: active_bit().active(delta)
func inactive(delta:float) -> void: active_bit().inactive(delta)

func phys_active(delta:float)   -> void: active_bit().phys_active(delta)
func phys_inactive(delta:float) -> void: active_bit().phys_inactive(delta)

func active_bit() -> MoveBit: return true_bit if condition.value() else false_bit
