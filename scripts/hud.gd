extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Evidence/Label.text = str(Budget.confronts)
	
	if (not Global.dialog_visible and not Global.choice_visible):
		if (Input.is_action_just_pressed("notes")):
			$Notes.visible = true
			$Notes/UserNotes.grab_focus()
			$Evidence.visible = false
			$StartTrialIcon.visible = false
			$NotesIcon.visible = false
			Global.notes_visible = true
		if (Input.is_action_just_pressed("escape")):
			$Notes.visible = false
			$Evidence.visible = true
			$StartTrialIcon.visible = true
			$NotesIcon.visible = true
			Global.notes_visible = false

func init(data: CaseData):
	$Notes/CaseInfo.text = """CASE INFORMATION
---
NAME: {0}
BRIEFING:
	{1}
""".format([data.title, data.briefing])
