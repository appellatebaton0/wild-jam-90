class_name CheckpointBit extends AreaBit3D

var respawn:RespawnBit3D

func on_body_entered(body:Node) -> void:
	if body is Bit:
		body = body.bot
		var scan:Array[Bit] = body.scan_bot(RespawnBit3D)
		
		if len(scan) > 0:
			respawn = scan[0]
			
			respawn.setup(self)

func is_current() -> bool: return (respawn.setup_by == self) if respawn else false
