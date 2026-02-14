class_name CrateBit extends RigidBody3D

var held_by:MoveMasterBit3D

func _integrate_forces(state:PhysicsDirectBodyState3D): if held_by:
	var mov = held_by.mover
	
	# Get the velocity w/o side to side.
	var vel = mov.velocity.rotated(Vector3.UP, -mov.rotation.y)
	vel.x = 0.0
	vel = vel.rotated(Vector3.UP, mov.rotation.y)
	
	var dir = held_by.direction.rotated(Vector3.UP, -mov.rotation.y)
	dir.x = 0.0
	dir = dir.rotated(Vector3.UP, mov.rotation.y)
	
	
	## ALSO tries to make pushing foarwards possible.
	if dir and mag(vel) < 1.0:
		apply_central_force(dir * 100)
	
	state.transform.origin += vel * state.get_step()

func mag(vec3:Vector3): return sqrt(pow(vec3.x, 2) + pow(vec3.y, 2) + pow(vec3.z, 2))
