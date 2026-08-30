class_name DialogueEntry extends Resource

@export var entry_id: String
@export var priority: int = 0
@export var requires: Array[String] = []
@export var forbids: Array[String] = []
@export_multiline var text: Array[String] = []
@export var grants: Array[String] = []
@export var choices: Array[DialogueChoice] = []
@export var next_id: String
@export var once: bool = false
## gives the spent confrontation point back when this entry is shown.
## for NPCs whose confront costs the player nothing (see Grey, case 1).
@export var refunds_confront: bool = false
