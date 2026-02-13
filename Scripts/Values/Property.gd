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
		
		# If it's a call return the call.
		if "()" in property:
			return from.value().call(property.replace("()", ""))
		
		# Otherwise, return the property.
		return from.value().get(property)
	return null
