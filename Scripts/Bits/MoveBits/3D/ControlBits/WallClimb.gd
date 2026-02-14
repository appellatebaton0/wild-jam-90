class_name WallClimb extends MoveBit3D
## Allows a controllable Bot to dash up a wall.

@export var input:InputValue ## The input that activates the dash.
@export var climb_speed := 200.0 ## The upwards velocity applied.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if not input:
		for child in get_children(): if child is InputValue:
			input = child
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func phys_active(delta:float) -> void:
	if input:
		if input.value(): _on_input_pressed(delta)
	else: _on_input_pressed(delta)

func _on_input_pressed(delta:float) -> void: if master.mover.is_on_wall_only():
	
	## Climb.
	master.mover.velocity.y = max(master.mover.velocity.y, climb_speed * delta)
	
	## Stick to the wall while climbing.
	master.mover.velocity.x = -master.mover.get_wall_normal().x
	
