class_name SignalBool extends BoolValue

var response := false

func value() -> bool:
	if response:
		response = false
		return true
	else: return false

func activate() -> void:
	print("ACTIVATED", self)
	response = true

func arg_activate(_arg): activate()
