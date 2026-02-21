class_name TerrainAudioBit extends Bit
## Plays a different track based on the terrain detected by a ray.

@export var player:AudioStreamPlayer
var aud_stream:AudioStreamSynchronized

@export var ray:RayCast3D
@export var terrain_node:NodeValue
var terrain_data:Terrain3DData

var last_index := 0

## How fast to transition between tracks
@export var transition_speed := 0.6
## How long to wait before switching audios after the terrain switches.
## To prevent switching rapidly.
@export var transition_threshold := 2.0
var transition_score := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	get_terrain_data()
	aud_stream = player.stream
	
	for i in range(aud_stream.stream_count):
		aud_stream.set_sync_stream_volume(i, -60.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: 
	
	if not terrain_data: get_terrain_data()
	
	if terrain_data and ray:
		
		if ray.is_colliding():
			var tex_data = terrain_data.get_texture_id(ray.get_collision_point())
			var new_index = get_index_from_texture_data(tex_data, 0.7)
			
			if new_index != last_index:
				transition_score += delta
				if transition_score > transition_threshold:
					last_index = new_index
			else: transition_score = 0.0
		print(transition_speed, " - ", transition_score, " - ", last_index)
		transition_speed = 8.0
		for i in range(aud_stream.stream_count):
			
			var vol = aud_stream.get_sync_stream_volume(i)
			
			if i == last_index:
				aud_stream.set_sync_stream_volume(i, move_toward(vol, 0.0, delta * transition_speed))
			else:
				aud_stream.set_sync_stream_volume(i, move_toward(vol, -40.0, delta * transition_speed))
		
func get_index_from_texture_data(tex_data: Vector3, switch_margin := 0.5) -> int:
	if tex_data != tex_data:
		# when tex_data is NaN
		return 0
	if tex_data.x != tex_data.y:
		#print("Base: ", tex_data.x, " Overlay: ", tex_data.y, " Blend: ", tex_data.z)
		return int(tex_data.x) if tex_data.z < switch_margin else int(tex_data.y)
	return int(tex_data.x)

func get_terrain_data(): 
	if terrain_node:
		var terrain = terrain_node.value()
		
		if terrain is Terrain3D:
			terrain_data = terrain.data
