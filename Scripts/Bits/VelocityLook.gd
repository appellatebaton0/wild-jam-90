class_name VelocityLook extends Bit

# The MoveMaster to make look at its current velocity.
@export var master:MoveMasterBit3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void: if not master:
	var parent = get_parent()
	if parent is MoveMasterBit3D: master = parent


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mov = master.mover
	var tar = mov.global_position + mov.velocity if not mov.is_on_wall_only() else mov.global_position - mov.get_wall_normal()
	
	# Only update the look if it does something.
	if not mov.global_position.cross(tar).is_zero_approx() and abs(mov.velocity.normalized().y) != 1.0:
		mov.look_at(tar)
	mov.rotation.x = 0.0
	
	# There'll likely need to be something here to let the rotation stop happening while on the walls...
