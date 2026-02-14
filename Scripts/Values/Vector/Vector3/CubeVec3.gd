class_name CubeVector3 extends Vector3Value
## Returns a random point from within the bounds specified.

## The negative bounds for the x and y.
@export var negative_bounds = Vector3.ZERO
## The positive bounds for the x and y.
@export var positive_bounds = Vector3.ZERO

## Whether to randomize once on start, or to return a random value on each ask.
@export var randomize_every_time := true
var response:Vector3

func _ready() -> void:
	response = Vector3(randf_range(negative_bounds.x, positive_bounds.x), randf_range(negative_bounds.y, positive_bounds.y), randf_range(negative_bounds.z, positive_bounds.z))

func value() -> Vector3:
	if randomize_every_time:
		_ready()
	
	return response
	
