extends Node

enum State { MENU, CASE_SELECT, TOWN, COURT, RESULTS }

const SCENES := {
	State.MENU: "res://scenes/ui/menu.tscn",
	State.CASE_SELECT: "res://scenes/ui/case_select.tscn",
	State.TOWN: "res://scenes/world.tscn",
	State.COURT: "res://scenes/ui/court.tscn",
	State.RESULTS: "res://scenes/ui/results.tscn"
}

var state: State = State.MENU

func go(next: State) -> void:
	state = next
	get_tree().change_scene_to_file(SCENES[next])

func _process(_delta: float) -> void:
	if (not Global.dialog_visible and not Global.choice_visible and not Global.notes_visible):
		if (state == State.TOWN and Input.is_action_just_pressed("start_trial")):
			await Global.show_dialog(["Do you want to start the trial now?"])
			var confirm = await Global.show_choices(["Start trial", "Not yet"])
			
			if (confirm == "Start trial"):
				if CaseState.evidence_held.is_empty():
					await Global.show_dialog(["You haven't collected any evidence yet."])
					return
				await Fade.fade_out()
				GameFlow.go(GameFlow.State.COURT)
				Fade.fade_in()
			return
