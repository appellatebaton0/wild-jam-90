class_name HijackedAudioBit extends Bit
## An AudioPlayer that allows for hijacking its main track with another track,
## which it will fade to.

signal hijacked
signal resetted

@export var players:Array[AudioStreamPlayer]
@export var transition_speed := 4.0

@export var current_index := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for child in get_children(): 
		if child is AudioStreamPlayer and not players.has(child):
			players.append(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for player in players:
		# Fade in the current track, and out everything else.
		if players.find(player) == current_index:
			player.volume_db = move_toward(player.volume_db,   0.0, delta * transition_speed)
		else:
			player.volume_db = move_toward(player.volume_db, -40.0, delta * transition_speed)

## Hijack the currently playing track with a new one.
func hijack(with:AudioStream): 
	
	var player = find_open_player()
	
	player.stream = with
	player.volume_db = -40.0
	player.play()
	
	current_index = players.find(player)
	
	hijacked.emit()

## Reset the current stream target back to the main stream.
func reset() -> void: 
	current_index = 0
	
	resetted.emit()

func find_open_player() -> AudioStreamPlayer:
	
	## Look for players that either aren't playing, or are silent.
	for player in players:
		if players.find(player) == 0: continue # Skip the first one, the base track.
		if not player.playing or player.volume_db == -40.0:
			return player # Found one!
	
	# If one isn't found, we gotta make a new one.
	var new = AudioStreamPlayer.new()
	
	add_child(new)
	players.append(new)
	
	return new
	
