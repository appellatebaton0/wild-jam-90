class_name WallSlideBit3D extends ControlBit3D
## Allows a bot to slide down walls slower than the normal falling speed.

## The static speed to slide with.
@export var slide_speed := 30.0
## How long you can just hold onto the wall before you start to slide.
@export var stick_time := 4.0
var stick_timer := 0.0

func phys_active(delta:float) -> void:
	if master.mover.is_on_wall_only():
		
		stick_timer = move_toward(stick_timer, 0, delta)
		
		if stick_timer <= 0:
			master.mover.velocity.y = max(master.mover.velocity.y ,-slide_speed * delta)
		else:
			master.mover.velocity.y = max(master.mover.velocity.y , 0)
		
		### Stick to the wall while climbing.
		print(abs(master.mover.get_wall_normal().x * 10), " | ", abs(master.mover.velocity.x))
		if not Input.is_action_pressed(inputs[inp.up]):
			var vel = absmax(-master.mover.get_wall_normal() * 10, master.mover.velocity)
			
			master.mover.velocity.x = vel.x
			master.mover.velocity.z = vel.z
			
		
		
	else: stick_timer = stick_time

func absmax(a:Vector3, b:Vector3) -> Vector3:
	if abs(a.x) > abs(b.x): b.x = a.x
	if abs(a.y) > abs(b.y): b.y = a.y
	if abs(a.z) > abs(b.z): b.z = a.z
	
	return b
