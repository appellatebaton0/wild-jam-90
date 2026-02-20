class_name BarBit extends Bit
## Creates functionality for bars, like stamina, basic health, etc.

signal up
signal down

@export var value := 100.0 ## The current value.
@export var max_value := 100.0 ## The maximum value of the bar.

## If the key condition is true, the value will go up by that amount.
@export var up_conditions:Dictionary[BoolValue, float]

## If the key condition is true, the value will go down by that amount.
@export var down_conditions:Dictionary[BoolValue, float]

@export var bar:Range ## The bar this bit will display its value on.
@export var hide_on_full := false ## Whether to hide the bar if the value is the max.
@export var hide_speed := 10.0

@onready var real_value := value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for condition in down_conditions:
		if condition.value():
			real_value = move_toward(real_value, 0, delta * down_conditions[condition])
			down.emit()
	
	for condition in up_conditions:
		if condition.value():
			real_value = move_toward(real_value, max_value, delta * up_conditions[condition])
			up.emit()
		
	value = lerp(value, real_value, 0.2)
	
	if bar:
		bar.value = value
		bar.max_value = max_value
		
		if hide_on_full:
			bar.modulate.a = move_toward(bar.modulate.a, 0.0 if real_value == max_value else 1.0, delta * hide_speed)

func remains(): return real_value > 0
