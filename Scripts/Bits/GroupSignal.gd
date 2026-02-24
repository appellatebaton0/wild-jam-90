class_name GroupSignalBit extends Bit
## Funnels a signal from every node in a group into a single signal.

signal emitted

@export var group_name := &""
@export var signal_name := &""

## Skips any nodes already connected.
var node_cache:Array[Node]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: if group_name and signal_name:
	
	var group = get_tree().get_nodes_in_group(group_name)
	
	for node in group: 
		if node_cache.has(node): continue ## Skip already connected nodes.
		
		
		# Connect the signal.
		if node.has_signal(signal_name):
			print("connected ", node)
			node.connect(signal_name, _on_signal)
		
		if node.is_connected(signal_name, _on_signal):
			node_cache.append(node)

## Pass the signal on.
func _on_signal(...args): 
	print("emitted w/ ", args)
	emit_signal("emitted", args)
