class_name AudioBus extends Bit

@export var bar:Range
@export var label:Label
@export var title:Label

@export var bus_name:StringName
var bus_idx := 0

func _ready() -> void:
	_setup_audio_and_slider.call_deferred()

func _setup_audio_and_slider():
	title.text = bus_name
	bus_idx = AudioServer.get_bus_index(bus_name)
	bar.value_changed.connect(_on_value_changed)
	var current_volume = AudioServer.get_bus_volume_linear(bus_idx)
	current_volume -= fmod(current_volume, bar.step)
	bar.value = current_volume
	_on_value_changed(current_volume)

func _on_value_changed(to:float):
	AudioServer.set_bus_volume_linear(bus_idx, to)
	label.text = str(to)
