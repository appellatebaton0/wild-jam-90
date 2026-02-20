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

@export var extinguish_target := 0.0
var _extinguish_time := 0.1
var _extinguish_lerped := extinguish_target

var lerped_wall_move_vector := wall_move_vector
@onready var tracked_position := self.global_position
var fire_direction := Vector3.UP

func _process(delta: float):
	if !visible: return
	
	RenderingServer.global_shader_parameter_set("player_position", self.global_position + Vector3(0, 1.0, 0))
	
	tracked_position = lerp(tracked_position, self.global_position, 6.0 * delta);
	fire_direction = lerp(fire_direction, to_local(tracked_position) + Vector3.UP, 12.0 * delta)
	
	RenderingServer.global_shader_parameter_set("player_movement", self.global_position - tracked_position)
	lerped_wall_move_vector = lerped_wall_move_vector.lerp(wall_move_vector, 0.1)
	if AnimTree:
		AnimTree.set("parameters/Wall_Movement/blend_position", lerped_wall_move_vector)
	
	_extinguish_lerped = move_toward(_extinguish_lerped, extinguish_target, delta / _extinguish_time)
	
	if character_material:
		character_material.set_shader_parameter("vertex_fire_direction", fire_direction)
		character_material.set_shader_parameter("extinguish", _extinguish_lerped)

func play_animation(anim_name: String):
	AnimTree.set(str("parameters/Play_", anim_name, "/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func stop_animation(anim_name: String):
	AnimTree.set(str("parameters/Play_", anim_name, "/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

func set_extinguish(to: float, time := 0.1):
	extinguish_target = to
	_extinguish_time = time

func _on_state_transition(state_from: String, state_to: String) -> void:
	if state_from == "Wall_Grab" and state_to == "Fall":
		play_animation("Wall_Jump")
	if state_to != "Fall":
		stop_animation("Wall_Jump")
