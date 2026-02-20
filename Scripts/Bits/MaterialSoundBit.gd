@tool
class_name MaterialSoundBit extends Bit
## Plays sound on a loop depending on the material of a Terrain3D

@export_tool_button("Reload Streams") var reload := reload_streams

@export_global_dir var a_stream_directories:Array[String]
@export_global_dir var b_stream_directories:Array[String]
@export var a_streams:Array[AudioStream]
@export var b_streams:Array[AudioStream]

@export var player:AudioStreamPlayer3D
@export var ray:RayCast3D
@export var terrain_node:NodeValue
var terrain_data:Terrain3DData

@export var condition:BoolValue
@export var switch_condition:BoolValue
@export var speed_modifier:FloatValue

var interval = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void: if not Engine.is_editor_hint(): get_terrain_data()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: if not Engine.is_editor_hint():
	
	if not terrain_data: get_terrain_data()
	
	if terrain_data and ray and player:
		
		var should_play = condition.value() if condition else true
		var speed_mod = max(speed_modifier.value(), 0.1) if speed_modifier else 1.0
		
		if not should_play or not ray.is_colliding(): return
		
		var tex_data = terrain_data.get_texture_id(ray.get_collision_point())
		var new_index = get_index_from_texture_data(tex_data, 0.7)
		
		var streams = a_streams if (switch_condition.value() if switch_condition else true) else b_streams
		
		if len(streams) >= new_index and not player.playing: 
			player.stream = streams[new_index]
		
		if interval <= 0:
			player.play()
			interval = 1.0
		interval = move_toward(interval, 0, 0.4 * speed_mod * delta)

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

## Turn a directory into a AudioStreamRandomizer
func make_stream(of:String) -> AudioStreamRandomizer: 
	var stream := AudioStreamRandomizer.new()
	
	var dir = DirAccess.open(of)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var file = load(of + "/" + file_name)
				
				if file is AudioStream:
					stream.add_stream(-1, file, 1.0)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return stream

func reload_streams():
	
	a_streams.clear()
	for directory in a_stream_directories:
		a_streams.append(make_stream(directory))
	
	b_streams.clear()
	for directory in b_stream_directories:
		b_streams.append(make_stream(directory))
