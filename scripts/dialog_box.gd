extends CanvasLayer

var dialog_visible := false
var _skip_requested := false

func _input(event: InputEvent) -> void:
	if dialog_visible and event.is_action_pressed("cancel"):
		_skip_requested = true
		get_viewport().set_input_as_handled()

func show_dialog(dialogue: Array, speed: float = 0.04, pause_multiplers := [2.5, 3]):
	dialog_visible = true
	$Control.visible = true
	_skip_requested = false
	for text in dialogue:
		$Control/Text.text = ""
		for c in text:
			if _skip_requested:
				$Control/Text.text = text
				break
			$Control/Text.text += c
			var wait_time = speed
			if (c in [';', ',', ':']):
				wait_time *= pause_multiplers[0]
			elif (c in ['.', '?', '!']):
				wait_time *= pause_multiplers[1]
			await get_tree().create_timer(wait_time).timeout
		$Icon.visible = true
		_skip_requested = false
		
		while not Input.is_action_just_pressed("interact"):
			await get_tree().process_frame
		
		$Icon.visible = false
	
	dialog_visible = false
	$Control.visible = false

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("interact") and dialog_visible:
		#dialog_visible = false
		#$Control.visible = false
		#$Icon.visible = false
