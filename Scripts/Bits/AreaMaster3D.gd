class_name AreaMasterBit3D extends Bit
## Provides an Area3D for AreaBits, and handles their ability to have their own layers :D

func get_area() -> Area3D:
	var me = self
	if me is Area3D:
		return me
	
	var parent = get_parent()
	if parent is Area3D:
		return parent
	
	return null
@onready var area:Area3D = get_area()

## Compares two ints to see if their binary matches, pretty much.
## Effectively, lets you plug in a collision_layer and collision_mask to see if they collide.
func layer_match(layer:int, mask:int) -> bool:
	
	for i in range(32): # For all 32 layers
		# If the layer node is on this layer and the mask node is checking for it...
		
		# NOTE: These operations are what's going on in get_collision_layer(),
		# A bitwise AND and a bitshift.
		var matches_layer = bool(layer & (1 << i))
		var matches_mask = bool(mask & (1 << i))
		
		if matches_layer and matches_mask:
			return true # Return true!
	return false # If no matches were found, return false :(

## Mask an array of collision objects to just the ones that match a mask.
func mask_objects(objects:Array[CollisionObject3D], mask:int) -> Array[Node]:
	var response:Array[Node]
	
	for object in objects:
		if layer_match(object.collision_layer, mask):
			response.append(object)
	
	return response

## But not in a bad way. Return the array's CollisionObjects.
func objectify(array:Array) -> Array[CollisionObject3D]:
	var response:Array[CollisionObject3D]
	
	for node in array:
		if node is CollisionObject3D:
			response.append(node)
	
	return response

## Get all the child and sibling AreaBit3Ds that need to be informed.
func get_area_bits() -> Array[AreaBit3D]:
	var response:Array[AreaBit3D]
	
	## Reply with any children
	for child in get_children():
		if child is AreaBit3D:
			response.append(child)
	
	## Reply with any siblings
	for child in get_parent().get_children():
		if child is AreaBit3D:
			response.append(child)
	
	return response
@onready var area_bits:Array[AreaBit3D] = get_area_bits()

func _ready() -> void:
	if area != null:
		area.area_entered.connect(_on_area_entered)
		area.body_entered.connect(_on_body_entered)
		
		area.area_exited.connect(_on_area_exited)
		area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if area != null:
		# All the currently overlapping Area3Ds
		var overlapping_areas:Array[Area3D] = area.get_overlapping_areas()
		# All the currently overlapping PhysicsBodies and Tilesets
		var overlapping_bodies:Array[Node3D] = area.get_overlapping_bodies()
		
		# Handle all the AreaBits
		for bit in area_bits:
			# Get the areas & bodies overlapping with this.
			# NOTE: this will ignore Tilesets :[
			var o_areas = mask_objects(objectify(overlapping_areas), bit.collision_mask)
			var o_bodies = mask_objects(objectify(overlapping_bodies), bit.collision_mask)
			
			# Pass them on to the relevant functions, along with delta :)
			bit.while_overlapping_areas(delta)
			bit.while_overlapping_bodies(delta)
			
			bit.overlapping_areas = o_areas
			bit.overlapping_bodies = o_bodies

## When an area enters, tell any bits that are listening (have the right mask)
func _on_area_entered(area_in:Area3D):
	for bit in area_bits:
		if layer_match(area_in.collision_layer, bit.collision_mask):
			bit.on_area_entered(area_in)
			bit.area_entered.emit()
## When a body enters, tell any bits that are listening (have the right mask)
func _on_body_entered(body_in: Node3D):
	for bit in area_bits:
		if layer_match(body_in.collision_layer, bit.collision_mask):
			bit.on_body_entered(body_in)
			bit.body_entered.emit()

## When an area leaves, tell any bits that are listening (have the right mask)
func _on_area_exited(area_out:Area3D):
	for bit in area_bits:
		if layer_match(area_out.collision_layer, bit.collision_mask):
			bit.on_area_exited(area_out)
			bit.area_exited.emit()
## When a body leaves, tell any bits that are listening (have the right mask)
func _on_body_exited(body_out:Node3D):
	for bit in area_bits:
		if layer_match(body_out.collision_layer, bit.collision_mask):
			bit.on_body_exited(body_out)
			bit.body_exited.emit()
