@abstract class_name MoveBit extends Bit
## A bit that provides instructions for how to move,
## through a MoveMasterBit that executes them. 

## Whether this MoveBit needs to be the current_state of its MoveMasterBit to run.
@export var exclusive := true

func on_active() -> void:
	pass
func on_inactive() -> void:
	pass

func active(_delta:float) -> void:
	pass
func inactive(_delta:float) -> void:
	pass

func phys_active(_delta:float) -> void:
	pass
func phys_inactive(_delta:float) -> void:
	pass
