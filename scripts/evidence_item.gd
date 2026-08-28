# evidence_item.gd
extends Area2D

@export var evidence_id: String
@export var grants_flag: String
@export var pickup_text: Array[String] = ["You pocket it."]
@export var already_text: Array[String] = ["Already collected."]
@export var destroy_on_pickup: bool = true

func _ready() -> void:
	if CaseState.evidence_held.has(evidence_id) and destroy_on_pickup:
		queue_free()

func interact() -> void:
	print("evidence interact")
	if CaseState.evidence_held.has(evidence_id):
		await Global.show_dialog(already_text)
		return
	CaseState.add_evidence(evidence_id)
	if grants_flag != "":
		Knowledge.grant(grants_flag)
	await Global.show_dialog(pickup_text)
	if destroy_on_pickup:
		queue_free()
