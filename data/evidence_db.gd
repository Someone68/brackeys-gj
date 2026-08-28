extends Node
class_name EvidenceDB

const ITEMS := {
	"placeholder_evidence": {
		"label": "test evidence",
		"desc": "this is some test evidence",
	}
}

static func get_item(id: String) -> Dictionary:
	return ITEMS.get(id, {})
