extends CanvasLayer

var dialog_visible := false

func show_dialog(text: String, speed: float = 0.04, pause_multiplers := [2.5, 3]):
	dialog_visible = true
	$Control/Text.text = ""
	$Control.visible = true
	for c in text:
		$Control/Text.text += c
		var wait_time = speed
		if (c in [';', ',', ':']):
			wait_time *= pause_multiplers[0]
		elif (c in ['.', '?', '!']):
			wait_time *= pause_multiplers[1]
		await get_tree().create_timer(wait_time).timeout

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and dialog_visible:
		dialog_visible = false
		$Control.visible = false
