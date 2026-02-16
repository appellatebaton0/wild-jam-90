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
func _ready() -> void: if not Engine.is_editor_hint():
	print("TN",terrain_node)
	get_terrain_data()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: if not Engine.is_editor_hint():
	#print(terrain_data, ray, player)
	
	if not terrain_data: get_terrain_data()
	
	if terrain_data and ray and player:
		
		var should_play = condition.value() if condition else true
		var speed_mod = max(speed_modifier.value(), 0.1) if speed_modifier else 1.0
		
		if not should_play or not ray.is_colliding(): return
		
		var new_index = terrain_data.get_texture_id(ray.get_collision_point()).x
		
		var streams = a_streams if (switch_condition.value() if switch_condition else true) else b_streams
		
		if len(streams) >= new_index and not player.playing: 
			player.stream = streams[new_index]
		
		print(interval)
		if interval <= 0:
			print("playing ", player.stream)
			print(speed_mod)
			player.play()
			interval = 1.0
		interval = move_toward(interval, 0, 0.4 * speed_mod * delta)

func get_terrain_data(): 
	if terrain_node:
		var terrain = terrain_node.value()
		
		print(get_tree().get_first_node_in_group("Terrain"))
		
		print(terrain)
		
		if terrain is Terrain3D:
			terrain_data = terrain.data

## Turn a directory into a AudioStreamRandomizer
func make_stream(of:String) -> AudioStreamRandomizer: 
	var stream := AudioStreamRandomizer.new()
	print("made stream: ", stream)
	
	var dir = DirAccess.open(of)
	print("opened ", dir, " from ", of)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				print("loading... ", of + "/"+file_name)
				var file = load(of + "/" + file_name)
				
				if file is AudioStream:
					print("Was filestream, adding.")
					stream.add_stream(-1, file, 1.0)
					print("added.")
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	print("finished, returning.")
	return stream

func reload_streams():
	
	a_streams.clear()
	for directory in a_stream_directories:
		a_streams.append(make_stream(directory))
	
	b_streams.clear()
	for directory in b_stream_directories:
		b_streams.append(make_stream(directory))
