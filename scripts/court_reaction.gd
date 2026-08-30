class_name CourtReaction extends Resource

@export var npc_id: String
@export var evidence_id: String
## conditions on what the player is carrying, on top of the ids above:
## every id in requires_evidence must be held and none in forbids_evidence may
## be, so a case can score "accused the right person but only half the proof".
@export var requires_evidence: Array[String] = []
@export var forbids_evidence: Array[String] = []
@export_multiline var accusation_line: String
@export_multiline var evidence_line: String
@export var base_strength: int = 0
@export var challenges: Array[CourtChallenge] = []
