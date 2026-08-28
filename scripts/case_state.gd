extends Node

var current: CaseData = null
var reputation: int = 50
var evidence_held: Array[String] = []
var used_entries: Dictionary = {}
var accused: String = ""

func start(c: CaseData) -> void:
	current = c
	evidence_held.clear()
	used_entries.clear()
	accused = ""
	Knowledge.flags.clear()
	Budget.start_case(c)

func add_evidence(id: String) -> void:
	if evidence_held.has(id): return
	evidence_held.append(id)

func evidence_required() -> int:
	return maxi(1, current.base_evidence_required - reputation / 25)

func can_accuse() -> bool:
	return Knowledge.has_all(current.accuse_gate)

func missing_gate() -> int:
	var n := 0
	for f in current.accuse_gate:
		if not Knowledge.has(f): n += 1
	return n

func score() -> int:
	var correct := accused == current.culprit_id
	return 100 + Budget.confronts * 25 + reputation + (500 if correct else 0)
