class_name DragObjectBit extends ControlBit3D
## Allows for dragging an object held by a PushPullBit around.

@export var pushpull:PushPullBit3D

## How fast the bot gets up to top speed
@export var acceleration := 40.0
## The maximum speed the bot can move via this.
@export var max_speed := 10.0
## The amount of friction to apply when the bot is trying to stop moving.
@export var friction := 60.0

## The amount of gravity to apply to the bot.
@export var gravity_scale := 2.0

var direction:Vector3
func phys_active(delta:float) -> void:
	if not master.mover.is_on_floor():
		master.mover.velocity += gravity_scale * master.mover.get_gravity() * delta
	
	# The directional input the player is giving as a vec3
	direction = Vector3(0.0, 0.0, Input.get_axis(inputs[inp.forwards], inputs[inp.backwards]))
	
	# Rotate it by the mover's rotation
	direction = direction.rotated(Vector3(0,1,0), master.mover.global_rotation.y)
	
	# Lock it to within a 90* increment of the object being held.
	direction = lock_to_obj(direction)
	
	# Apply it to the mover.
	if direction:
		# Get the current acceleration
		var current_acceleration = acceleration
		
		# Set the next velocity
		var next_velocity = master.mover.velocity
		
		next_velocity.x = move_toward(next_velocity.x, direction.x * max_speed, current_acceleration * delta)
		next_velocity.z = move_toward(next_velocity.z, direction.z * max_speed, current_acceleration * delta)
		
		master.mover.velocity.x = next_velocity.x
		master.mover.velocity.z = next_velocity.z
	else:
		# Get the current friction
		var current_friction = friction
		
		master.mover.velocity.x = move_toward(master.mover.velocity.x, 0, current_friction * delta)
		master.mover.velocity.z = move_toward(master.mover.velocity.z, 0, current_friction * delta)
	
	master.direction = direction

func lock_to_obj(direction:Vector3) -> Vector3:
	
	if not direction: return direction
	
	var dir := Vector2(direction.x, direction.z)
	
	var object = pushpull.holding
	var obj_rotation = object.rotation.y
	
	var options := [
		Vector2.UP.rotated(deg_to_rad(rad_to_deg(-obj_rotation) + 0)),
		Vector2.UP.rotated(deg_to_rad(rad_to_deg(-obj_rotation) + 90)),
		Vector2.UP.rotated(deg_to_rad(rad_to_deg(-obj_rotation) + 180)),
		Vector2.UP.rotated(deg_to_rad(rad_to_deg(-obj_rotation) + 270)),
	]
	
	var best:Vector2
	
	# Options
	for option in options:
		if option.dot(dir) > best.dot(dir) or not best:
			best = option
	
	return Vector3(best.x, 0, best.y)
