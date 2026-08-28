extends Control

func _on_button_pressed() -> void:
	GameFlow.go(GameFlow.State.CASE_SELECT)
