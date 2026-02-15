@tool

class_name JiggleBone3D
extends SkeletonModifier3D

enum Axis {
	X_Plus, Y_Plus, Z_Plus, X_Minus, Y_Minus, Z_Minus
}

@export_enum(" ") var bone_name: String:
	set(name):
		bone_name = name
		var _skeleton = get_skeleton()
		if _skeleton:
			bone_id = _skeleton.find_bone(bone_name)
			bone_id_parent = _skeleton.get_bone_parent(bone_id)


func _validate_property(property: Dictionary) -> void:
	if property.name == "bone_name":
		var _skeleton: Skeleton3D = get_skeleton()
		if _skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = _skeleton.get_concatenated_bone_names()
			

@export_range(0.1,100,0.1) var stiffness: float = 1
@export_range(0,100,0.1) var damping: float = 0
@export var use_gravity: bool = false
@export var gravity := Vector3(0, -9.81, 0)
@export var forward_axis: Axis = Axis.Z_Minus
#@export_node_path("CollisionShape3D") var collision_shape: NodePath:
	#set(path):
		#collision_shape = path
		#var collision_sphere = get_node_or_null(path)
		#if collision_sphere:
			#assert(collision_sphere is CollisionShape3D and collision_sphere.shape is SphereShape3D, "%s: Only SphereShapes are supported for CollisionShapes" % [ name ])
			#collision_spheres.set(0, collision_sphere)


var skeleton: Skeleton3D
var bone_id: int
var bone_id_parent: int
@export var collision_spheres: Array[CollisionShape3D]
var prev_pos: Vector3

func validate_skeleton():
	skeleton = get_skeleton()
	if skeleton:
		bone_id = skeleton.find_bone(bone_name)
		bone_id_parent = skeleton.get_bone_parent(bone_id)
	
	top_level = true

func _process_modification() -> void:
	var delta = get_process_delta_time()
	
	if !skeleton or skeleton != get_skeleton():
		validate_skeleton()
	
	if !skeleton or !is_inside_tree():
		return
	
	if prev_pos == Vector3.ZERO:
		prev_pos = global_transform.origin
	
	# Note:
	# Local space = local to the bone
	# Object space = local to the skeleton (confusingly called "global" in get_bone_global_pose)
	# World space = global

	# See https://godotengine.org/qa/7631/armature-differences-between-bones-custom_pose-Transform3D
	
	var bone_transf_obj: Transform3D = skeleton.get_bone_global_pose(bone_id) # Object space bone pose
	var bone_transf_world: Transform3D = skeleton.global_transform * bone_transf_obj
	
	var parent_pose = Transform3D()
	if bone_id_parent >= 0:
		parent_pose = skeleton.get_bone_global_pose(bone_id_parent)
	
	var bone_transf_rest_local: Transform3D = skeleton.get_bone_rest(bone_id)
	var bone_transf_rest_obj: Transform3D = (parent_pose * bone_transf_rest_local)
	var bone_transf_rest_world: Transform3D = skeleton.global_transform * bone_transf_rest_obj

	############### Integrate velocity (Verlet integration) ##############	
	
	# If not using gravity, apply force in the direction of the bone (so it always wants to point "forward")
	var grav: Vector3 = (bone_transf_world.basis * get_bone_forward_local()).normalized() * 9.81
	var vel: Vector3 = (global_transform.origin - prev_pos) / delta

	if use_gravity:
		grav = gravity

	grav *= stiffness
	vel += grav 
	vel -= vel * damping * delta  # Damping

	prev_pos = global_transform.origin
	
	if !vel.is_finite():
		return
	
	global_transform.origin += vel * delta

	############### Solve distance constraint ##############

	var goal_pos: Vector3 = skeleton.to_global(skeleton.get_bone_global_pose(bone_id).origin)
	global_transform.origin = goal_pos + (global_transform.origin - goal_pos).normalized()

	if collision_spheres.size() > 0:
		# If bone is inside the collision sphere, push it out
		var total_push := Vector3.ZERO
		for collision_sphere: CollisionShape3D in collision_spheres:
			if collision_sphere and is_instance_valid(collision_sphere) and collision_sphere.is_inside_tree():
				var test_vec: Vector3 = goal_pos - collision_sphere.global_transform.origin
				var distance: float = test_vec.length() - collision_sphere.shape.radius
				if distance < 0:
					total_push += test_vec.normalized() * distance
					#global_transform.origin -= test_vec.normalized() * distance
		global_transform.origin -= total_push

	############## Rotate the bone to point to this object #############

	var diff_vec_local: Vector3 = (bone_transf_world.affine_inverse() * global_transform.origin).normalized()

	var bone_forward_local: Vector3 = get_bone_forward_local()

	# The axis+angle to rotate on, in local-to-bone space
	var bone_rotate_axis: Vector3 = bone_forward_local.cross(diff_vec_local)
	var bone_rotate_angle: float = acos(bone_forward_local.dot(diff_vec_local))
	
	if bone_rotate_axis.length() < 1e-3:
		return  # Already aligned, no need to rotate

	bone_rotate_axis = bone_rotate_axis.normalized()
	if is_nan(bone_rotate_axis.x):
		push_error("AXIS IS NAN! ABORTING")
		return
	
	# Bring the axis to object space, WITHOUT position (so only the BASIS is used) since vectors shouldn't be translated
	var bone_rotate_axis_obj: Vector3 = (bone_transf_obj.basis * bone_rotate_axis).normalized()
	var bone_new_transf_obj: Transform3D = Transform3D(bone_transf_obj.basis.rotated(bone_rotate_axis_obj, bone_rotate_angle), bone_transf_obj.origin)
	
	#bone_new_transf_obj = lerp(bone_transf_obj, bone_new_transf_obj, 0.5)
	skeleton.set_bone_global_pose(bone_id, bone_new_transf_obj)#, 0.5, true)

	# Orient this object to the jigglebone
	global_transform.basis = (skeleton.global_transform * skeleton.get_bone_global_pose(bone_id)).basis

func get_bone_forward_local() -> Vector3:
	match forward_axis:
		Axis.X_Plus: return Vector3(1,0,0)
		Axis.Y_Plus: return Vector3(0,1,0)
		Axis.Z_Plus: return Vector3(0,0,1)
		Axis.X_Minus: return Vector3(-1,0,0)
		Axis.Y_Minus: return Vector3(0,-1,0)
		_, Axis.Z_Minus: return Vector3(0,0,-1)
