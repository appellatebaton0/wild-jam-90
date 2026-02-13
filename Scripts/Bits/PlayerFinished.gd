class_name PlayerFinishedBit extends Bit
## Emits a signal when the given AnimationPlayer completes the given animation.

## The signal emitted when the given animation finishes.
signal finished

## The AnimationPlayer to use.
@export var player:NodeValue
var anim_player:AnimationPlayer
## The animation to detect finishing.
@export var animation:String

## Look for an AnimationPlayer in the children, siblings, piblings, etc.
func search_player(with:Node, depth:int = 4) -> AnimationPlayer:
	# If this happens, no player was found :(
	if depth <= 0:
		return null
	
	# Search the children for a player
	for child in with.get_children():
		if child is AnimationPlayer:
			return child
	
	# Move up one layer in the hierarchy and search again.
	return search_player(with.get_parent(), depth - 1)

func _ready() -> void:
	if player != null:
		var p_node = player.value()
		if p_node is AnimationPlayer:
			anim_player = p_node
	
	if anim_player == null:
		anim_player = search_player(self)
	
	if anim_player != null:
		anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name:StringName):
	if anim_name == animation:
		finished.emit()
	
