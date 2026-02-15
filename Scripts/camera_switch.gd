extends Area3D
class_name CSwitch
@onready var Marker = $Marker3D/Camera3D
@export var tspeed:int
var old :Transform3D
var new :Transform3D

func _ready() -> void:
	old = Marker.global_transform


func _on_area_entered(area: Switch) -> void: # This is how the camera switches 
	print("Player entered")
	var CB = area.get_parent()
	
	if CB:	
		var parent = CB.get_parent()
		if parent:
			var camera = parent.get_node_or_null("CameraPivot/Camera3D") # Checking to see if the node has a camear so its not just any node that enters triggers this
			print("Found camera",camera)
			new = camera.global_transform # I wanted to lerp it but I suck 
			
			if camera:
				Marker.make_current()

func _on_area_exited(area: Switch) -> void: # REturns the camera to the previous one 
	print("Player Exited")
	var CB = area.get_parent()
	
	if CB:	
		var parent = CB.get_parent()
		if parent:
			var camera = parent.get_node_or_null("CameraPivot/Camera3D") # Checking to see if the node has a camera 
			print("Found camera",camera)
			if camera:
				camera.make_current()
