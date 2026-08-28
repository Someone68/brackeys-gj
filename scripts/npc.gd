extends StaticBody2D
@export var profile: NPCProfile

func interact() -> void:
	var entry := DialogueUtil.pick(profile.dialogue.idle)
	if entry == null:
		await Global.show_dialog(["..."])
		return
	await _run(entry)

func _run(entry: DialogueEntry) -> DialogueEntry:
	await Global.show_dialog(entry.text)
	_grant(entry.grants)
	if entry.once: CaseState.used_entries[entry.entry_id] = true

	var avail := DialogueUtil.avail(entry.choices)
	if avail.is_empty(): return null

	var labels: Array[String] = []
	for c: DialogueChoice in avail: labels.append(c.label)

	var chosen: String = await Global.show_choices(labels)
	var picked: DialogueChoice = null
	for c: DialogueChoice in avail:
		if c.label == chosen: picked = c; break
	if picked == null: return null

	await Global.show_dialog(picked.response)
	_grant(picked.grants)
	if picked.once: CaseState.used_entries[picked.choice_id] = true

	return profile.dialogue.by_id(picked.next_id) if picked.next_id != "" else null

func _grant(fs: Array) -> void:
	for f in fs: Knowledge.grant(f)
