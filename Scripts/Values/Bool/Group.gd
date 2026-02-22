class_name GroupBool extends BoolValue
## Returns if all the nodes in a group have a property, and that property is true.

@export var groupname := &""
@export var property := &""

var nodes:Array[Node]

func _ready() -> void: if groupname != &"":
	nodes = get_tree().get_nodes_in_group(groupname)

func value() -> bool:
	for node in nodes: if not node.get(property): return false
	return true
