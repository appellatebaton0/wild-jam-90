class_name MoveMasterBit3D extends Bit
## Meant for a CharacterBody, provides a basis for movement
## This is a state machine!

## The node to use for rotating controlled movement correctly; the camera. 
@export var rotator:ManualNode

@export var mover:CharacterBody3D

@export var initial_bit:MoveBit
var current_bit:MoveBit

var direction:Vector3

## All the childed bits.
@onready var bits:Array[MoveBit] = get_move_bits()
func get_move_bits() -> Array[MoveBit]:
	var response_bits:Array[MoveBit]
	
	# Append any children that are MoveBits.
	for child in get_children():
		if child is MoveBit: if not child.isolated:
			response_bits.append(child)
	
	# Append any siblings that are MoveBits.
	for child in get_parent().get_children():
		if child is MoveBit: if not child.isolated:
			response_bits.append(child)
	
	return response_bits

## Change the current_bit to another.
func change_bit(to:MoveBit):
	# Run the going-out function for the old bit
	if current_bit != null:
		current_bit.on_inactive()
	
	# Change to the new bit
	current_bit = to
	
	# Run the going-in function for the new bit!
	if current_bit != null:
		current_bit.on_active()

func _ready() -> void:
	# Set mover2D
	if mover == null:
		var parent = get_parent()
		if parent is CharacterBody3D:
			mover = parent
	if mover == null:
		var me = self
		if me is CharacterBody3D:
			mover = me
	
	if initial_bit == null and len(bits) > 0:
		initial_bit = bits[0]
	
	if initial_bit != null:
		change_bit(initial_bit)

func _process(delta: float) -> void:
	# Run all bits' appropriate functions.
	for bit in bits:
		# If it's always running, or is the one that should be.
		if not bit.exclusive or bit == current_bit:
			bit.active(delta)
		else:
			bit.inactive(delta)

func _physics_process(delta: float) -> void:
	# Run all bits' appropriate functions.
	for bit in bits:
		# If it's always running, or is the one that should be.
		if not bit.exclusive or bit == current_bit:
			bit.phys_active(delta)
		else:
			bit.phys_inactive(delta)
	
	## Run on mover
	if mover != null:
		mover.move_and_slide()
		# Pass to the bot.
		if bot.is_class("Node3D"):
			bot.global_position = mover.global_position
			mover.position = Vector3.ZERO

func real_dir() -> Vector3: return direction if direction else mover.velocity.normalized()
