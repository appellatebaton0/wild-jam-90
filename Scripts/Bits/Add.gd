class_name AddBit extends Bit
## Instantiates and adds a node from a PackedScene to another node.
## Sort of like a simpler SpawnerBit, better fit for things that don't move.

## The node to add the new instance to.
@export var parent:NodeValue
## The new instance to make.
@export var scene:PackedSceneValue

func _ready() -> void:
	for child in get_children():
		if child is NodeValue and parent == null:
			parent = child
		elif child is PackedSceneValue and scene == null:
			scene = child

func add():
	if parent != null and scene != null:
		var p_node := parent.value()
		var s_value := scene.value()
		
		var new = s_value.instantiate()
		
		p_node.add_child(new)
