class_name Property extends Value
## Returns a given property from a given node.

@export var property:String
@export var from:NodeValue

func _ready() -> void:
	if from == null:
		for child in get_children():
			if child is NodeValue:
				from = child
				break

func value() -> Variant:
	if property != null and from != null:
		
		var from_node = from.value()
		if not from_node: return null
		
		# If it's a call, call that and return it instead of returning the callable itself.
		if "()" in property:
			return from_node.call(property.replace("()", ""))
		
		# Otherwise, return the property.
		return from_node.get(property) 
	return null
