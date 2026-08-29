class_name CourtResponse extends Resource

@export var label: String
@export var requires: Array[String] = []
@export var requires_evidence: Array[String] = []
@export_multiline var reply: String
@export var strength: int = 0
@export var presents_evidence: bool = false
@export var accepts: Array[String] = []
@export var strength_wrong: int = -10
@export_multiline var reply_wrong: String
