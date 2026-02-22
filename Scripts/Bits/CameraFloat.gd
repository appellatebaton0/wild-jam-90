class_name CameraFloat extends CameraModifier
# Uses a raycast to set the position of a camera, to (hopefully) prevent clipping.

func set_active(to:bool):
	active = to
	
	if to:
		timer = time
		
		var targ:Node3D = target.value()
		
		or_pos = targ.position
		or_rot = targ.global_rotation

@export var ray:RayCast3D

func _ready() -> void:
	if not ray:
		var me = self
		if me is RayCast3D: ray = me

func _process(delta: float) -> void: if active:
	var targ:Node3D = target.value()
	
	goal_pos = ray.to_local(ray.get_collision_point()) * 0.9 if ray.is_colliding() else lerp(targ.position, ray.target_position, 0.1)
	
	# Set the target position to the point the ray hits if there is one, otherwise as far out as it goes.
	targ.position = lerp(goal_pos, or_pos, ease(timer/time, easing))
	
	targ.look_at(ray.global_position)
	goal_rot = targ.global_rotation
	
	targ.global_rotation = lerp(goal_rot, or_rot, ease(timer/time, easing))
	
	timer = move_toward(timer, 0.0, delta)
	
