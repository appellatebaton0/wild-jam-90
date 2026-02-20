class_name TransferBit extends Bit
## Transfers a value across scenes to a target's manual value.

@export var target:NodeValue
@export var target_name:StringName
@export var target_property:StringName

@export var sets_to:Value
@export var constant := true

var last_target:Node
var last_real_target:Node
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: if constant: transfer()

func recur_children(with:Node) -> Array[Node]:
	
	var response:Array[Node]
	
	for child in with.get_children():
		response.append(child)
		response.append_array(recur_children(child))
	
	return response

func transfer() -> void: if target and sets_to:
	
	var t_node := target.value()
	var to:Variant = sets_to.value()
	
	if last_target != t_node or last_real_target == null: if t_node:
		var search = t_node
		if search is Bit: search = search.bot
		
		for node in recur_children(search): if node.name == target_name:
			last_real_target = node
			break
	
	if last_real_target: last_real_target.set(target_property, to)
	
	pass
