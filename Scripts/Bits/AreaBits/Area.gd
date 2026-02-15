@abstract class_name AreaBit extends Bit
## Provides functionality to be run by an AreaMaster, with its own mask that has to be met ALONGSIDE the one from the AreaMaster.

@warning_ignore("unused_signal") signal area_entered ## Emitted when an area enters this AreaBit
@warning_ignore("unused_signal") signal body_entered ## Emitted when a body enters this AreaBit
@warning_ignore("unused_signal") signal area_exited ## Emitted when an area exits this AreaBit
@warning_ignore("unused_signal") signal body_exited ## Emitted when a body exits this AreaBit

var overlapping_bodies:Array[Node] 
var overlapping_areas:Array[Node]

## Run when a body / area enters the Master
func on_body_entered(_body:Node) -> void:
	pass
func on_area_entered(_area:Node) -> void:
	pass

## Run when a body / area exits the Master
func on_body_exited(_body:Node) -> void:
	pass
func on_area_exited(_area:Node) -> void:
	pass

## Always run; effectively _process with inputs for overlapping bodies / areas.
func while_overlapping_bodies(_delta:float) -> void:
	pass
func while_overlapping_areas(_delta:float) -> void:
	pass

func has_overlapping_bodies() -> bool: return len(overlapping_bodies) > 0
func has_overlapping_areas()  -> bool: return len(overlapping_areas)  > 0
