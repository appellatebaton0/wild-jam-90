class_name MagnitudeFloat extends FloatValue
## Turns a Vector2 or Vector3 Value into its magnitude.

@export var vec2:Vector2Value
@export var vec3:Vector3Value

func _ready() -> void:
	for child in get_children():
		if child is Vector2Value and not vec2: vec2 = child
		if child is Vector3Value and not vec3: vec3 = child

func value() -> float:
	if vec2: 
		var vec = vec2.value()
		return sqrt(pow(vec.x, 2) + pow(vec.y, 2))
	if vec3: 
		var vec = vec3.value()
		return sqrt(pow(vec.x, 2) + pow(vec.y, 2) + pow(vec.z, 2))
	return 0
