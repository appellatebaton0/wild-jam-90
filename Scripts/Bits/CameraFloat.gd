class_name CameraFloat extends Bit
# Uses a raycast to set the position of a camera, to (hopefully) prevent clipping.

@export var ray:RayCast3D
@export var target:ManualNode

func _ready() -> void:
	if not ray:
		var me = self
		if me is RayCast3D: ray = me

func _process(_delta: float) -> void:
	var targ:Node3D = target.value()
	
	# Set the target position to the point the ray hits if there is one, otherwise as far out as it goes.
	targ.position = ray.to_local(ray.get_collision_point()) if ray.is_colliding() else lerp(targ.position, ray.target_position, 0.1)
