class_name CaseData extends Resource

@export var id: String
@export var title: String
@export_multiline var briefing: String
@export var start_room: String = "town_square"
@export var culprit_id: String
@export var max_confronts: int = 8
@export var base_evidence_required: int = 3
@export var npcs: Array[NPCProfile] = []
@export var accuse_gate: Array[String] = [] 
@export var reactions: Array[CourtReaction] = []
@export var fallback_reaction: CourtReaction
@export var convict_threshold: int = 60
@export_multiline var verdict_guilty: String
@export_multiline var verdict_acquit: String
