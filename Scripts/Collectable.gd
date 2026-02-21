@tool
class_name Collectable extends AreaMasterBit3D

const STAMINA_NODE_NAME := &"GotStamina"

var last:Bot

@export var is_stamina_item := false:
	set(to):
		is_stamina_item = to
		
		var a = get_area()
		if to: if a.is_connected("area_entered", consume):
			a.area_entered.disconnect(consume)
		else: if not a.is_connected("area_entered", consume):
			a.area_entered.connect(consume)
		call("add_to_group" if to else "remove_from_group", "Respawnable")
		#suck_range.active = not to

@export var collectable_value := 1

func _ready() -> void: 
	is_stamina_item = is_stamina_item
	area.area_entered.connect(_on_area_entered)

func _on_area_entered(area_in:Area3D):
	var a = area_in
	if a is Bit: a = a.bot
	
	last = a

func consume() -> void:
	GameState.add_collectable(collectable_value)
	queue_free()
	
	if is_stamina_item: transfer(last)

func recur_children(with:Node) -> Array[Node]:
	
	var response:Array[Node]
	
	print(with)
	for child in with.get_children():
		response.append(child)
		response.append_array(recur_children(child))
	
	return response

func transfer(to:Bot) -> void:
	
	var target:Node
	for node in recur_children(to): if node.name == STAMINA_NODE_NAME:
		target = node
		break
	
	if target: target.set("response", true)
