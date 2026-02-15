class_name CheckpointBit extends AreaBit3D

var player:Bot

func on_body_entered(body:Node) -> void:
	if body is Bot:
		player = body
	
	var scan := player.scan_bot("RespawnBit3D")
	
	if len(scan) > 0:
		var respawn:RespawnBit3D = scan[0]
		
		respawn.setup()
