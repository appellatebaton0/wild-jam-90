class_name RectVector2 extends Vector2Value
## Returns a random point from within the bounds specified.

## The negative bounds for the x and y.
@export var negative_bounds = Vector2.ZERO
## The positive bounds for the x and y.
@export var positive_bounds = Vector2.ZERO

## Whether to randomize once on start, or to return a random value on each ask.
@export var randomize_every_time := true
var response:Vector2

func _ready() -> void:
	response = Vector2(randf_range(negative_bounds.x, positive_bounds.x), randf_range(negative_bounds.y, positive_bounds.y))

func value() -> Vector2:
	if randomize_every_time:
		response = Vector2(randf_range(negative_bounds.x, positive_bounds.x), randf_range(negative_bounds.y, positive_bounds.y))
	
	return response
	
