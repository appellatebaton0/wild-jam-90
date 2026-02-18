extends Area3D
class_name Collectable

@export var Value : int 


func _ready() -> void:
	Value
	



func _on_area_entered(area:Detector) -> void:
	var collect = $".."
	print("YUM")
	collect.queue_free()
