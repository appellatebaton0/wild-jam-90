class_name RespawnBit3D extends Bit
## Provides functionality for respawning a Bot at a certain location.

var setup_by:Node

@export var animator:AnimationPlayer
@export var global_kill:StringName = "" ## An optional group to recursively kill.

@export var out_anim_name:StringName
@export var in_anim_name:StringName

var position:Vector3
var rotation:Vector3

var target

func _ready() -> void: 
	
	if animator:
		animator.animation_finished.connect(_on_animation_finished)
	
	setup()

func respawn(group := global_kill) -> void:
	if group != "":
		for node in get_tree().get_nodes_in_group(global_kill):
			if node is Bot:
				var scan:Array[Bit] = node.scan_bot("RespawnBit3D")
				
				if len(scan) > 0: scan[0].respawn("")
	
	if animator:
		animator.play(out_anim_name)
	else:
		_real_respawn()

func find_target(with:Node = bot, depth := 5) -> Node3D:
	
	if depth == 0 or with == null: return null
	
	if with is Node3D: return with
	
	for child in with.get_children():
		if child is Node3D: return child
		
		var check = find_target(child, depth - 1)
		
		if check is Node3D: return check
	return null

func _on_animation_finished(anim_name:StringName):
	if anim_name == out_anim_name:
		_real_respawn()
		animator.play(in_anim_name)

func setup(by:Node = self):
	setup_by = by
	 
	if not target: target = find_target()
	
	if target:
		position = target.global_position
		rotation = target.global_rotation

func _real_respawn():
	if not target: target = find_target()
	
	if target:
		target.global_position = position
		target.global_rotation = rotation
	else: push_warning("Could not respawn ", self, ": missing target.")

func is_respawning() -> bool: return (animator.current_animation == out_anim_name or animator.current_animation == in_anim_name) if animator else false
