extends Node

var dialog_visible := false
var dialog_initialized := false
var dialog_node : CanvasLayer
var choice_visible := false
var notes_visible := false
var notes : String = ""
const CHOICE_PICKER := preload("res://scenes/choice_picker.tscn")

func show_dialog(dialogue: Array, speed: float = 0.02, pause_multipliers := [4.5, 6], wait_for_input := true, title := "") -> void:
	while not dialog_initialized:
		await get_tree().process_frame
	await dialog_node.show_dialog(dialogue, speed, pause_multipliers, wait_for_input, title)

func show_choices(choices: Array[String], default : int = 0, root := NodePath("Root")):
	var picker: ChoicePicker = CHOICE_PICKER.instantiate()
	var root_node = get_node_or_null(root)
	if root_node == null:
		root_node = get_tree().current_scene
	root_node.add_child(picker)
	return await picker.activate(choices, default)
