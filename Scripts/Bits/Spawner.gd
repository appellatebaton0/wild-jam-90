class_name SpawnerBit extends Bit
## Spawns nodes from PackedScenes, with configurable intervals.

## The node to add new spawns to.
@export var parent:NodeValue
## The PackedScene to use
@export var scene:PackedSceneValue
## The position to spawn the nodes at
@export var spawn_position:VectorValue
## The rotation to spawn the nodes with (degrees).
@export var spawn_rotation:FloatValue

## The interval between spawns.
@export var interval:FloatValue
var current_interval := -1.0 ## The current interval. When the timer reaches this, it's updated by [interval] and the timer is reset.
var timer := 0.0

## Sets a limit on how many times the node can be spawned; -1 is infinite.
@export var total_spawn_limit := -1
var total_spawns := 0
## Sets a limit on how many nodes spawned by this spawner can exist at once; -1 is infinite.
@export var concurrent_spawn_limit := -1
var spawns:Array[Node]

## Attempt to create a new node.
func spawn_new():
	# Define the variables 
	var parent_v:Node
	var scene_v:PackedScene
	var position_v
	var rotation_v
	
	# Setup the scene value.
	if scene != null:
		scene_v = scene.value()
	if scene_v == null:
		push_error(self, " FAILED: NO SCENE")
		return "NO SCENE"
	
	# Make the node
	var new:Node = scene_v.instantiate()
	
	if new == null:
		push_error(self, " FAILED: NO NODE")
		return "NO NODE"
	
	# Set the parent
	if parent != null:
		parent_v = parent.value()
	else:
		parent_v = self
	
	if parent_v == null:
		push_error(self, " FAILED: NO PARENT")
		return "NO PARENT"
	
	# Set the position value
	if spawn_position != null:
		position_v = spawn_position.value()
		
		# Modify it if possible
		if (position_v is Vector2 and bot.is_class("Node2D")) or (position_v is Vector3 and bot.is_class("Node3D")):
			position_v += bot.global_position
	
	# Set the rotation value
	if spawn_rotation != null:
		rotation_v = spawn_rotation.value()
		
		# Modify it if possible
		if (rotation_v is float and bot.is_class("Node2D")) or (rotation_v is Vector3 and bot.is_class("Node3D")):
			rotation_v += bot.global_rotation
	
	
	
	match new.get_class():
		"Node2D":
			# Set defaults
			if position_v == null:
				position_v = self.global_position if is_class("Node2D") else Vector2.ZERO
			if rotation_v == null:
				rotation_v = self.global_position if is_class("Node2D") else 0.0
			
			
		"Node3D":
			# Set defaults
			if position_v == null:
				position_v = self.global_position if is_class("Node3D") else Vector3.ZERO
			if rotation_v == null:
				rotation_v = self.global_position if is_class("Node3D") else Vector3.ZERO
	
	
	# Now that all the values FINALLY exist, make and return the node;
	parent_v.add_child(new)
	
	if new is Node2D or new is Node3D:
		new.global_position = position_v
		new.rotation = rotation_v
	
	total_spawns += 1
	spawns.append(new)
	
	
	if parent_v == null:
		push_error(self, " FAILED TO SPAWN NODE: NO PARENT")

## Try to get a new interval.
func renew_interval() -> void:
	if interval != null:
		var val = interval.value()
		if val != null:
			current_interval = val

## Whether not the spawner can make a new node currently.
func can_spawn() -> bool:
	var real_spawns:Array[Node]
	
	for spawn in spawns:
		if is_instance_valid(spawn):
			real_spawns.append(spawn)

	spawns = real_spawns
	
	
	if len(spawns) >= concurrent_spawn_limit and not concurrent_spawn_limit == -1:
		return false
	
	if total_spawns >= total_spawn_limit and not total_spawn_limit == -1:
		return false
	return true

func _ready() -> void:
	renew_interval()
	
	timer = current_interval

func _process(delta: float) -> void:
	
	if current_interval >= 0 and can_spawn(): # If a valid interval exists
		
		timer = move_toward(timer, 0, delta)
		
		if timer <= 0:
			spawn_new()
			
			renew_interval()
			
			timer = current_interval
		
