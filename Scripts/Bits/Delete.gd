class_name DeleteBit extends Bit
## Deletes an existing node.

## The node to delete.
@export var target:NodeValue

func _ready() -> void:
	for child in get_children():
		if child is NodeValue and target == null:
			target = child

func delete():
	if target != null:
		var node = target.value()
		
		if node != null:
			if node is Bot:
				node.bot_free()
			else:
				node.call_deferred("queue_free")
