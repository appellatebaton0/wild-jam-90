@abstract class_name Bit extends Bot
## A bot with extended functionality, that can pass that functionality 
## off to its parent if that parent is an Bot.

## Whether to use this Bit as the Bot, instead of only doing so if all else fails.
## Cuts off the hierarchy, basically.
@export var isolated := false

## The bot to pass the functionality off to.
@onready var bot:Bot = get_bot()
func get_bot() -> Bot:
	
	if isolated:
		return self
	
	# Search up through the hierarchy
	var with = get_parent()
	
	for i in range(3):
		if with is Bit:
			return with.bot
		elif with is Bot:
			return with
		else:
			with = with.get_parent()
	
	return self

## Scanning for a bit returns any results from the bot this bit belongs to.
func scan_bot(for_id:String, include_self := true) -> Array[Bit]:
	return bot._get_sub_bit(for_id, include_self)
