# evidence_item.gd
extends Area2D

@export var evidence_id: String
## name shown under this item in the court evidence selector.
## falls back to EvidenceDB, then to evidence_id, when left blank.
@export var display_name: String
## icon shown for this item in the court evidence selector.
## falls back to EvidenceDB, then to a generic scroll, when left blank.
@export var court_sprite: Texture2D
@export var grants_flag: String
@export var pickup_text: Array[String] = ["You pocket it."]
@export var already_text: Array[String] = ["Already collected."]
@export var destroy_on_pickup: bool = true
@export var grants : Array[String]

func _ready() -> void:
	if CaseState.evidence_held.has(evidence_id) and destroy_on_pickup:
		queue_free()

func interact() -> void:
	if CaseState.evidence_held.has(evidence_id):
		await Global.show_dialog(already_text)
		return
	CaseState.add_evidence(evidence_id, display_name, court_sprite)
	Audio.play_sfx("pickup")
	for e in grants: Knowledge.grant(e)
	if grants_flag != "":
		Knowledge.grant(grants_flag)
	await Global.show_dialog(pickup_text)
	if destroy_on_pickup:
		queue_free()
