class_name HijackedAudioBit extends Bit
## An AudioPlayer that allows for hijacking its main track with another track,
## which it will fade to.

signal hijacked
signal resetted

@export var player:AudioStreamPlayer
@export var aud_stream:AudioStreamSynchronized

@export var transition_speed := 2.0

var current_index := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if not player:
		var me = self
		if me is AudioStreamPlayer:
			player = me
	
	if player: 
		print("AUD STREAM SET")
		player.stream = aud_stream
	
	if player.autoplay: player.play()

	
	print(player.stream)
	print(player.playing)
	print(player.autoplay)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not player.playing: player.play()
	## Manage the transition.
	for i in range(aud_stream.stream_count):
		
		var current_volume = aud_stream.get_sync_stream_volume(i)
		#if randf() > 0.7:
			#print(i, ": ", current_volume)
		#print(i, ": ", aud_stream.get_sync_stream(i))
		#print(player.playing)
		
		if i == current_index:
			aud_stream.set_sync_stream_volume(i, move_toward(current_volume, 0.0, delta))
		else:
			aud_stream.set_sync_stream_volume(i, move_toward(current_volume, -40.0, delta))

## Hijack the currently playing track with a new one.
func hijack(with): 
	
	if with is Array: if with[0] is AudioStream: 
		print("yep.")
		with = with[0]
	
	
	print("HIJACKED W/ ", with, " -> ", with as AudioStream)
	var a:AudioStream = with
	print(a, " -> ", a is AudioStream)
	if not with is AudioStream: return
	
	print("!")
	
	var created := -1
	
	for i in range(aud_stream.stream_count):
		if i == 0: continue # Don't replace the main track.
		if i == current_index: continue # Don't replace the currently playing track.
		if aud_stream.get_sync_stream_volume(i) > -40 and aud_stream.get_sync_stream(i): continue # Don't replace tracks that aren't faded out yet.
		
		## Replace the first open stream with this one.
		print("replacing i ", i, " with ", with)
		aud_stream.set_sync_stream(i, with)
		aud_stream.set_sync_stream_volume(i, -40.0)
		created = i
		break
	
	print("!!")
	
	## If no open stream was found, we gotta make a new one.
	if created == -1:
		aud_stream.set_sync_stream(aud_stream.stream_count + 1, with)
		aud_stream.set_sync_stream_volume(aud_stream.stream_count + 1, -40.0)
		created = aud_stream.stream_count + 1
	
	print("Hijacked ", created)
	
	current_index = created
	
	hijacked.emit()
	
	if not player.playing: player.play(player.get_playback_position())

## Reset the current stream target back to the main stream.
func reset() -> void: 
	
	print("RESET")
	
	current_index = 0
	
	resetted.emit()
