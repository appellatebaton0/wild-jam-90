class_name PushPullBit3D extends MoveBit3D
## Allows for pushing and pulling objects like crates, OOT styling.

@export var input_name:StringName

@export var cast:ShapeCast3D
@export var bot_collision_mask:int
@export var obj_collision_layer:int

var holding:RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Find the cast if needed.
	if not cast:
		for child in get_children(): if child is ShapeCast3D:
			cast = child
			break
		
		var me = self
		if me is ShapeCast3D:
			cast = me
		
		var parent = get_parent()
		if parent is ShapeCast3D:
			cast = parent

func phys_active(_delta:float) -> void:
	
	#print(holding)
	#for i in range(cast.get_collision_count()):
		#print(i, ": ", cast.get_collider(i))
	
	if can_hold():
		var obj = cast.get_collider(0)
		
		if not holding: # Pick up something.
			if obj is CrateBit:
				holding = obj
				
				obj.held_by = master
		
		else: # Keep holding something.
			cast.target_position.z = -1.5

	elif holding: # Put something down.
		holding.held_by = null
		holding = null
		
		cast.target_position.z = -0.3

func can_hold() -> bool:
	
	if not cast.is_colliding() or not Input.is_action_pressed(input_name): return false
	
	if holding and cast.get_collider(0) != holding: return false
	
	
	return true
	

func mag(vec3:Vector3): return sqrt(pow(vec3.x, 2) + pow(vec3.y, 2) + pow(vec3.z, 2))

func pushing_forwards() -> bool:
	if not holding: return false
	
	return master.direction.rotated(Vector3.UP, -master.mover.global_rotation.y).z < 0
