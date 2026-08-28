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
