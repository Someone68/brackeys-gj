extends StaticBody2D
@export var profile: NPCProfile
@export var case: String

func _ready() -> void:
	if (case != CaseState.current.id): queue_free()

func interact() -> void:
	var entry := DialogueUtil.pick(profile.dialogue.idle)
	if entry == null:
		await Global.show_dialog(["..."], 0.02, [4.5, 6], true, profile.display_name)
	else:
		await _run(entry)

	var opts := profile.confront_options
	var labels: Array[String] = []
	var press := ""

	if Budget.confronts > 0 and DialogueUtil.pick(profile.dialogue.confront) != null:
		press = opts[1] % Budget.confronts if "%d" in opts[1] else opts[1]
		labels.append(press)
	if opts.size() >= 3 and opts[2] != "":
		labels.append(opts[2])
	if opts.size() >= 4 and opts[3] != "":
		labels.append(opts[3])
	labels.append(opts[0])

	var r: String = await Global.show_choices(labels, 0)

	if press != "" and r == press:
		await confront()
	elif opts.size() >= 3 and r == opts[2]:
		await Global.show_dialog(profile.slot_1_response, 0.02, [4.5, 6], true, profile.display_name)
	elif opts.size() >= 4 and r == opts[3]:
		await Global.show_dialog(profile.slot_2_response, 0.02, [4.5, 6], true, profile.display_name)
	elif r == opts[0]:
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
	if entry.refunds_confront: Budget.refund()
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
	if picked.refunds_confront: Budget.refund()
	if picked.once: CaseState.used_entries[picked.choice_id] = true

	return profile.dialogue.by_id(picked.next_id) if picked.next_id != "" else null

func _grant(fs: Array) -> void:
	for f in fs: Knowledge.grant(f)
