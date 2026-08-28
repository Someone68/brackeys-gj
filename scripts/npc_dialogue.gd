class_name NPCDialogue extends Resource

@export var npc_id: String
@export var idle: Array[DialogueEntry] = []
@export var confront: Array[DialogueEntry] = []

func by_id(id: String) -> DialogueEntry:
	for e in confront:
		if e.entry_id == id: return e
	for e in idle:
		if e.entry_id == id: return e
	return null
