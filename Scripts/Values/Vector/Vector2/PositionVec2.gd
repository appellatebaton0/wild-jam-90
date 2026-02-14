class_name PositionVector2 extends Vector2Value
## Returns the position of a Node2D

## The node to use.
@export var node:NodeValue
var real_node:Node
## Whether to use the local or global position.
@export var local := false

func _ready() -> void:
	var me = self
	if me is Node2D:
		real_node = me
	
	if node == null:
		for child in get_children():
			if child is NodeValue:
				node = child
				break
	
func value() -> Vector2:
	if node != null:
		real_node = node.value()
	if real_node is Node2D:
		return real_node.global_position if not local else real_node.position
	
	return Vector2.ZERO
