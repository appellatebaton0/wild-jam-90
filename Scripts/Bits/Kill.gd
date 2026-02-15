class_name KillBit extends Bit
## Kills a target Bot (if possible) when a condition becomes true.

@export var target:Bot ## The target to kill.
@export var condition:BoolValue ## The condition upon which the target is killed.

@export var pulse := true ## Whether to only kill the target once when the condition is met.

var activated:bool = false

var respawner:RespawnBit3D

func _ready() -> void:
	if not condition:
		# Try the parent is an actor.
		var parent = get_parent()
		if parent is Actor:
			condition = ActorBool.new()
			condition.actor = parent
	
	if not condition:
		for child in get_children(): if child is BoolValue:
			condition = child
			break
	
	## Find the target's respawner.
	find_respawner()

func _process(_delta: float) -> void: if condition:
	
	if condition.value():
		if not activated or not pulse: # Kill the target.
			kill()
		activated = true
	else: activated = false

func kill():
	if not respawner: find_respawner()
	if respawner: respawner.respawn()

func find_respawner():
	
	if target:
		if target is Bit: target = target.bot
		
		var scan = target.scan_bot("RespawnBit3D")
		
		if len(scan) > 0: respawner = scan[0]
