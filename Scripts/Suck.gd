extends Area3D
class_name SuckRange

## suction speed in m/s
@export var suck_speed := 0.5
## increase force as distance closes
@export var suck_force := 15.0
## distance in meters at which the suck gives up
@export var suck_abandon_range := 15.0

@onready var parent = $".."
var tracking_node: Node3D

func _physics_process(delta):
	if tracking_node and is_instance_valid(parent):
		var distance = (parent.global_position - tracking_node.global_position).length()
		if distance <= suck_abandon_range:
			var strength = (1.0 - (distance / suck_abandon_range)) * suck_force
			parent.global_position = parent.global_position.move_toward(tracking_node.global_position, delta * (suck_speed + strength))
		else:
			tracking_node = null

func _on_area_entered(area: Area3D) -> void:
	tracking_node = area
