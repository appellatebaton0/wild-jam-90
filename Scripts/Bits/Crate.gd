class_name CrateBit extends Bit

@onready var player:Node3D = get_tree().get_first_node_in_group("Player")
@onready var rigid:RigidBody3D

var held_by:MoveMasterBit3D

const FREEZE_DISTANCE := 90.0

var interval := 0.0

func _ready() -> void:
	var me = self
	if me is RigidBody3D: rigid = me

func _process(delta: float) -> void:
	
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
		print(get_tree().get_nodes_in_group("Player"))
		return
	
	if interval <= 0.0:
		var set_freeze = player.global_position.distance_to(rigid.global_position) > FREEZE_DISTANCE
		
		if rigid.freeze != set_freeze:
			rigid.freeze = set_freeze
		interval = 3.0
	else: interval = move_toward(interval, 0, delta)

func _integrate_forces(state:PhysicsDirectBodyState3D): if held_by:
	state.transform.origin += held_by.attempt_velocity * state.get_step()

func mag(vec3:Vector3): return sqrt(pow(vec3.x, 2) + pow(vec3.y, 2) + pow(vec3.z, 2))

func being_pushed() -> bool: return (mag(held_by.attempt_velocity) > 0.7) if held_by else false 
