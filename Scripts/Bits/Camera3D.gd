class_name CameraBit3D extends Bit
## Provides functionality for a node to pivot along with the mouse.

## The node to pass the Y rotation to
@export var y_target:NodeValue
## The node to pass the X rotation to
@export var x_target:NodeValue

## The angles to clamp the x rotation to.
@export var x_clamp := Vector2(-90, 90)

## The sensitivity of the rotation.
@export var sensitivity:float = 4
## Whether to only apply the rotation if the mouse is captured.
@export var must_be_captured := true

func set_valid(value:NodeValue, amount:Vector3):
	if value != null:
		var node = value.value()
		if node is Node3D:
			var next_rotation:Vector3 = (node.rotation + amount)
			next_rotation.x = clamp(next_rotation.x, deg_to_rad(x_clamp.x), deg_to_rad(x_clamp.y))
			
			node.rotation = next_rotation


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not must_be_captured or Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			set_valid(x_target, Vector3(-event.relative.y * 0.001 * sensitivity, 0, 0))
			set_valid(y_target, Vector3(0, -event.relative.x * 0.001 * sensitivity, 0))
		
