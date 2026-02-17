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
		if to != movement_state and AnimTree:
			_on_state_transition(movement_state, to)
			AnimTree.set("parameters/Movement/transition_request", to)
		movement_state = to

@export var wall_move_vector := Vector2(0.0, 0.0):
	set(to):
		wall_move_vector = to

var lerped_wall_move_vector := wall_move_vector
var tracked_position := self.global_position
var fire_direction := Vector3.UP

func _process(delta: float):
	RenderingServer.global_shader_parameter_set("player_position", self.global_position)
	
	tracked_position = lerp(tracked_position, self.global_position, 6.0 * delta);
	fire_direction = lerp(fire_direction, to_local(tracked_position) + Vector3.UP, 12.0 * delta)
	
	lerped_wall_move_vector = lerped_wall_move_vector.lerp(wall_move_vector, 0.1)
	if AnimTree:
		AnimTree.set("parameters/Wall_Movement/blend_position", lerped_wall_move_vector)
	
	if character_material:
		character_material.set_shader_parameter("vertex_fire_direction", fire_direction)

func play_animation(anim_name: String):
	if AnimTree.get(str("parameters/Play_", anim_name)):
		AnimTree.set(str("parameters/Play_", anim_name, "/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func stop_animation(anim_name: String):
	if AnimTree.get(str("parameters/Play_", anim_name)):
		AnimTree.set(str("parameters/Play_", anim_name, "/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

func _on_state_transition(state_from: String, state_to: String) -> void:
	if state_from == "Wall_Grab" and state_to == "Fall":
		play_animation("Wall_Jump")
	if state_to != "Fall":
		stop_animation("Wall_Jump")
