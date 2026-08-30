extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UserNotes.text = Global.notes

func init(data: CaseData) -> void:
	$CaseInfo.text = """CASE INFORMATION
---
NAME: {0}
BRIEFING:
{1}
""".format([data.title, data.briefing])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (not Global.dialog_visible and not Global.choice_visible):
		if (Input.is_action_just_pressed("notes")):
			visible = true
			$UserNotes.grab_focus()
			Global.notes_visible = true
		if (Input.is_action_just_pressed("escape")):
			visible = false
			Global.notes_visible = false

func _on_user_notes_text_changed() -> void:
	Global.notes = $UserNotes.text
