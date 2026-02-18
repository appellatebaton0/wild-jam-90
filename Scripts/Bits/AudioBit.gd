class_name AudioBit extends Bit
## Makes an audio stream player run on a condition.

@export var target:Node
@export var condition:BoolValue
@export var on_true := false

var last_value
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: if condition and target:
	
	var value = condition.value()
	
	if on_true and last_value != value:
		last_value = value
		stream(value)
	else: stream(value)

func stream(play:bool): if target: 
	if not target.playing and play: target.play()
	elif   target.playing and not play: target.stop()
