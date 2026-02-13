class_name WallJumpBit3D extends ControlBit3D
## Allows a bot to wall jump. Nothing else, so this should likely be unexclusive.

## The amount of upwards velocity to make the minimum when wall jumping.
@export var vertical_velocity := 10.0
## The amount of velocity to push the bot off of the wall with.
@export var horizontal_velocity := 10.0

## How long to save a jump input for, so the bot can attempt it preemptively.
@export var jump_buffering := 0.1
var jump_buffer := 0.0
## How long to continue allowing jumping after leaving the wall.
@export var coyote_time := 0.1
var coyote_timer := 0.0

## The cooldown before the bot can wall jump again.
@export var cooldown := 0.0
var cooldown_timer := 0.0

## For coyote time, keep track of the last wall normal.
var last_wall_normal:Vector3

func phys_active(delta:float) -> void:
	
	
	# Run down the cooldown.
	cooldown_timer = move_toward(cooldown_timer, 0, delta)
	
	# Coyote Time
	coyote_timer = move_toward(coyote_timer, 0, delta)
	jump_buffer = move_toward(jump_buffer, 0, delta)
	if master.mover.is_on_wall_only():
		coyote_timer = coyote_time
		last_wall_normal = master.mover.get_wall_normal()
	
		# Jump Buffering
		if Input.is_action_just_pressed(inputs[inp.up]):
			jump_buffer = jump_buffering
	
	# If can wall jump, and trying to, do so.
	if coyote_timer > 0.0 and jump_buffer > 0.0 and cooldown_timer <= 0.0:
		master.mover.velocity += last_wall_normal * horizontal_velocity
		master.mover.velocity.y = max(master.mover.velocity.y, vertical_velocity)
		
		# Reset the variables.
		cooldown_timer = cooldown
		coyote_timer = 0
		jump_buffer = 0
	
