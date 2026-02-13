@abstract class_name AreaBit3D extends AreaBit
## Acts like an Area2D, with extendable functionality.
## needs to be a child of an AreaMasterBit2D to work.

## The collision mask of this bit - layers on top of the AreaMasterBit's mask.
## (ie, the master AND this bit need to have true for a layer to mask for it.)
@export_flags_3d_physics var collision_mask := 0
