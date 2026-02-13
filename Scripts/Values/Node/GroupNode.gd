class_name GroupNode extends NodeValue
## Returns the first node in a group.

@export var group_name:String

func value() -> Node:
	return get_tree().get_first_node_in_group(group_name)
