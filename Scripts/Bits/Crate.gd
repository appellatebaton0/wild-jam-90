class_name CrateBit extends RigidBody3D

var held_by:MoveMasterBit3D

func _integrate_forces(state:PhysicsDirectBodyState3D): if held_by:
	
	state.transform.origin += held_by.attempt_velocity * state.get_step()

func mag(vec3:Vector3): return sqrt(pow(vec3.x, 2) + pow(vec3.y, 2) + pow(vec3.z, 2))
