class_name DisappearBit extends Bit

@export var target:Node3D
var active := false

func activate(): if target: target.visible = false
func arg_activate(_x) -> void: if target: target.visible = false
