class_name PositionVector3 extends Vector3Value
## Returns the position of a Node2D

## The node to use.
@export var node:NodeValue
var real_node:Node
## Whether to use the local or global position.
@export var local := false

func _ready() -> void:
	var me = self
	if me is Node3D:
		real_node = me
	
	if node == null:
		for child in get_children():
			if child is NodeValue:
				node = child
				break
	
func value() -> Vector3:
	if node != null:
		real_node = node.value()
	if real_node is Node2D:
		return real_node.global_position if not local else real_node.position
	
	return Vector3.ZERO
