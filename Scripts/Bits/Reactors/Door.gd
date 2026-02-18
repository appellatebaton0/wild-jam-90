class_name DoorBit extends Reactor
## A simple reactor to function as a door.

@export var easing := 1.0 ## The ease to use when moving.
@export var time := 1.0 ## How long moving between positions takes.
var timer := 0.0

@export var open_extent := Vector3(0, 5, 0)
var close_extent := Vector3.ZERO

var last:bool

var body:CharacterBody3D
var area:Area3D # An area to make sure the door doesn't close in the player's face.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var parent = get_parent()
	if parent is CharacterBody3D: body = parent
	if parent is Area3D:          area = parent
	
	var me = self
	if me is CharacterBody3D: body = me
	if me is Area3D:          area = me
	
	for child in get_children():
		if child is CharacterBody3D and not body: body = child
		if child is Area3D          and not area: area = child
	
	find_condition()
	

var value
var to:Vector3
var from:Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	value = (condition.value() if condition else true) or area.has_overlapping_bodies()
	
	if value != last:
		last = value
		timer = time - timer
	
	to   = open_extent  if value else close_extent
	from = close_extent if value else open_extent
	
	body.position = lerp(to, from, ease(timer / time, easing))
	
	timer = move_toward(timer, 0.0, delta)

func is_moving() -> bool: return body.position != to and body.position != from
