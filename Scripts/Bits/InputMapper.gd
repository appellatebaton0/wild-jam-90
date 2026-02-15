class_name InputMapperBit extends Bit

@export var event_name:StringName
@export var display_name:StringName

@onready var input_mapper := %InputButton
@onready var label := %Label

var monitoring = false

var controller_inputs:Array[StringName] = [
	"LT", "RT", "RB", "LB", "Menu", "Back",
	"D-pad Up", "D-pad Left", "D-pad Right", "D-pad Down",
	"Axis 0", "Axis 1", "Axis 2", "Axis 3",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_mapper.pressed.connect(_on_pressed)
	label.text = display_name
	
	input_mapper.text = text_from_event(InputMap.action_get_events(event_name)[0])

func _on_pressed():
	monitoring = true
	pass

func _input(event: InputEvent) -> void:
	
	if monitoring and not event is InputEventMouseMotion:
		input_mapper.text = text_from_event(event)
		
		
		
		# Clear the existing events for an action.
		print(InputMap.action_get_events(event_name)[0])
		print(event)
		InputMap.action_erase_events(event_name)
		InputMap.action_add_event(event_name, event)
		
		monitoring = false

func text_from_event(event:InputEvent) -> String:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		for input in controller_inputs:
			if event.as_text().contains(input):
				return input
		
		## For X, Y, A, B since they're too common
		var t = event.as_text()
		return t.replace(t.left(t.find("Xbox") + 4), "").left(2)
	return  event.as_text().replace(" - Physical", "")
