extends Area3D
@export var reset:Node
@export var rememberPos:bool = false 
@export var positionmark:Marker3D


func _on_area_entered(_area: Detector) -> void:
	var copy = reset.duplicate()
	
	reset.queue_free()
	get_parent().add_child(copy)
	reset = copy
	
	
	if rememberPos == true:
		reset.global_position = positionmark.global_position
		var anim = reset.get_node_or_null("AnimationPlayer")
		if anim:
			anim.play("Dissolve_In")
			
	

func _ready() -> void:
	pass
		
