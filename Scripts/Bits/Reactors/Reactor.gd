@abstract class_name Reactor extends Bit

## The condition the Reactor depends on to function.
@export var condition:BoolValue

## Looks in the children for a condition. Should be run at the start of all Reactors' _ready.
func find_condition(): if not condition:
	for child in get_children(): if child is BoolValue:
		condition = child
		break
