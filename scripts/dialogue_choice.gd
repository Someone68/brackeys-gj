class_name DialogueChoice extends Resource

@export var label: String
@export var requires: Array[String] = []
@export var forbids: Array[String] = []
@export_multiline var response: String
@export var grants: Array[String] = []
@export var next_id: String = ""
@export var once: bool = false
@export var choice_id: String = ""
