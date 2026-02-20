class_name KillBit extends Bit
## Kills a target Bot (if possible) when a condition becomes true.

signal killing

## The target to kill.
@export var target:Bot
## The condition upon which the target is killed.
@export var condition:BoolValue
## Whether to only kill the target once when the condition is met.
@export var pulse := true

var activated:bool = false

var respawner:RespawnBit3D

@onready var parent = get_parent()
func _ready() -> void:
	if parent is AreaMasterBit3D:
		
		var a = Property.new()
		a.property = "has_overlapping_bodies()"
		var b = CastBool.new()
		b.input = a
		var c = ManualNode.new()
		c.response = parent
		
		a.from = c
		
		condition = b
	
	if not condition:
		# Try the parent is an actor.
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
	
	if parent is AreaMasterBit3D: target = parent.area.get_overlapping_bodies()[0] if parent.area.has_overlapping_bodies() else null
	
	if condition.value():
		if not activated or not pulse: # Kill the target.
			kill()
		activated = true
	else: activated = false

func kill():
	killing.emit()
	
	if not respawner: find_respawner()
	if respawner: respawner.respawn()
	
	if parent is AreaMasterBit3D:
		respawner = null
		target = null
	

func find_respawner():
	
	if target:
		if target is Bit: target = target.bot
		
		var scan = target.scan_bot("RespawnBit3D")
		
		if len(scan) > 0: respawner = scan[0]
