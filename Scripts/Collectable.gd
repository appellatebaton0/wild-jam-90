extends Area3D
class_name Collectable

@export var collectable_value := 1

func _on_area_entered(area: CollisionObject3D) -> void:
	#print("YUM")
	GameState.add_collectable(collectable_value)
	queue_free()
