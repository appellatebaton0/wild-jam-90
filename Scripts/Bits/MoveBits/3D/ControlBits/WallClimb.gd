class_name WallClimb extends ControlBit3D
## Allows a controllable Bot to dash up a wall.

@export var input:InputValue ## The input that activates the dash.
@export var climb_speed := 200.0 ## The upwards velocity applied.

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
	
	var real_direction = Vector3(direction.x, direction.y, 0).rotated(Vector3.UP, master.mover.global_rotation.y)
	
	master.mover.velocity = real_direction * climb_speed * delta
	
	### Stick to the wall while climbing.
	if not Input.is_action_pressed(inputs[inp.up]):
		var vel = absmax(-master.mover.get_wall_normal() * 2, master.mover.velocity)
		
		master.mover.velocity.x = vel.x
		master.mover.velocity.z = vel.z
	
func absmax(a:Vector3, b:Vector3) -> Vector3:
	if abs(a.x) > abs(b.x): b.x = a.x
	if abs(a.y) > abs(b.y): b.y = a.y
	if abs(a.z) > abs(b.z): b.z = a.z
	
	return b
