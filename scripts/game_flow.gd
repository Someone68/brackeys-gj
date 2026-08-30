extends Node

enum State { MENU, CASE_SELECT, TOWN, COURT, RESULTS }

const SCENES := {
	State.MENU: "res://scenes/ui/menu.tscn",
	State.CASE_SELECT: "res://scenes/ui/case_select.tscn",
	State.TOWN: "res://scenes/world.tscn",
	State.COURT: "res://scenes/ui/court.tscn",
	State.RESULTS: "res://scenes/ui/results.tscn"
}

## which track each screen runs under, and how loud. anything not listed is
## played in silence.
const MUSIC := {
	State.TOWN: ["town", 0.7],
	State.COURT: ["tense", 1.0],
}

var state: State = State.MENU

func go(next: State) -> void:
	state = next
	var track: Array = MUSIC.get(next, ["", 1.0])
	Audio.play_music(track[0], track[1])
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
				Audio.play_sfx("starttrial")
				await Fade.fade_out()
				GameFlow.go(GameFlow.State.COURT)
				Fade.fade_in()
			return
