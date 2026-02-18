extends Node3D

@export var anim_tween_duration := 0.5
@export var fire_meshes: Array[MeshInstance3D]
@export var fire_strengths: Array[float] = []

@export var lights: Array[OmniLight3D]

@export var burning := true:
	set(value):
		burning = value
		_update_fire_fx()

# keep values
var was_burning = true
var is_ready = false

var light_energies: Dictionary[int, float] = {}
var fire_materials: Array[ShaderMaterial] = []
var tweens: Dictionary[int, Tween] = {}
var tween_alphas: Dictionary[int, float] = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for mesh in fire_meshes:
		var fire_material: ShaderMaterial = mesh.mesh.surface_get_material(0).duplicate()
		mesh.set_surface_override_material(0, fire_material)
		fire_materials.append(fire_material)
	for light_idx in lights.size():
		light_energies[light_idx] = lights[light_idx].light_energy
	is_ready = true
	_update_fire_fx.call_deferred()

func _update_fire_fx():
	if !is_ready: return
	if was_burning == burning:
		return
	
	was_burning = burning
	for idx: int in fire_materials.size():
		var mesh = fire_meshes[idx]
		mesh.show()
		
		if tweens.has(idx):
			if tweens[idx] and is_instance_valid(tweens[idx]):
				tweens[idx].kill()
		
		if !tween_alphas.has(idx):
			tween_alphas[idx] = 1.0 if !burning else 0.0
		
		tweens[idx] = mesh.create_tween()
		tweens[idx].tween_method(_update_tween.bind(idx), tween_alphas[idx], 1.0 if burning else 0.0, anim_tween_duration)
		
		await get_tree().create_timer(anim_tween_duration, false).timeout
		if burning:
			mesh.show()
		else:
			mesh.hide()

func _update_tween(alpha: float, idx: int):
	var mesh = fire_meshes[idx]
	var material = fire_materials[idx]
	
	if light_energies.has(idx):
		lights[idx].light_energy = light_energies[idx] * alpha
	
	tween_alphas[idx] = alpha
	mesh.transparency = 1.0 - alpha
	material.set_shader_parameter("vertex_fire_strength", alpha * fire_strengths[idx])
