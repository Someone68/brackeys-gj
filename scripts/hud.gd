extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameFlow.state == GameFlow.State.TOWN:
		$Evidence.visible = true
		$StartTrialIcon.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameFlow.state == GameFlow.State.TOWN:
		$Evidence/Label.text = str(Budget.confronts)
		
	if (Global.notes_visible):
		$Evidence.visible = false
		$StartTrialIcon.visible = false
		$NotesIcon.visible = false
	else:
		$NotesIcon.visible = true
		if GameFlow.state == GameFlow.State.TOWN:
			$Evidence.visible = true
			$StartTrialIcon.visible = true

func init(data: CaseData):
	$Notes.init(data)
