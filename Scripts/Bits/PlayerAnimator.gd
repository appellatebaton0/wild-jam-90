class_name PlayerAnimatorBit extends Bit
## Plays an animation from an AnimationPlayer when given a signal :D

## The animation to play.
@export var animation := ""

## Optional, the location of the AnimationPlayer to use. Otherwise, will look for one by itself.
@export var player:NodeValue
var anim_player:AnimationPlayer

## Look for an AnimationPlayer in the children, siblings, piblings, etc.
func search_player(with:Node, depth:int = 7) -> AnimationPlayer:
	# If this happens, no player was found :(
	if depth <= 0 or with == null:
		return null
	
	# Search the children for a player
	for child in with.get_children():
		if child is AnimationPlayer:
			return child
	
	# Move up one layer in the hierarchy and search again.
	return search_player(with.get_parent(), depth - 1)

func _ready() -> void:
	if player == null:
		for child in get_children():
			if child is NodeValue:
				player = child

	if player != null:
		var p_node = player.value()
		if p_node is AnimationPlayer:
			anim_player = p_node
	
	if anim_player == null:
		anim_player = search_player(self)

func animate():
	if anim_player != null:
		anim_player.play(animation)
