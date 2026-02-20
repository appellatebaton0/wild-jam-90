@tool
class_name Collectable extends AreaMasterBit3D

const STAMINA_NODE_NAME := &"GotStamina"

#@export var suck_range:Area3D
@export var is_stamina_item := false:
	set(to):
		is_stamina_item = to
		call("add_to_group" if to else "remove_from_group", "Respawnable")
		#suck_range.active = not to

@export var collectable_value := 1

func _on_area_entered(area: Area3D) -> void:
	
	var a = area
	if a is Bit: a = a.bot
	
	#print("YUM")
	GameState.add_collectable(collectable_value)
	queue_free()
	
	if is_stamina_item: transfer(a)


func recur_children(with:Node) -> Array[Node]:
	
	var response:Array[Node]
	
	for child in with.get_children():
		response.append(child)
		response.append_array(recur_children(child))
	
	return response

func transfer(to:Bot) -> void:
	
	var target:Node
	for node in recur_children(to): if node.name == STAMINA_NODE_NAME:
		target = node
		break
	
	print("setting ", target, " as true")
	if target: target.set("response", true)
