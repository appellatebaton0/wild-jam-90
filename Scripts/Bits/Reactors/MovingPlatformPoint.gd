@tool
class_name PlatformPoint extends Bit
## Provides a point for a MovingPlatform to interpolate to/from.

@export var ease := 1.0 ## The ease to use when moving from this point.
@export var time := 1.0 ## How long moving to this point takes.
@export var after_wait := 1.0 ## How long to wait before moving from this point.

@onready var node := get_self()
func get_self() -> Node3D: 
	var me = self
	return me

func _ready() -> void:
	node.visible = Engine.is_editor_hint()
