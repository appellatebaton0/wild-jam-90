class_name AudioBit extends Bit
## Makes an audio stream player run on a condition.

@export var target:Node
@export var condition:BoolValue
@export var on_true := false

@export var volume_transition_time := 0.0

var initial_volume := 0.0
var last_value

func _ready():
	if target:
		initial_volume = target.volume_linear

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: if condition and target:
	if initial_volume <= 0.0:
		return
	
	var value = condition.value()
	#var play = last_value != value if on_true else true
	
	if volume_transition_time > 0.0:
		target.volume_linear = move_toward(target.volume_linear, initial_volume if value else 0.0, (1.0 / volume_transition_time) * delta)
	
	if value or volume_transition_time == 0.0:
		play_stream(value)
	elif !value: # volume transition time > 0
		if target.volume_linear == 0.0:
			play_stream(value)
	

func play_stream(play:bool): if target: 
	if on_true and play == last_value:
		return
	
	last_value = play
	
	if not target.playing and play: target.play()
	elif   target.playing and not play: target.stop()
	
