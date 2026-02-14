@tool
extends Node3D

#INFO it's a tool script to see animation changes in real time

@export var character_material: ShaderMaterial
@onready var AnimTree = $AnimationTree as AnimationTree
@export_enum(
	"Idle",
	"Walk",
	"Sprint",
	"Fall",
	"Push",
	"Pull",
	"Wall_Grab",
	) var movement_state := "Idle":
	set(to):
		if to != movement_state:
			AnimTree.set("parameters/Movement/transition_request", to)
		movement_state = to

var total_time := 0.0

var tracked_position := self.global_position
var fire_direction := Vector3.UP
var fire_strength := 0.5

func _process(delta: float):
	total_time += delta
	
	tracked_position = lerp(tracked_position, self.global_position, 6.0 * delta);
	fire_direction = lerp(fire_direction, to_local(tracked_position) + Vector3.UP, 12.0 * delta)
	
	fire_strength = 0.75 + (0.125 * sin(total_time * 1.0))
	
	if character_material:
		character_material.set_shader_parameter("vertex_fire_direction", fire_direction)
		character_material.set_shader_parameter("vertex_fire_strength", fire_strength)

func play_animation(anim_name: String):
	if AnimTree.has_animation(anim_name):
		AnimTree.set(str("parameters/Play_", anim_name, "request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
