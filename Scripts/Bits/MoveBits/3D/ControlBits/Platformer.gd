class_name PlatformerBit3D extends ControlBit3D
## Provides functionality for a bot to move like a 3D platformer.

@export_group("Horizontal", "horizontal_")
## How fast the bot gets up to top speed
@export var horizontal_acceleration := 40.0
## How fast the bot gets up to top speed while midair
@export var horizontal_air_acceleration := 40.0
## The maximum speed the bot can move via this.
@export var horizontal_max_speed := 10.0
## The amount of friction to apply when the bot is trying to stop moving.
@export var horizontal_friction := 60.0
## The amount of friction to apply when the bot is trying to stop moving midair.
@export var horizontal_air_friction := 60.0

@export_group("Vertical", "vertical_")
## The amount of velocity to apply when jumping.
@export var vertical_jump_velocity := 10.0
## The amount of gravity to apply to the bot.
@export var vertical_gravity_scale := 2.0

@export_group("Leniencies", "l_")
## How long to save a jump input, in seconds.
@export var l_jump_buffering := 0.1
var jump_buffer := 0.0
## How long to allow jumping after leaving the group, in seconds.
@export var l_coyote_time := 0.1
var coyote_timer := 0.0

func phys_active(delta:float) -> void:
	
	# Jump buffering
	jump_buffer = move_toward(jump_buffer, 0, delta)
	if Input.is_action_just_pressed(inputs[inp.up]):
		jump_buffer = l_jump_buffering
	
	# Coyote time.
	coyote_timer = move_toward(coyote_timer, 0, delta)
	if master.mover.is_on_floor():
		coyote_timer = l_coyote_time
	
	
	# Add gravity.
	else:
		master.mover.velocity += vertical_gravity_scale * master.mover.get_gravity() * delta
	
	# Jumping
	if jump_buffer > 0 and coyote_timer > 0:
		master.mover.velocity.y += vertical_jump_velocity
		
		jump_buffer = 0
		coyote_timer = 0
	
	# The directional input the player is giving as a vec2
	var dir = Input.get_vector(inputs[inp.left], inputs[inp.right], inputs[inp.forwards], inputs[inp.backwards])
	# Turn that into a vec3
	var direction := Vector3(dir.x, 0, dir.y)
	# Rotate it by the mover's rotation
	direction = direction.rotated(Vector3(0,1,0), master.rotator.value().global_rotation.y)
	
	# Apply it to the mover.
	if direction:
		# Get the current acceleration
		var current_acceleration = horizontal_acceleration if master.mover.is_on_floor() else horizontal_air_acceleration
		
		# Set the next velocity
		var next_velocity = master.mover.velocity
		
		next_velocity.x = move_toward(next_velocity.x, direction.x * horizontal_max_speed, current_acceleration * delta)
		next_velocity.z = move_toward(next_velocity.z, direction.z * horizontal_max_speed, current_acceleration * delta)
		
		
		master.mover.velocity.x = next_velocity.x
		master.mover.velocity.z = next_velocity.z
	else:
		# Get the current friction
		var current_friction = horizontal_friction if master.mover.is_on_floor() else horizontal_air_friction
		
		master.mover.velocity.x = move_toward(master.mover.velocity.x, 0, current_friction * delta)
		master.mover.velocity.z = move_toward(master.mover.velocity.z, 0, current_friction * delta)
