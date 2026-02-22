class_name CameraModifier extends Bit

@export var target:ManualNode

var goal_pos: Vector3
var goal_rot: Vector3
var or_rot:Vector3
var or_pos:Vector3

@export var easing := 1.0 ## The ease to use when moving.
@export var time := 1.0 ## How long moving between positions takes.
var timer := 0.0

@export var active:bool = true
func set_active(to:bool):
	if to:
		timer = time
	active = to


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !active: return
	
	timer = move_toward(timer, 0.0, delta)
	
