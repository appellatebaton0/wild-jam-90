class_name TransferBit extends Bit
## Transfers a value across scenes to a target's manual value.

@export var target:NodeValue
@export var target_name:StringName
@export var target_property:StringName

@export var sets_to:Value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var last_target:Node
var last_real_target:Node
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: if target and sets_to:
	
	var t_node := target.value()
	var to:Variant = sets_to.value()
	
	if last_target != t_node:
		
		for node in recur_children(t_node): if node.name == target_name:
			last_real_target = node
			break
	
	if last_real_target: last_real_target.set(target_property, to)

func find_target_value(from:Node) -> Value: 
	if from is Bot:
		
		if from is Bit: from = from.bot
		
		#for bit in from.scan_bot("Value",)
	
	return null

func recur_children(with:Node) -> Array[Node]:
	
	var response:Array[Node]
	
	for child in with.get_children():
		response.append(child)
		response.append_array(recur_children(child))
	
	return response
