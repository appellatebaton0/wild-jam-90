class_name BitNode extends NodeValue
## Returns a bit from a given node.

## The class_name of the bit to get.
@export var bit_id:Variant 
@export var from:NodeValue

func _ready() -> void:
	if from == null:
		for child in get_children():
			if child is NodeValue:
				from = child
				break

func value() -> Node:
	if from != null and bit_id != null:
		var from_node = from.value()
		
		for child in from_node.get_children():
			if is_instance_of(child, bit_id):
				return child
	return null
