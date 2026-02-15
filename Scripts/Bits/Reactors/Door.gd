class_name DoorBit extends Reactor
## A simple reactor to function as a door.

@export var lerp_speed := 0.06

@export var open_extent := Vector3(0, 5, 0)
var close_extent := Vector3.ZERO

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
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var value = condition.value() if condition else true
	
	body.position = lerp(body.position, open_extent if value or area.has_overlapping_bodies() else close_extent, lerp_speed)
