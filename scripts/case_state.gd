extends Node

var current: CaseData = null
var reputation: int = 50
var evidence_held: Array[String] = []
var evidence_shown: Array[String] = []
## id -> {"label": String, "icon": Texture2D}, filled in as items are picked up
## so the court can still name and draw them once the world scene is gone.
var evidence_meta: Dictionary = {}
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
	evidence_meta.clear()
	used_entries.clear()
	accused = ""
	Knowledge.flags.clear()
	Budget.start_case(c)

func add_evidence(id: String, label: String = "", icon: Texture2D = null) -> void:
	if label != "" or icon != null:
		evidence_meta[id] = {"label": label, "icon": icon}
	if evidence_held.has(id): return
	evidence_held.append(id)

## name for an evidence id: what the item was authored with, else EvidenceDB,
## else the raw id so a missing entry is still readable.
func evidence_label(id: String) -> String:
	var label: String = evidence_meta.get(id, {}).get("label", "")
	return label if label != "" else EvidenceDB.get_label(id)

## icon for an evidence id, with the same fallback order.
func evidence_icon(id: String) -> Texture2D:
	var icon = evidence_meta.get(id, {}).get("icon", null)
	return icon if icon != null else EvidenceDB.get_icon(id)

func evidence_required() -> int:
	return maxi(1, current.base_evidence_required - reputation / 25)

func can_accuse() -> bool:
	return Knowledge.has_all(current.accuse_gate)

func missing_gate() -> int:
	var n := 0
	for f in current.accuse_gate:
		if not Knowledge.has(f): n += 1
	return n

func npc(id: String) -> NPCProfile:
	if current == null: return null
	for n: NPCProfile in current.npcs:
		if n.id == id: return n
	return null
