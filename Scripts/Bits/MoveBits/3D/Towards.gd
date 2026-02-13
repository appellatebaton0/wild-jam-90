class_name TowardsBit3D extends MoveBit3D
## Moves this bot in a straight line towards another bot.

## How fast the bot gets up to top speed / turns, per second.
@export var acceleration := 20.0
## How fast the bot can move.
@export var max_speed := 10.0

## The node to follow after.
@export var target:NodeValue

func _ready() -> void:
	if target == null:
		for child in get_children():
			if child is NodeValue:
				target = child
				break

func phys_active(delta:float) -> void:
	if target != null:
		var node = target.value()
		if node is Node3D:
			var direction = master.mover.global_position.direction_to(node.global_position)
			
			master.mover.velocity = vec3_move_towards(master.mover.velocity, direction * max_speed, acceleration * delta)
