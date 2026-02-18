@tool
class_name Signpost extends Node3D

@export_multiline() var text:String:
	set(to): 
		if label: label.text = to
		text = to
@export var label:Label3D

func _ready() -> void:
	label.text = text
