extends Node3D


@export_subgroup("Incomplete Visuals", "_incomplete")
@export var _incomplete_color: Color = Color(1.0, 0.514, 0.545, 1.0)
@export var _incomplete_energy := 8.0
@export_subgroup("Complete Visuals", "_complete")
@export var _complete_color: Color = Color(0.6, 0.837, 0.78, 1.0)
@export var _complete_energy := 6.0
@export var tween_time := 5.0

@onready var shrine = $"Shrine/Plane_002" as MeshInstance3D
@onready var shrine_material: StandardMaterial3D = shrine.mesh.surface_get_material(0)

var tween_alpha := 0.0
var is_shrine_complete := false
var current_tween: Tween

func _ready():
	_make_material_unique.call_deferred()

func _make_material_unique():
	shrine_material = shrine_material.duplicate()
	shrine.set_surface_override_material(0, shrine_material)

func _on_shrine_returned(_from_point: Node3D):
	if is_shrine_complete: return
	set_complete(true)

func set_complete(complete := false):
	is_shrine_complete = complete
	if current_tween and is_instance_valid(current_tween):
		current_tween.kill()
	
	var tween_to = 1.0 if complete else 0.0
	var time_modifier = abs(tween_to - tween_alpha) / 1.0
	
	current_tween = create_tween()
	current_tween.tween_method(_tween_material, tween_alpha, tween_to, tween_time * time_modifier)
	

func _tween_material(alpha: float):
	shrine_material.emission_energy_multiplier = lerp(_incomplete_energy, _complete_energy, tween_alpha)
	shrine_material.emission = lerp(_incomplete_color, _complete_color, alpha)
	tween_alpha = alpha
	
