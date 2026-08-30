extends Control

const CASE_PATHS := [
	"res://data/case_1.tres",
	"res://data/case_2.tres",
	"res://data/case_3.tres",
]

var cases: Array[CaseData] = []
var selected: int = -1

@onready var buttons: Array[Button] = [$Case1, $Case2, $Case3]

func _ready() -> void:
	for i in CASE_PATHS.size():
		var data: CaseData = load(CASE_PATHS[i])
		cases.append(data)
		buttons[i].text = "%d. %s" % [i + 1, data.title]
		buttons[i].pressed.connect(_on_case_pressed.bind(i))
	_show_info(-1)

func _on_case_pressed(i: int) -> void:
	selected = i
	$StartButton.disabled = false
	for j in buttons.size():
		buttons[j].set_pressed_no_signal(j == i)
	_show_info(i)

func _show_info(i: int) -> void:
	if i < 0:
		$Panel/CaseInfo.text = "Pick a case from the list."
		return
	var data := cases[i]
	$Panel/CaseInfo.text = """CASE INFORMATION
---
NAME: {0}
BRIEFING:
{1}
""".format([data.title, data.briefing])

func _on_start_button_pressed() -> void:
	if selected < 0: return
	CaseState.start(cases[selected])
	GameFlow.go(GameFlow.State.TOWN)

func _on_back_button_pressed() -> void:
	GameFlow.go(GameFlow.State.MENU)
