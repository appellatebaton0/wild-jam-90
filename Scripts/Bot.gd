class_name Bot extends Node
## A node that has completely modular functionality :D

@warning_ignore("unused_signal") signal freeing
func bot_free():
	freeing.emit()
	call_deferred("queue_free")

func bot_free_val(_x):
	bot_free()

## Finds the certain instance of a kind of bit in a bot.
func scan_bot(for_class:Variant, include_self := true) -> Array[Bit]:
	return _get_sub_bit(for_class, include_self)

## Get any bits in the children, using a class_name.
func _get_sub_bit(bit_class:Variant, include_self, depth := 4, with:Node = self) -> Array[Bit]:
	
	if depth <= 0:
		return []
	
	
	var results:Array[Bit]
	
	# If can return self and self works, do that.
	if include_self and is_instance_of(self, bit_class):
		results.append(self)
		
	# Otherwise, look in the children recursively
	for child in with.get_children():
		# Try this child, first.
		if child is Bit:
			# If its class_name matches, return it.
			if is_instance_of(child, bit_class) and child.get_bot() == self:
				results.append(child)
		
		# Else, run this function for each Bit child, with one less recursion so it's not infinite.
		var attempt = _get_sub_bit(bit_class, true, depth - 1, child)
		
		# If anything is found, return that.
		if attempt != null:
			results.append_array(attempt)
	
	return results
