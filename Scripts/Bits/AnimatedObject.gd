class_name AnimatedObject extends Bit
## Controls the animation of an AnimationTree via a dictionary of conditions to states.

## The target of the switches.
@export var target:Node
## The conditions that control the currently running animation. int = priority. Name the bool the animation name.
@export var condition_switches:Dictionary[int, BoolValue]

func _process(_delta: float) -> void:
	var check = 0
	var left = condition_switches.duplicate()
	
	while len(left) > 0:
		for priority in left: if priority <= check:
			if left[priority].value():
				target.movement_state = left[priority].name
			left.erase(priority)
		check += 1
