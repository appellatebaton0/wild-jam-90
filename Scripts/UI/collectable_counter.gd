extends Node

@export var amount_label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.got_collectable.connect(_update_label)

func _update_label(_amount_added: int):
	if amount_label:
		amount_label.text = str(GameState.collectable_value)
