class_name PressurePlateBit extends Actor

## How long the plate will stay down for after it's no longer activated.
@export var weight_time := 0.0
var weight_timer := 0.0

var area:Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var parent = get_parent()
	if parent is Area3D and not area: area = parent
	
	var me = self
	if me is Area3D and not area: area = me
	
	for child in get_children():
		if child is Area3D and not area: area = child


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if area.has_overlapping_bodies(): weight_timer = weight_time
	else: weight_timer = move_toward(weight_timer, 0, delta)
	
	value = weight_timer > 0 or area.has_overlapping_bodies()
