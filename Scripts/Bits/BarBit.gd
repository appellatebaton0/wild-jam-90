class_name BarBit extends Bit
## Creates functionality for bars, like stamina, basic health, etc.

@export var value := 100.0 ## The current value.
@export var max_value := 100.0 ## The maximum value of the bar.

@export_group("Up", "up_")
@export var up_condition:BoolValue ## If true, the value will go up by the up_increment.
@export var up_increment := 10.0 ## How much to change the value by per second.

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
	
	var up:bool = up_condition.value() if up_condition else false
	if up:   real_value = move_toward(real_value, max_value, delta * up_increment)
	
	value = lerp(value, real_value, 0.2)
	
	if bar:
		bar.value = value
		bar.max_value = max_value
		
		if hide_on_full:
			bar.modulate.a = move_toward(bar.modulate.a, 0.0 if real_value == max_value else 1.0, delta * hide_speed)

func remains(): return real_value > 0
