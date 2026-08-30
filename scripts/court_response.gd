class_name CourtResponse extends Resource

@export var label: String
@export var requires: Array[String] = []
@export var requires_evidence: Array[String] = []
## evidence that backs this claim up: holding ANY ONE of these proves it.
## an answer is always offered, proof or not — an unproven one is simply not
## accepted, so the player can try a claim they cannot back up.
@export var proof: Array[String] = []
@export_multiline var reply: String
@export var strength: int = 0
## what the court says, and pays, when the claim is not proven.
@export_multiline var unproven_reply: String = "The court has seen no such evidence."
@export var strength_unproven: int = 0
## an extra question the court asks after this answer. purely a follow-up:
## every option leads to the same reply, and the strength is already paid.
@export_multiline var followup_prompt: String
@export var followup_options: Array[String] = []
@export_multiline var followup_reply: String
@export var presents_evidence: bool = false
@export var accepts: Array[String] = []
@export var strength_wrong: int = -10
@export_multiline var reply_wrong: String
