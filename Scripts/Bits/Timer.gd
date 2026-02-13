class_name TimerBit extends Bit
## Emits a signal on a given timer.

signal timed_out ## Emitted whenever the timer runs outs.

## The length between each signal
@export var length := 1.0
## The starting time of the timer.
@export var time := 0.0
## Whether to only run this timer once.
@export var one_shot := false

func _process(delta: float) -> void:
	
	time = move_toward(time, length, delta)
	
	if time >= length:
		timed_out.emit()
		
		if not one_shot:
			time = 0
