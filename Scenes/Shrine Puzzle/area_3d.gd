extends Area3D
@export var reset:Node


func _on_area_entered(_area: Detector) -> void:
	var copy = reset.duplicate()
	print("Duplicated")
	reset.queue_free()
	get_parent().add_child(copy)
	reset = copy
	
	
	
