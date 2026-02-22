class_name WallClimb extends ControlBit3D
## Allows a controllable Bot to dash up a wall.

@export var input:InputValue ## The input that activates the dash.
@export var climb_speed := 200.0 ## The upwards velocity applied.

## Switches from Camera_Up to Wall_Up if true
@export var alt_climb_mode := false
#@export_enum("Camera_Up", "Wall_Up") var climb_mode: String = "Camera_Up"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if not input:
		for child in get_children(): if child is InputValue:
			input = child
			break

var direction:Vector2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func phys_active(delta:float) -> void:
	## Get the input direction.
	direction = Input.get_vector(inputs[inp.left], inputs[inp.right], inputs[inp.backwards], inputs[inp.forwards])
	
	## Rotate the direction to face the direction the player is facing (into the wall, because of VelocityLook).
	
	var wall_normal = master.mover.get_wall_normal()
	var flat_wall_normal = (wall_normal * Vector3(1, 0, 1)).normalized()
	var wall_tangent = flat_wall_normal.cross(Vector3.UP)
	var wall_up_relative = wall_tangent.cross(wall_normal)
	
	var wall_basis = Basis(wall_tangent, wall_up_relative, wall_normal)
	var relative_view: Vector3 = master.mover.global_position - master.rotator.value().global_position
	relative_view = relative_view.normalized()
	
	var real_direction := Vector3.ZERO
	if !alt_climb_mode:
		var up_input = (relative_view.dot(Vector3.UP))
		up_input = abs(up_input)#clamp(up_input + 0.5, -1, 1)
		var right_input = (relative_view.dot(wall_tangent))
		
		var turn_amount = atan2(right_input, up_input)
		wall_basis = wall_basis.rotated(wall_basis.z, turn_amount)
		real_direction = (wall_basis.y * direction.y) + (wall_basis.x * -direction.x)
		real_direction = real_direction.normalized()
	else:
		var looking_forward = relative_view.dot(flat_wall_normal)
		
		var right_motion = wall_basis.x * direction.x
		var forward_up_motion = wall_basis.y * -direction.y
		
		real_direction = (forward_up_motion + right_motion)
		real_direction = real_direction.normalized() * normal_sign(looking_forward)
	
	var stick_factor = -wall_normal * 3
	real_direction += stick_factor
	
	#var real_direction = Vector3(direction.x, direction.y, 0).rotated(Vector3.UP, master.mover.global_rotation.y)
	
	master.mover.velocity = real_direction * climb_speed * delta
	
	### Stick to the wall while climbing.
	if not Input.is_action_pressed(inputs[inp.up]):
		var vel = absmax(-master.mover.get_wall_normal() * 2, master.mover.velocity)
		
		master.mover.velocity.x = vel.x
		master.mover.velocity.z = vel.z
	
func normal_sign(x: float) -> float:
	return 1.0 if x >= 0.0 else -1.0

func absmax(a:Vector3, b:Vector3) -> Vector3:
	if abs(a.x) > abs(b.x): b.x = a.x
	if abs(a.y) > abs(b.y): b.y = a.y
	if abs(a.z) > abs(b.z): b.z = a.z
	
	return b

func _set_climb_mode(alt := false):
	alt_climb_mode = alt
