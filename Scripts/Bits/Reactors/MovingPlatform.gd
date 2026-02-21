@tool
class_name MovingPlatformBit extends Reactor
## A reactor that moves between a number of points when active.

const POINT_SCENE := preload("res://Scenes/MovingPlatformPoint.tscn")

@export_tool_button("New Point") var new_point := create_new_point
@export_tool_button("Clear Points") var clear_all := clear_points

@export_tool_button("Reset") var reset := _reset

@export var move_in_editor := true ## Whether or not to animate in-editor
@export var muted := false

## How the platform cycles through its points if it has a condition, and that condition is false.
## || Pause: The platform will stop cycling once it reaches its next point.
## || Return: The platform will cycle backwards through its points until it reaches the beginning point.
## || Once: The platform will continue cycling through its points until it reaches the beginning.
@export_enum(&"Pause", &"Return", &"Once") var disabled_mode: String = &"Pause"

@export var points:Array[PlatformPoint] = get_points()
var index_direction := 1

@export var _print_debug := false

var node:Node3D
var current_index = 0
var next_index    = 0

var current_point:PlatformPoint
var next_point   :PlatformPoint

var timer := 0.0
var pause := 0.0
var moving := false

var passed_once := true

func _ready() -> void:
	
	var me = self
	node = me
	
	if muted: $AudioStreamPlayer3D.volume_db = -90.0
	else:     $AudioStreamPlayer3D.volume_db = 0.0
	
	_reset()

func _physics_process(delta: float) -> void: if len(points) > 0:
	
	if Engine.is_editor_hint() and not move_in_editor: return
	
	for point in points: if not is_instance_valid(point): points.erase(point)
	if not current_point or not next_point: return
	
	if pause <= 0.0:
		if current_index > len(points) - 1: current_index = 0
		
		if timer > 0.0:
			var ease_alpha: float = ease((current_point.time - timer) / current_point.time, current_point.easing)
			var lerped_transform: Transform3D = lerp(current_point.node.global_transform, next_point.node.global_transform, ease_alpha)
			node.global_transform = lerped_transform.scaled_local(node.scale)
			timer = move_toward(timer, 0.0, delta)
		
		moving = timer != 0.0
		
		if timer == 0.0:
			var next_direction = _evaluate_condition_direction()
			if next_direction == 0: return
			
			cycle_points(next_direction)
			
			timer = current_point.time
			
			pause = current_point.after_wait
	else:
		var point_transform: Transform3D = current_point.node.global_transform.scaled_local(node.scale)
		node.global_transform = point_transform
		pause = move_toward(pause, 0, delta)
		

func cycle_points(index_direction_override: int = index_direction):
	if len(points) <= 1:
		current_index = 0
		current_point = points[0] if len(points) > 0 else null
		next_point = null
		return
	
	if _print_debug:
		print("| BEFORE ")
		print("C: ", current_index, " | N: ", next_index, " | O: ", index_direction_override)
	
	if current_index == 0 and next_index == 0 and index_direction_override == 1:
		current_index = 0
		next_index = 1
	else:
		current_index = (current_index + index_direction_override)
		next_index = (current_index + index_direction_override)
		
		var point_count = len(points)
		current_index = clampmod(current_index, point_count)
		next_index = clampmod(next_index, point_count)
	
	#if current_index < 0:
		#current_index = abs(current_index)
	#
	#
	
	if _print_debug:
		print("| AFTER ")
		print("C: ", current_index, " | N: ", next_index, " | O: ", index_direction_override)
		print("--------------------")
	
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
	
	var point_transform = Transform3D(node.global_basis, node.global_position)
	new.global_transform = point_transform
	new.name = name + "'s " + str(len(points))
	
	return new

func clear_points():
	
	for point in points:
		point.queue_free()
	points.clear()
	
	create_new_point()

func _evaluate_condition_direction() -> int:
	var direction := index_direction
	if condition and is_instance_valid(condition):
		if Engine.is_editor_hint():
			return direction
		if condition.value():
			passed_once = false
			return direction
		match disabled_mode:
			&"Pause":
				return 0
			&"Return":
				if next_index > 0:
					return -direction
				return 0
			&"Once":
				if !passed_once and next_index > 0:
					return direction
				elif !passed_once:
					passed_once = true
				return 0
	
	return direction
	

func clampmod(x: int, _max: int) -> int:
	return maxi(0, x % _max)

func absmod(x: int, _max: int) -> int:
	if x < 0:
		x = _max - (abs(x) % _max)
	return x % _max

func _reset():
	find_condition()
	
	## Make a point at the current position if none exist.
	if len(points) == 0: create_new_point()
	
	passed_once = true
	timer = 0.0
	# I don't know why this exact sequence of numbers works
	# but I'm not going to question it for another eternity
	
	current_index = 0
	if len(points) > 2:
		current_index = len(points) - 2
	next_point = null
	cycle_points()
	if next_point and next_point.node:
		var point_transform = next_point.node.global_transform
		node.global_transform = point_transform.scaled_local(node.scale)
