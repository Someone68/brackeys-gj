extends Control

var selected_npc : int
var selected_evidence : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Notes.init(CaseState.current)
	Global.dialog_node = $DialogBox
	Global.dialog_initialized = true
	
	Global.show_dialog(["ORDER IN THE COURT!!!"], 0.02, [4.5, 6], true, "Judge") # placeholder

func _exit_tree() -> void:
	if Global.dialog_node == $DialogBox:
		Global.dialog_initialized = false
		Global.dialog_node = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _refresh_selectors() -> void:
	$EvidencePanel/Selector.refresh(true)
	$AccusationPanel/Selector.refresh(true)

func _on_accusation(index: int) -> void:
	selected_npc = index
	$AccusationLabel.text = "ACCUSATION (CHOSEN)"
	$AccusationPanel/Selector.enabled = false
	$AccusationPanel/Selector.chosen = true
	$EvidencePanel/Selector.enabled = true
	_refresh_selectors()

func _on_evidence(index: int) -> void:
	selected_evidence = index
	$EvidenceLabel.text = "EVIDENCE (CHOSEN)"
	$EvidencePanel/Selector.enabled = false
	$EvidencePanel/Selector.chosen = true
	_refresh_selectors()
	
	selected_evidence = index
	$EvidenceLabel.text = "EVIDENCE (CHOSEN)"
	$EvidencePanel/Selector.enabled = false
	$EvidencePanel/Selector.chosen = true
	_refresh_selectors()
	await _trial()

var strength := 0
var accused_id := ""
var evidence_id := ""

var attempt := 0

func _trial() -> void:
	accused_id = CaseState.current.npcs[selected_npc].id
	evidence_id = CaseState.evidence_held[selected_evidence]
	CaseState.accused = accused_id

	var r := _reaction(accused_id, evidence_id)
	strength = r.base_strength - attempt * 20

	if r.accusation_line != "":
		await Global.show_dialog([r.accusation_line], 0.02, [4.5, 6], true, "Judge")
	if r.evidence_line != "":
		await Global.show_dialog([r.evidence_line], 0.02, [4.5, 6], true, "Judge")

	for c: CourtChallenge in r.challenges:
		await _challenge(c)

	var correct := accused_id == CaseState.current.culprit_id
	var convicted := correct and strength >= CaseState.current.convict_threshold

	if not convicted and attempt == 0:
		await Global.show_dialog([
			"The court is not satisfied.",
			"You may name another, but understand: this will be your last."
		], 0.02, [4.5, 6], true, "Judge")
		var again: String = await Global.show_choices(
			["Name another suspect", "Stand by my accusation"], 0)
		if again == "Name another suspect":
			attempt += 1
			_reset_selectors()
			return
	await _verdict(correct, convicted)

func _reset_selectors() -> void:
	$AccusationLabel.text = "ACCUSATION"
	$EvidenceLabel.text = "EVIDENCE"
	$AccusationPanel/Selector.enabled = true
	$AccusationPanel/Selector.chosen = false
	$EvidencePanel/Selector.enabled = false
	$EvidencePanel/Selector.chosen = false
	CaseState.evidence_shown.clear()
	_refresh_selectors()

func _reaction(npc: String, ev: String) -> CourtReaction:
	for r: CourtReaction in CaseState.current.reactions:
		if r.npc_id == npc and r.evidence_id == ev:
			return r
	return CaseState.current.fallback_reaction

func _challenge(c: CourtChallenge) -> void:
	await Global.show_dialog([c.prompt], 0.02, [4.5, 6], true, c.speaker)

	var avail: Array[CourtResponse] = []
	for res: CourtResponse in c.responses:
		if not Knowledge.has_all(res.requires): continue
		var ok := true
		for e in res.requires_evidence:
			if not CaseState.evidence_held.has(e): ok = false; break
		if ok: avail.append(res)

	if avail.is_empty():
		strength -= 10
		await Global.show_dialog(["The detective has nothing to say."], 0.02, [4.5, 6], true, "Clerk")
		return

	var labels: Array[String] = []
	for res in avail: labels.append(res.label)

	var picked_label: String = await Global.show_choices_paged(labels)
	var picked: CourtResponse = avail[labels.find(picked_label)]

	strength += picked.strength
	await Global.show_dialog([picked.reply], 0.02, [4.5, 6], true, c.speaker)

	if picked.presents_evidence:
		var shown := await _present()
		if shown != "" and picked.accepts.has(shown):
			strength += 20
			CaseState.evidence_shown.append(shown)
			await Global.show_dialog(["The court accepts this."], 0.02, [4.5, 6], true, c.speaker)
		else:
			strength += picked.strength_wrong
			await Global.show_dialog(
				[picked.reply_wrong if picked.reply_wrong != "" else "That proves nothing."],
				0.02, [4.5, 6], true, c.speaker)

func _present() -> String:
	var labels: Array[String] = []
	var ids: Array[String] = []
	for e_id in CaseState.evidence_held:
		if e_id == evidence_id or CaseState.evidence_shown.has(e_id): continue
		labels.append(EvidenceDB.get_item(e_id).get("label", e_id))
		ids.append(e_id)
	if labels.is_empty():
		await Global.show_dialog(["No more evidence, your honor."], 0.02, [4.5, 6], true, "Detective")
		return ""
	labels.append("Nothing further")
	var picked: String = await Global.show_choices_paged(labels)
	if picked == "Nothing further": return ""
	return ids[labels.find(picked)]


func _verdict(correct: bool, convicted: bool) -> void:
	await Global.show_dialog(
		[CaseState.current.verdict_guilty if convicted else CaseState.current.verdict_acquit],
		0.02, [4.5, 6], true, "Judge")

	CaseState.last_convicted = convicted
	CaseState.last_strength = strength
	CaseState.last_correct = correct
	CaseState.last_attempts = attempt + 1
	CaseState.reputation = clampi(
		CaseState.reputation + (15 if convicted else (-5 if correct else -20)) - attempt * 10,
		0, 100)
	GameFlow.go(GameFlow.State.RESULTS)
