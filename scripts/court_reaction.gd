class_name CourtReaction extends Resource

@export var npc_id: String
@export var evidence_id: String
@export_multiline var accusation_line: String
@export_multiline var evidence_line: String
@export var base_strength: int = 0
@export var challenges: Array[CourtChallenge] = []
