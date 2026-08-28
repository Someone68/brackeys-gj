extends Node

signal changed(remaining: int)
signal exhausted

var confronts: int = 0
var max_confronts: int = 0


func start_case(c: CaseData) -> void:
	max_confronts = c.max_confronts
	confronts = c.max_confronts
	changed.emit(confronts)

func try_spend() -> bool:
	if confronts <= 0:
		return false
	confronts -= 1
	changed.emit(confronts)
	if confronts == 0:
		exhausted.emit()
	return true


func refund() -> void:
	confronts = mini(confronts + 1, max_confronts)
	changed.emit(confronts)


func grant(n: int = 1) -> void:
	confronts = mini(confronts + n, max_confronts)
	changed.emit(confronts)


func used() -> int:
	return max_confronts - confronts
