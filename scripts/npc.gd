extends StaticBody2D
@export var profile: NPCProfile
@export var case: String

func _ready() -> void:
	if (case != CaseState.current.id): queue_free()

func interact() -> void:
	var entry := DialogueUtil.pick(profile.dialogue.idle)
	if entry == null:
		await Global.show_dialog(["..."], 0.02, [4.5, 6], true, profile.display_name)
		return
	await _run(entry)
	
	if DialogueUtil.pick(profile.dialogue.confront) != null:
		var press := profile.confront_options[1] % Budget.confronts if profile.confront_options[1].contains("%") else profile.confront_options[1]
		var other_options = profile.confront_options.slice(2, 4)
		var final_choices : Array[String] = other_options
		if (Budget.confronts > 0):
			other_options.append(press)
		final_choices.append(profile.confront_options[0])
		var r: String = await Global.show_choices(final_choices, 0)
		if r == press:
			await confront()
		if (len(profile.confront_options) >= 3):
			if(r == profile.confront_options[2]):
				await Global.show_dialog(profile.slot_1_response, 0.02, [4.5, 6], true, profile.display_name)
		
		if (len(profile.confront_options) >= 4):
			if(r == profile.confront_options[3]):
				await Global.show_dialog(profile.slot_2_response, 0.02, [4.5, 6], true, profile.display_name)
		
		if(r == profile.confront_options[0]):
			await Global.show_dialog(profile.leave_response, 0.02, [4.5, 6], true, profile.display_name)

func confront() -> void:
	if not Budget.try_spend(): return
	var entry := DialogueUtil.pick(profile.dialogue.confront)
	if entry == null:
		Budget.refund(); return
	while entry != null:
		entry = await _run(entry)

func _run(entry: DialogueEntry) -> DialogueEntry:
	await Global.show_dialog(entry.text, 0.02, [4.5, 6], true, profile.display_name)
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

	await Global.show_dialog(picked.response, 0.02, [4.5, 6], true, profile.display_name)
	_grant(picked.grants)
	if picked.once: CaseState.used_entries[picked.choice_id] = true

	return profile.dialogue.by_id(picked.next_id) if picked.next_id != "" else null

func _grant(fs: Array) -> void:
	for f in fs: Knowledge.grant(f)
