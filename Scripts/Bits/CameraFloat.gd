class_name CameraFloat extends Bit
# Uses a raycast to set the position of a camera, to (hopefully) prevent clipping.

@export var ray:RayCast3D
@export var target:ManualNode

func _ready() -> void:
	if not ray:
		var me = self
		if me is RayCast3D: ray = me

func _process(delta: float) -> void:
	var targ:Node3D = target.value()
	
	if ray.is_colliding():
		print(ray.is_colliding())
		
		targ.position = ray.to_local(ray.get_collision_point())
	else:
		targ.position = ray.target_position
