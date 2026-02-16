class_name AnimatedObject extends Bit
## Controls the animation of an AnimationTree via a dictionary of conditions to states.

## The target of the switches.
@export var target:Node
## The conditions that control the currently running animation. int = priority. Name the bool the animation name.
@export var condition_switches:Array[BoolValue]

func _process(_delta: float) -> void:
	
	for condition in condition_switches:
		if condition.value():
			target.movement_state = condition.name
			break
	
	
