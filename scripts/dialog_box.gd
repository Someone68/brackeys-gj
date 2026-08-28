extends CanvasLayer

var _skip_requested := false

func _input(event: InputEvent) -> void:
	if Global.dialog_visible and event.is_action_pressed("cancel"):
		_skip_requested = true
		get_viewport().set_input_as_handled()

func show_dialog(dialogue: Array, speed: float = 0.01, pause_multipliers := [2.5, 3], wait_for_input := true, title := ""):
	if (Global.dialog_visible):
		while Global.dialog_visible:
			await get_tree().process_frame
	Global.dialog_visible = true
	$Control.visible = true
	_skip_requested = false
	if (title.length() > 0):
		$Control/TitlePanel.visible = true
		$Control/TitlePanel/Label.text = title
	for text in dialogue:
		$Control/Text.text = ""
		for c in text:
			if _skip_requested:
				$Control/Text.text = text
				break
			$Control/Text.text += c
			var wait_time = speed
			if (c in [';', ',', ':']):
				wait_time *= pause_multipliers[0]
			elif (c in ['.', '?', '!']):
				wait_time *= pause_multipliers[1]
			await get_tree().create_timer(wait_time).timeout
		$Icon.visible = true
		_skip_requested = false
		
		if wait_for_input:
			await get_tree().process_frame
			while not Input.is_action_just_pressed("interact"):
				await get_tree().process_frame
		
		$Icon.visible = false
	
	Global.dialog_visible = false
	$Control.visible = false
	$Control/TitlePanel.visible = false

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("interact") and dialog_visible:
		#dialog_visible = false
		#$Control.visible = false
		#$Icon.visible = false
