extends Node

var current: CaseData = null
var reputation: int = 50
var evidence_held: Array[String] = []
var evidence_shown: Array[String] = []
var used_entries: Dictionary = {}
var accused: String = ""
var last_convicted := false
var last_strength := 0
var last_attempts := 0
var last_correct := false

func score() -> int:
	return (500 if last_convicted else 0) \
		+ last_strength * 5 \
		+ Budget.confronts * 25 \
		+ reputation \
		- (last_attempts - 1) * 150

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
