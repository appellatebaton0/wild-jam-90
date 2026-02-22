class_name PressurePlateBit extends Actor

## If true, the plate won't release once activated.
@export var stay_pressed := false
## How long the plate will stay down for after it's no longer activated.
@export var weight_time := 0.0
var weight_timer := 0.0

@export var animation_player: AnimationPlayer
@export var press_anim_name := "Press"
@export var release_anim_name := "Release"

var press_lock := false
var was_active := false

var area:Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var parent = get_parent()
	if parent is Area3D and not area: area = parent
	
	var me = self
	if me is Area3D and not area: area = me
	
	for child in get_children():
		if child is Area3D and not area: area = child

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var is_pressed = area.has_overlapping_bodies()
	if is_pressed and stay_pressed:
		press_lock = true
	
	var is_active = is_pressed or press_lock
	if !stay_pressed:
		if is_pressed:
			weight_timer = weight_time
		elif weight_time > 0.0:
			weight_timer = move_toward(weight_timer, 0.0, delta)
			is_active = weight_timer > 0.0
	
	if animation_player:
		if is_active and !was_active:
			animation_player.play(press_anim_name, 0.1)
		elif !is_active and was_active:
			animation_player.play(release_anim_name, 0.1)
	
	was_active = is_active
	value = is_active
