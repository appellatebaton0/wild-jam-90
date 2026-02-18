class_name Burnable
extends Node3D

## INFO copies material in surface material override/0
## and assumes it's a shader material for magic_dissolve.gdshader

@export var burn_meshes: Array[MeshInstance3D]
@export var burn_time := 4.0
@export var burn_brightness_addition := 15.0

var burn_default_dissolve: Array[float]
var burn_default_brightness: Array[float]

var burn_materials: Array[ShaderMaterial]
var active_tweens: Dictionary[int, Tween] = {}

var burnt := false

func _ready():
	_duplicate_materials.call_deferred()

func _duplicate_materials():
	for mesh in burn_meshes:
		var material = mesh.get_surface_override_material(0).duplicate() as ShaderMaterial
		mesh.set_surface_override_material(0, material)
		burn_default_brightness.append(material.get_shader_parameter("dissolve_brightness"))
		burn_default_dissolve.append(material.get_shader_parameter("dissolve"))
		burn_materials.append(material)

func play_dissolve_tween(dissolved := false, dissolve_time_override: float = 0.0):
	if burn_meshes.size() < 1:
		return
	
	var time = dissolve_time_override if dissolve_time_override > 0.0 else burn_time
	
	for idx in burn_meshes.size():
		var burn_material = burn_materials[idx]
		var burn_to := 1.0 if dissolved else 0.0
		var burn_from : float = burn_material.get_shader_parameter("dissolve")
		burn_from -= burn_default_dissolve[idx]
		burn_from /= 1.0 - burn_default_dissolve[idx]
		var burn_duration : float = abs(burn_to - burn_from) * time
		
		if is_equal_approx(burn_from, burn_to):
			continue
		if active_tweens.has(idx) and is_instance_valid(active_tweens[idx]):
			active_tweens[idx].kill()
		
		active_tweens[idx] = burn_meshes[idx].create_tween()
		active_tweens[idx].tween_method(_set_dissolve.bind(idx), burn_from, burn_to, burn_duration)

func _set_dissolve(burn_amount: float, idx: int) -> void:
	var burn_material = burn_materials[idx]
	var dissolve_brightness = scale_alpha(burn_amount, burn_default_brightness[idx], burn_default_brightness[idx] + burn_brightness_addition)
	var dissolve_scaled = scale_alpha(burn_amount, burn_default_dissolve[idx], 1.0)
	burn_material.set_shader_parameter("dissolve_brightness", dissolve_brightness)
	burn_material.set_shader_parameter("dissolve", dissolve_scaled)
	

func scale_alpha(alpha: float, _min: float, _max: float) -> float:
	return _min + (alpha * (_max - _min));

func burnable_collided(_body: Node3D):
	if !burnt:
		burnt = true
		play_dissolve_tween(true)
