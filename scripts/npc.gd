extends StaticBody2D
@export var profile: NPCProfile

func interact() -> void:
	var entry = DialogueUtil.pick(profile.dialogue.idle)
	if entry == null:
		await Global.show_dialog(["..."])
		return
	await Global.show_dialog([entry.text])
	for f in entry.grants: Knowledge.grant(f)
	if entry.once: CaseState.used_entries[entry.entry_id] = true
