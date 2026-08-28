extends Control

func _on_button_pressed() -> void:
	CaseState.start(load("res://data/test_case.tres"))
	GameFlow.go(GameFlow.State.TOWN)
