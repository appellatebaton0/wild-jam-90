@abstract class_name Bit extends Bot
## A bot with extended functionality, that can pass that functionality 
## off to its parent if that parent is an Bot.

## Whether to use this Bit as the Bot, instead of only doing so if all else fails.
## Cuts off the hierarchy, basically.
@export var isolated := false

## The bot to pass the functionality off to.
@onready var bot:Bot = get_bot()
func get_bot(with:Node = self) -> Bot:
	if isolated or with == null:
		return self
	
	# Search up through the hierarchy
	with = with.get_parent()
	
	if with is Bot: 
		
		if not with is Bit:
			return with
		elif with.isolated:
			return with
	
	return get_bot(with)
