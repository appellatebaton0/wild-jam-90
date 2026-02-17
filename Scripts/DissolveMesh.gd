class_name DissolveMesh
extends MeshInstance3D

@export var dissolve_material: ShaderMaterial
## How long it takes (in seconds) to fully dissolve the mesh.
@export var dissolve_time := 0.5;
## Enable when you expect multiple of these meshes to be dissolved at the same time.
@export var duplicate_material_on_ready := false;
@onready var initial_material := self.mesh.surface_get_material(0)

var current_tween: Tween;

func _ready():
	if duplicate_material_on_ready:
		_set_unique_dissolve_material.call_deferred()

func _set_unique_dissolve_material():
	dissolve_material = dissolve_material.duplicate();
	#play_dissolve_tween(true)

## INFO this function is what you want to call
func play_dissolve_tween(dissolved := false):
	if !dissolve_material:
		return
	
	var dissolve_to := 1.0 if dissolved else 0.0
	var dissolve_from : float = dissolve_material.get_shader_parameter("dissolve")
	var dissolve_duration : float = abs(dissolve_to - dissolve_from) * dissolve_time
	
	if is_equal_approx(dissolve_from, dissolve_to):
		return
	
	if current_tween and is_instance_valid(current_tween):
		current_tween.kill()
	
	self.mesh.surface_set_material(0, dissolve_material)
	current_tween = create_tween()
	current_tween.tween_method(_set_dissolve, dissolve_from, dissolve_to, dissolve_duration)
	current_tween.tween_callback(_switch_dissolve_material.bind(dissolved)).set_delay(dissolve_duration)

func _set_dissolve(dissolve_amount: float) -> void:
	dissolve_material.set_shader_parameter("dissolve", dissolve_amount)

func _switch_dissolve_material(dissolved: bool) -> void:
	var switch_to = dissolve_material if dissolved else initial_material
	self.mesh.surface_set_material(0, switch_to)
	#
	#await get_tree().create_timer(0.5).timeout
	#play_dissolve_tween(!dissolved)
