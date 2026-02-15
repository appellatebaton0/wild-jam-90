class_name LookBit extends Bit
## Makes one node look at another

## The node to make look at another.
@export var from:NodeValue

## The locations to make it look at.
@export var tos:Dictionary[BoolValue, Vector3Value]

## The speed with which to turn to look at the player, in degrees per second.
@export var turn_speed := 0.0
## The amount to lerp between the current rotation and the look rotation, 0 being none and 1 being instant.
@export_range(0.0, 1.0, 0.001) var turn_lerp := 1.0

## The axis to apply the look to.
@export_group("Axes", "look_")
@export var look_x := true
@export var look_y := true
@export var look_z := true

@export var to_is_local := true

func vec3_rad_to_deg(a:Vector3) -> Vector3:
	return Vector3(rad_to_deg(a.x),rad_to_deg(a.y),rad_to_deg(a.z))

func vec3_move_towards(a:Vector3, b:Vector3, delta:float):
	return Vector3(move_toward(a.x, b.x, delta), move_toward(a.y, b.y, delta), move_toward(a.z, b.z, delta))

func _ready() -> void:
	for child in get_children():
		if child is NodeValue and from == null: from = child

func _process(delta: float) -> void:
	if from != null and tos != null:
		
		var to:Vector3Value
	
		for condition in tos: if condition.value():
			to = tos[condition]
		
		var f_node = from.value()
		var t_pos = to.value() if to else f_node.global_position
		if to_is_local: t_pos = f_node.to_local(t_pos)
		
		if f_node is Node3D:
			if t_pos is Vector3:
				# Get the starting rotation
				var regular_rotation = f_node.rotation
				
				# Get the desired ending rotation
				if not f_node.global_position.cross(t_pos).is_zero_approx() and t_pos != f_node.global_position:
					f_node.look_at(t_pos)
				var look_rotation = f_node.rotation
				f_node.rotation = regular_rotation
				
				# Apply the necessary rotations
				var real_rotation = regular_rotation
				if look_x:
					real_rotation.x = look_rotation.x
				if look_y:
					real_rotation.y = look_rotation.y
				if look_z:
					real_rotation.z = look_rotation.z
				
				#f_node.rotation = real_rotation
				
				## NOTE: Something is broken here. Look at it later.
				## Fix not taking the shortest path, by altering the rotation 360* to match.
				var distances = real_rotation - regular_rotation
				if abs(distances.x) > deg_to_rad(180): # Fix X axis if the distance is more than needed
					if distances.x > 0:
						real_rotation.x -= deg_to_rad(360)
					else:
						real_rotation.x += deg_to_rad(360)
				if abs(distances.y) > deg_to_rad(180): # Fix Y axis if the distance is more than needed
					if distances.y > 0:
						real_rotation.y -= deg_to_rad(360)
					else:
						real_rotation.y += deg_to_rad(360)
				if abs(distances.z) > deg_to_rad(180): # Fix Z axis if the distance is more than needed
					if distances.z > 0:
						real_rotation.z -= deg_to_rad(360)
					else:
						real_rotation.z += deg_to_rad(360)
				
				if turn_speed != 0 and turn_lerp != 0:
					f_node.rotation = lerp(regular_rotation, real_rotation, turn_lerp)
					f_node.rotation = vec3_move_towards(f_node.rotation, real_rotation, turn_speed * delta)
				elif turn_speed != 0:
					f_node.rotation = vec3_move_towards(regular_rotation, real_rotation, turn_speed * delta)
				elif turn_lerp != 0:
					f_node.rotation = lerp(regular_rotation, real_rotation, turn_lerp)
