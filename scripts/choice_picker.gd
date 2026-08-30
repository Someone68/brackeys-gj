class_name ChoicePicker
extends CanvasLayer
signal on_select (selected_choice : String)

## labels are one line with no wrap, so long options would run off the panel.
## shrink the font just for those until they fit the space left of the border.
const LABEL_WIDTH := 284.0
const MIN_FONT_SIZE := 7

var selected := 0
var active := false
var current_choices := []

@onready var choice_items := [
	$Control/Choice1,
	$Control/Choice2,
	$Control/Choice3,
	$Control/Choice4,
]

@onready var select_items := [
	$Select1,
	$Select2,
	$Select3,
	$Select4,
]

func activate(choices: Array[String], default : int = 0):
	if (active == true): return
	current_choices = choices
	Global.choice_visible = true
	active = true
	selected = clampi(default, 0, choices.size() - 1)
	for i in choice_items.size():
		if i < choices.size():
			choice_items[i].text = choices[i]
			_fit(choice_items[i])
			choice_items[i].visible = true
		else:
			choice_items[i].visible = false
			select_items[i].visible = false
	
	await get_tree().process_frame
	var res = await on_select
	Global.choice_visible = false
	queue_free()
	return res

func _fit(label: Label) -> void:
	var font := label.get_theme_font("font")
	var size: int = label.get_theme_font_size("font_size")
	while size > MIN_FONT_SIZE and \
			font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > LABEL_WIDTH:
		size -= 1
	label.add_theme_font_size_override("font_size", size)


func _process(_delta: float) -> void:
	if not active: return
	var last := current_choices.size() - 1
	if (Input.is_action_just_pressed("down")):
		choice_items[selected].modulate.b = 255
		select_items[selected].visible = false
		selected += 1
		if (selected > last): selected = 0
	elif(Input.is_action_just_pressed("up")):
		choice_items[selected].modulate.b = 255
		select_items[selected].visible = false
		selected -= 1
		if (selected < 0): selected = last
	
	choice_items[selected].modulate.b = 0
	select_items[selected].visible = true
	
	if (Input.is_action_just_pressed("interact")):
		on_select.emit(current_choices[selected])
