extends Area3D
class_name SuckRange

func _on_area_entered(area: CollisionObject3D) -> void:
	var player = area.global_position
	var tween = create_tween()
	var collectable = $".."
	
	#print(" I see it")
	tween.tween_property(collectable, "global_position", player, 0.5)
