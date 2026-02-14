class_name SwitchMoveBit extends MoveBit
## Passes the functionality of a set of MoveBits depending on a condition.

## The condition used to decide which bit is active.
@export var condition:BoolValue

@export var true_bits :Array[MoveBit] ## The bit to use when the condition is true.
@export var false_bits:Array[MoveBit] ## The bit to use when the condition is false.

func _ready() -> void: if not condition: for child in get_children(): if child is BoolValue: condition = child

## Wrap all the functions around an abstracted active_bit.
func on_active()   -> void: active_call("on_active")
func on_inactive() -> void: active_call("on_inactive")

func active(delta:float)   -> void: active_call("active", delta)
func inactive(delta:float) -> void: active_call("inactive", delta)

func phys_active(delta:float)   -> void: active_call("phys_active", delta)
func phys_inactive(delta:float) -> void: active_call("phys_inactive", delta)


func active_call(call_name:StringName, arg = null):
	
	for bit in active_bits():
		if arg: bit.call(call_name, arg)
		else:   bit.call(call_name)
	
func active_bits() -> Array[MoveBit]: return true_bits if condition.value() else false_bits
