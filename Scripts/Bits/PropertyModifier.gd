class_name PropertyModifier extends Bit
## Replaces a property of a node with a dynamic one.

## The node to modify
@export var target:NodeValue
## The name of the property to change
@export var property:String
## The value to change it to
@export var value:Value
## Whether to constantly update
@export var constant := false

func _ready() -> void:
	for child in get_children():
		if child is NodeValue and target == null:
			target = child
		elif child is Value and value == null:
			value = child

func _process(_delta: float) -> void:
	if constant:
		update()

func update():
	#print(value.value())
	if target != null and value != null:
		var target_node = target.value()
		var new_value = value.value()
		if target_node and is_instance_valid(target_node) and new_value != target_node.get(property):
			target_node.set(property, value.value())

func arg_update(_x): update()
