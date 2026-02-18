extends Area3D
class_name  SuckRange

var tween =create_tween()


func  _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Detector) -> void:
	var player = area.global_position
	var Gpose = global_position
	var tween =create_tween()
	var collectable = $".."
	
	print(" I see it")
	tween.tween_property(collectable,"global_position",player,0.5)
