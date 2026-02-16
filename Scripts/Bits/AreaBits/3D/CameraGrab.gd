class_name CameraGrab extends AreaBit3D
## On collision, attempts to steal the camera from the collided body
## (Don't worry, I'll give it back).

@export var easing := 1.0 ## The ease to use when moving.
@export var time := 1.0 ## How long moving between positions takes.
var timer := 0.0

var held_by:Node

var previous_owner:Node
var camera:Camera3D

var pivot:CameraFloat

var grab_node:Node3D

var start_position:Vector3
var start_rotation:Vector3

func _ready() -> void:
	var me = self
	if me is Node3D:
		grab_node = me
	
	grab_node.visible = false

func _process(delta: float) -> void: if camera:
	
	camera.global_position = lerp(grab_node.global_position, start_position, ease(timer/time, easing))
	camera.global_rotation = lerp(grab_node.global_rotation, start_rotation, ease(timer/time, easing))
	
	print(camera.global_position, " as ", start_position, " and ", grab_node.global_position, " and ", ease(timer/time, easing))
	
	timer = move_toward(timer, 0, delta)
	

func on_body_entered(body:Node) -> void:
	if body is Bit: body = body.bot
	
	if body is Bot: ## This MAY have the camera.
		
		## Find the camera via a recursive search.
		camera = search_for_camera(body)
		
		## Find a camera pivot if one exists.
		pivot = body.scan_bot("CameraFloat")[0]
		
		print("! -> ", camera)
		
		if camera:
			held_by = body
			
			if pivot: pivot.active = false
			previous_owner = camera.get_parent()
			
			camera.reparent(self)
			
			start_position = camera.global_position
			start_rotation = camera.global_rotation
			
			timer = time

func on_body_exited(body:Node) -> void:
	if body is Bit: body = body.bot
	
	if body == held_by: ## Left to pick its camera back up
		camera.reparent(previous_owner)
		
		if pivot: pivot.active = true
		
		camera = null
		pivot = null


func search_for_camera(with:Node, depth := 5) -> Camera3D:
	
	if depth == 0: return null
	
	if with is Camera3D: return with
	
	for child in with.get_children():
		var check = search_for_camera(child, depth - 1)
		
		if check: return check
	
	return null
