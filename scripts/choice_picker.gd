class_name ChoicePicker
extends CanvasLayer
signal on_select (selected_choice : String)

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
	current_choices = choices
	if (active == true): return
	Global.choice_visible = true
	active = true
	selected = default
	for i in choice_items.size():
		var item = choice_items[i]
		item.text = choices[i]
	
	var res = await on_select
	Global.choice_visible = false
	queue_free()
	return res

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("down")):
		choice_items[selected].modulate.b = 255
		select_items[selected].visible = false
		selected += 1
		if (selected > 3): selected = 0
	
	elif(Input.is_action_just_pressed("up")):
		choice_items[selected].modulate.b = 255
		select_items[selected].visible = false
		selected -= 1
		if (selected < 0): selected = 3
	
	choice_items[selected].modulate.b = 0
	select_items[selected].visible = true
	
	if (Input.is_action_just_pressed("interact")):
		on_select.emit(current_choices[selected])
