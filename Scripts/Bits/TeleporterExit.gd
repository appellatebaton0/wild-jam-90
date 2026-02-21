class_name TeleporterExitBit extends AreaMasterBit3D
## Teleports the activator back to the last-used TeleporterEntrance
## (that was set to be returnable to).

## If true, teleports a body immediately after entering rather than on input.
@export var teleport_on_enter := true

@onready var parent := get_tree().get_first_node_in_group("TeleporterParent")
var last_user:Node3D

## The action name for using the teleporter
@export var use_input:StringName
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
			
			warp() # Warp the user back to the teleporter entrance.
			
			animator.play("warp_out")


## Warp the user to the last-set TeleporterEntranceBit
func warp(): if last_user:
	
	parent.return_point.returned(self)
	var marker:Node3D = parent.return_point.locate_marker(parent.return_point)
	
	var target:Node3D = marker if marker else parent.return_point.area
	
	last_user.global_position = target.global_position
	last_user.global_rotation = target.global_rotation

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
