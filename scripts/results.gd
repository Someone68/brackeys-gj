extends Control

func _ready() -> void:
	var c := CaseState.current
	# opening this scene straight from the editor has no case behind it
	if c == null:
		$Title.text = "NO CASE"
		$Panel/Summary.text = "No trial has been run."
		return
	$Title.text = "GUILTY" if CaseState.last_convicted else "CASE CLOSED"
	$Panel/Summary.text = """{0}
---
ACCUSED: {1}
VERDICT: {2}
CASE STRENGTH: {3} / {4}
ATTEMPTS USED: {5}
CONFRONTS LEFT: {6} / {7}
REPUTATION: {8}
---
SCORE: {9}""".format([
		c.title,
		_accused_name(),
		"convicted" if CaseState.last_convicted else \
			("right suspect, weak case" if CaseState.last_correct else "acquitted"),
		CaseState.last_strength, c.convict_threshold,
		CaseState.last_attempts,
		Budget.confronts, Budget.max_confronts,
		CaseState.reputation,
		CaseState.score(),
	])

## the accused is stored as an id, so look the profile back up for a real name.
func _accused_name() -> String:
	var p := CaseState.npc(CaseState.accused)
	if p == null: return CaseState.accused
	return p.display_name if p.display_name != "" else p.id

func _on_retry_button_pressed() -> void:
	CaseState.start(CaseState.current)
	GameFlow.go(GameFlow.State.TOWN)

func _on_cases_button_pressed() -> void:
	GameFlow.go(GameFlow.State.CASE_SELECT)

func _on_menu_button_pressed() -> void:
	GameFlow.go(GameFlow.State.MENU)
