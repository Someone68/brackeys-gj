class_name DialogueChoice extends Resource

@export var label: String
@export var requires: Array[String] = []
@export var forbids: Array[String] = []
@export_multiline var response: Array[String] = []
@export var grants: Array[String] = []
@export var next_id: String = ""
@export var once: bool = false
@export var choice_id: String = ""
## gives the spent confrontation point back when this choice is picked.
@export var refunds_confront: bool = false
