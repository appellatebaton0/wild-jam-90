@tool
class_name MovingPlatformBit extends Reactor
## A reactor that moves between a number of points when active.

const POINT_SCENE := preload("res://Scenes/MovingPlatformPoint.tscn")

@export_tool_button("New Point") var new_point := create_new_point
@export_tool_button("Clear Points") var clear_all := clear_points

@export_tool_button("Reset") var reset := _ready

@export var move_in_editor := true ## Whether or not to animate in-editor

@export var points:Array[PlatformPoint] = get_points()
var index_direction = 1

var node:Node3D
var current_index = 0
var next_index    = 0

var current_point:PlatformPoint
var next_point   :PlatformPoint

var timer := 0.0
var pause := 0.0

func _ready() -> void:
	
	find_condition()
	
	var me = self
	node = me
	
	if not Engine.is_editor_hint():
		current_index = 0
		timer = 0.0
	
	## Make a point at the current position if none exist.
	
	if len(points) == 0: create_new_point()
	
	current_index = 1
	cycle_points()

func _process(delta: float) -> void: if len(points) > 0:
	
	if Engine.is_editor_hint() and not move_in_editor: return
	
	for point in points: if not is_instance_valid(point): points.erase(point)
	if not current_point or not next_point: return
	
	if pause <= 0.0:
		if current_index > len(points) - 1: current_index = 0
		
		var from:Vector3 = current_point.node.global_position
		var to  :Vector3 = next_point.node.global_position
		
		node.global_position = lerp(from, to, ease((current_point.time - timer) / current_point.time, current_point.easing))
		
		var from_rot:Vector3 = current_point.node.global_rotation
		var to_rot  :Vector3 = next_point.node.global_rotation
		
		node.global_rotation = lerp(from_rot, to_rot, ease((current_point.time - timer) / current_point.time, current_point.easing))
		
		timer = move_toward(timer, 0.0, delta)
		
		var value = condition.value() if condition and not Engine.is_editor_hint() else true
		if timer == 0.0 and value:
			cycle_points()
			
			timer = current_point.time
			
			pause = current_point.after_wait
	else: 
		node.global_position = current_point.global_position
		node.global_rotation = current_point.global_rotation
		pause = move_toward(pause, 0, delta)
		

func cycle_points():
	current_index = (current_index + index_direction)       % len(points)
	next_index    = (current_index + (2 * index_direction)) 		% len(points)
	
	current_point = next_point if next_point else points[current_index]
	next_point = points[next_index]
	


func get_points() -> Array[PlatformPoint]:
	var response:Array[PlatformPoint]
	
	for child in get_children(): if child is PlatformPoint:
		response.append(child)
	
	return response

func create_new_point() -> PlatformPoint:
	
	# NEW POINT
	var new = POINT_SCENE.instantiate()
	
	get_parent().add_child(new)
	new.owner = owner
	
	points.append(new)
	
	new.global_position = node.global_position
	new.name = name + "'s " + str(len(points))
	
	return new

func clear_points():
	
	for point in points:
		point.queue_free()
	points.clear()
	
	create_new_point()
