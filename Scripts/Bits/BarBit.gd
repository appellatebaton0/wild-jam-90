class_name BarBit extends Bit
## Creates functionality for bars, like stamina, basic health, etc.

@export var value := 100.0 ## The current value.
@export var max_value := 100.0 ## The maximum value of the bar.

@export_group("Up", "up_")
@export var up_condition:BoolValue ## If true, the value will go up by the up_increment.
@export var up_increment := 10.0 ## How much to change the value by per second.

@export_group("Down", "down_")
@export var down_condition:BoolValue ## If true, the value will go down by the down_increment.
@export var down_increment := 10.0 ## How much to change the value by per second.

@export var bar:Range ## The bar this bit will display its value on.
@export var hide_on_full := false ## Whether to hide the bar if the value is the max.
@export var hide_speed := 10.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var down:bool = down_condition.value() if down_condition else false
	if down: value = move_toward(value, 0,         delta * down_increment)
	
	var up:bool = up_condition.value() if up_condition else false
	if up:   value = move_toward(value, max_value, delta * up_increment)
	
	if bar:
		bar.value = value
		bar.max_value = max_value
		
		if hide_on_full:
			bar.modulate.a = move_toward(bar.modulate.a, 0.0 if value == max_value else 1.0, delta * hide_speed)

func remains(): return value > 0
