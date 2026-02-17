class_name RespawnBit3D extends Bit
## Provides functionality for respawning a Bot at a certain location.

var setup_by:Node

@export var global_kill:StringName = "" ## An optional group to recursively kill.
@export var delay := 0.0
var delay_time = 0.0
var should_kill := false

var position:Vector3
var rotation:Vector3

var target

func _ready() -> void: setup()

func respawn(group := global_kill) -> void:
	if group != "":
		for node in get_tree().get_nodes_in_group(global_kill):
			if node is Bot:
				var scan:Array[Bit] = node.scan_bot("RespawnBit3D")
				
				if len(scan) > 0: scan[0].respawn("")
	
	should_kill = true
	delay_time = delay
	

func find_target(with:Node = bot, depth := 5) -> Node3D:
	
	if depth == 0 or with == null: return null
	
	if with is Node3D: return with
	
	for child in with.get_children():
		if child is Node3D: return child
		
		var check = find_target(child, depth - 1)
		
		if check is Node3D: return check
	return null

func _process(delta: float) -> void:
	if not target: setup()
	
	if should_kill:
		
		delay_time = move_toward(delay_time, 0, delta)
		
		if delay_time <= 0:
			_real_respawn()
			should_kill = false

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
