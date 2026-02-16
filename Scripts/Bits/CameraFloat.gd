class_name CameraFloat extends Bit
# Uses a raycast to set the position of a camera, to (hopefully) prevent clipping.

@export var easing := 1.0 ## The ease to use when moving.
@export var time := 1.0 ## How long moving between positions takes.
var timer := 0.0

var or_rot:Vector3
var or_pos:Vector3

@export var active:bool = true : set = set_active
func set_active(to:bool):
	active = to
	
	if to:
		timer = time
		
		var targ:Node3D = target.value()
		
		or_pos = targ.position
		or_rot = targ.global_rotation

@export var ray:RayCast3D
@export var target:ManualNode

func _ready() -> void:
	if not ray:
		var me = self
		if me is RayCast3D: ray = me

func _process(delta: float) -> void: if active:
	var targ:Node3D = target.value()
	
	var goal_pos:Vector3 = ray.to_local(ray.get_collision_point()) if ray.is_colliding() else lerp(targ.position, ray.target_position, 0.1)
	
	# Set the target position to the point the ray hits if there is one, otherwise as far out as it goes.
	targ.position = lerp(goal_pos, or_pos, ease(timer/time, easing))
	
	var real_rotation = targ.global_rotation
	targ.look_at(ray.global_position)
	var goal_rotation = targ.global_rotation
	
	targ.global_rotation = lerp(goal_rotation, or_rot, ease(timer/time, easing))
	
	timer = move_toward(timer, 0.0, delta)
