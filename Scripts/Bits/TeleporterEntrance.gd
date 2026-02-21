class_name TeleporterEntranceBit extends AreaMasterBit3D # The master can handle all the Area3D stuff, for the most part
## Creates a scene at a certain point, and teleports the activator to that scene.

signal returned_from_exit(from: Node3D)

@onready var parent := get_tree().get_first_node_in_group("TeleporterParent")

## If true, teleports a body immediately after entering rather than on input.
@export var teleport_on_enter := false

## Whether all exits will point back to this once it's used.
@export var is_return_point := true

## The path to the scene that the activator will be teleported to.
@export_file("*.tscn") var scene_path:String
@onready var scene := load(scene_path)
var instance:Node3D ## The currently created scene, if one exists.
var last_user:Node3D ## The last node to "use" this teleporter

## The action name for using the teleporter
@export var use_input:StringName

## Where to put the instantiated scene. Don't mess w/ this unless you know you need to.
@export var spawn_position := Vector3(0, -50, 0)
## The group name of the teleporter exits.
@export var exit_group_name := &"TeleporterExit"
## The group name of the teleporter entrances.
@export var entrance_group_name := &"TeleporterEntrance"
@export var animator:AnimationPlayer

var warping := false
var colliding_bodies: Dictionary[Node, bool] = {}

func _ready() -> void:
	if area:
		area.area_entered.connect(_on_area_entered)
		area.body_entered.connect(_on_body_entered)
		
		area.area_exited.connect(_on_area_exited)
		area.body_exited.connect(_on_body_exited)
	if animator:
		animator.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void: if InputMap.has_action(use_input):
	$Label3D.visible = area.has_overlapping_bodies() and not teleport_on_enter
	
	if teleport_on_enter:
		return
	
	## The user is trying to, well, use this teleporter.
	if area.has_overlapping_bodies() and Input.is_action_just_pressed(use_input):
		last_user = area.get_overlapping_bodies()[0]
		_do_warp(last_user)

func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"warp_in": 
			# Do everything that'll happen halfway through the transition. 
			
			warp() # Load the scene and warp the user to it.
			notify_teleporters() # Tell the other teleporters whatever they need to know.
			
			animator.play("warp_out")
		"warp_out":
			pass

## Warp the user to a fresh instance of the scene.
func warp():
	
	## Create an instance, and look for the marker in it.
	var marker := locate_marker(spawn())
	
	if last_user:
		var user_position := marker.global_position if marker else spawn_position
		var user_rotation := marker.global_rotation if marker else last_user.global_rotation
		
		last_user.global_position = user_position
		last_user.global_rotation = user_rotation
	
	warping = false
	

## Spawn in a fresh instance of the scene, and return it.
func spawn() -> Node3D:
	
	despawn() # Unload any existing instance.
	
	var new:Node3D = scene.instantiate()
	
	parent.add_child(new)
	new.global_position = spawn_position
	
	instance = new
	
	return new

func despawn(): 
	if instance: 
		instance.queue_free()
		instance = null

## Search for a Marker3D as a child of the node.
func locate_marker(with:Node = instance, depth := 5) -> Marker3D:
	
	if depth == 0: return null
	if with is Marker3D: return with
	
	for child in with.get_children():
		var check = locate_marker(child, depth - 1)
		if check: return check
	
	return null

func notify_teleporters(): 
	for exit in get_tree().get_nodes_in_group(entrance_group_name): if exit is TeleporterEntranceBit:
		exit.instance = instance
	
	if not is_return_point: return
	
	parent.return_point = self

func returned(from_exit: TeleporterExitBit):
	returned_from_exit.emit(from_exit)

func _do_warp(user: Node3D):
	warping = true
	last_user = user
	if animator:
		animator.play("warp_in")
	else:
		warp()

func _on_body_entered(body_in: Node3D):
	if teleport_on_enter and !warping:
		if !colliding_bodies.has(body_in) or !colliding_bodies[body_in]:
			_do_warp(body_in)
		colliding_bodies[body_in] = true
	super._on_body_entered(body_in)

func _on_body_exited(body_out:Node3D):
	if teleport_on_enter:
		colliding_bodies[body_out] = false
	super._on_body_exited(body_out)
