class_name ManualPackedScene extends PackedSceneValue
## Returns a given PackedScene.

## The PackedScene to respond with.
@export var response:PackedScene

func value() -> PackedScene:
	return response
