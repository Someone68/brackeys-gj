extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RoomManager.host = $RoomHost
	RoomManager.player = $Player
	RoomManager.goto("town_square")
	Global.dialog_node = $DialogBox
	Global.dialog_initialized = true
	$CanvasLayer/HUD.init(CaseState.current)

func _exit_tree() -> void:
	if Global.dialog_node == $DialogBox:
		Global.dialog_initialized = false
		Global.dialog_node = null
