extends Area3D
class_name vanishingplatform
@onready var platform = $"../Pillar_Round_05"
@onready var plat_col:CollisionShape3D = $"../Pillar_Round_05/Plane_015/StaticBody3D/CollisionShape3D"

@export var Remove_Col:bool = false

func _on_area_entered(area: Search_radius) -> void:
	platform.visible = true
	if Remove_Col == true:
		plat_col.disabled = true
	
	


func _on_area_exited(area:Search_radius) -> void:
	platform.visible = false
	if Remove_Col == true:
		plat_col.disabled = false
