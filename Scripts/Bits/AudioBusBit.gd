class_name AudioBus extends Bit

@export var bar:Range
@export var label:Label

@export var bus_name:StringName

func _ready() -> void:
	bar.value_changed.connect(_on_value_changed)
	bar.value = bar.max_value / 2
	_on_value_changed(bar.value)

func _on_value_changed(to:float): 
	print("!")
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), to - (bar.max_value / 2))
	
	label.text = str(to - (bar.max_value / 2))
	
	
