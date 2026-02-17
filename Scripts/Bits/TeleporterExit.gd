class_name TeleporterExitBit extends AreaMasterBit3D
## Teleports the activator back to the last-used TeleporterEntrance
## (that was set to be returnable to).

@onready var parent := get_tree().get_first_node_in_group("TeleporterParent")
var used_by:Node3D

## The action name for using the teleporter
@export var use_input:StringName
@export var animator:AnimationPlayer

func _ready() -> void:
	if area:
		area.area_entered.connect(_on_area_entered)
		area.body_entered.connect(_on_body_entered)
		
		area.area_exited.connect(_on_area_exited)
		area.body_exited.connect(_on_body_exited)
	if animator:
		animator.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void: if InputMap.has_action(use_input):
	
	## The user is trying to, well, use this teleporter.
	if area.has_overlapping_bodies() and Input.is_action_just_pressed(use_input):
		used_by = area.get_overlapping_bodies()[0]
		
		if animator:
			animator.play("warp_in")
		else:
			warp()

func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"warp_in": 
			# Do everything that'll happen halfway through the transition. 
			
			warp() # Warp the user back to the teleporter entrance.
			
			animator.play("warp_out")


## Warp the user to the last-set TeleporterEntranceBit
func warp(): if used_by:
	
	var marker:Node3D = parent.return_point.locate_marker(parent.return_point)
	
	var target:Node3D = marker if marker else parent.return_point.area
	
	used_by.global_position = target.global_position
	used_by.global_rotation = target.global_rotation
