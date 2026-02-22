extends Node3D

@export var shrine: Node3D

@onready var indicator = $Indicator as MeshInstance3D

var checking_shrine: Node3D
var my_material: Material

# Called when the node enters the scene tree for the first time.
func _ready():
	_make_material_unique.call_deferred()
	_setup_shrine.call_deferred()

func _make_material_unique():
	if !indicator or !is_instance_valid(indicator): return
	var material = indicator.mesh.surface_get_material(0)
	if !material: return
	
	my_material = material.duplicate()
	indicator.set_surface_override_material(0, my_material)

func _setup_shrine():
	if !shrine or !is_instance_valid(shrine): return
	if shrine == checking_shrine: return
	if checking_shrine and is_instance_valid(checking_shrine):
		if checking_shrine.returned_from_exit.is_connected(_on_shrine_returned):
			checking_shrine.returned_from_exit.disconnect(_on_shrine_returned)
	checking_shrine = shrine
	shrine.returned_from_exit.connect(_on_shrine_returned)

func _on_shrine_returned(_from_exit):
	set_active(true)

func set_active(active := false):
	if !my_material: return
	if my_material is StandardMaterial3D:
		my_material.emission_energy_multiplier = 15.0 if active else 0.0
