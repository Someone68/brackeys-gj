extends Control

func _on_button_pressed() -> void:
	CaseState.start(load("res://data/case_2.tres"))
	GameFlow.go(GameFlow.State.TOWN)
