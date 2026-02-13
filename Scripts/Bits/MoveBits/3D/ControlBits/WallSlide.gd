class_name WallSlideBit3D extends ControlBit3D
## Allows a bot to slide down walls slower than the normal falling speed.

## The static speed to slide with.
@export var slide_speed := 10.0

func phys_active(delta:float) -> void:
	if master.mover.is_on_wall_only():
		master.mover.velocity.y = max(master.mover.velocity.y ,-slide_speed * delta)
