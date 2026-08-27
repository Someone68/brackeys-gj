extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RoomManager.host = $RoomHost
	RoomManager.player = $Player
	RoomManager.goto(CaseState.current.start_room)
