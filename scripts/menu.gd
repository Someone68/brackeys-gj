extends Control

func _ready() -> void:
	$Buttons/PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	GameFlow.go(GameFlow.State.CASE_SELECT)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
