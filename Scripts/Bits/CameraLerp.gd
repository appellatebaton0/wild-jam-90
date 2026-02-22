class_name CameraLerp extends CameraModifier
@export var node: Node3D

var or_transform: Transform3D

func set_active(to: bool):
	print(to)
	if to:
		var targ:Node3D = target.value()
		or_transform = targ.global_transform
	super.set_active(to)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !active: return
	var targ:Node3D = target.value()
	
	targ.global_transform = lerp(or_transform, node.global_transform, ease(1.0 - (timer / time), easing))
	
	timer = move_toward(timer, 0.0, delta)
