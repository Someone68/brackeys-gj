extends Node

var dialog_visible := false
var dialog_initialized := false
var dialog_node : CanvasLayer

func show_dialog(dialogue: Array, speed: float = 0.04, pause_multipliers := [2.5, 3], wait_for_input := true):
	while not dialog_initialized:
		await get_tree().process_frame
	dialog_node.show_dialog(dialogue, speed, pause_multipliers, wait_for_input)
