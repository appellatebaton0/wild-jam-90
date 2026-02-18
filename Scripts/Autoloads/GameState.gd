extends Node

signal got_collectable(value: int)

var found_collectables := 0
var collectable_value := 0

func add_collectable(value: int):
	found_collectables += 1
	collectable_value += value
	got_collectable.emit(value)
