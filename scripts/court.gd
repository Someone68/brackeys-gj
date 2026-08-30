extends Control

var selected_npc : int
var selected_evidence : int

## ids behind each selector slot, so an index always maps back to real data
## even when a profile is missing or an evidence id is unknown.
var npc_ids: Array[String] = []
var evidence_ids: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Notes.init(CaseState.current)
	Global.dialog_node = $DialogBox
	Global.dialog_initialized = true

	_build_accusation()
	_build_evidence()

	Global.show_dialog(["ORDER IN THE COURT!!!", "The Plaintiff shall accuse one of a crime."], 0.02, [4.5, 6], true, "Judge") # placeholder

func _build_accusation() -> void:
	npc_ids.clear()
	var items: Array[SelectorItem] = []
	for p: NPCProfile in CaseState.current.npcs:
		if p == null: continue
		var it := SelectorItem.new()
		it.texture = p.portrait
		it.caption = p.display_name if p.display_name != "" else p.id
		items.append(it)
		npc_ids.append(p.id)
	$AccusationPanel/Selector.items = items
	if npc_ids.is_empty():
		push_error("court: case '%s' has no npcs to accuse" % CaseState.current.id)

func _build_evidence(only: Array[String] = CaseState.evidence_held) -> void:
	evidence_ids.clear()
	var items: Array[SelectorItem] = []
	for e_id in only:
		var it := SelectorItem.new()
		it.texture = CaseState.evidence_icon(e_id)
		it.caption = CaseState.evidence_label(e_id)
		items.append(it)
		evidence_ids.append(e_id)
	$EvidencePanel/Selector.items = items
	if evidence_ids.is_empty():
		push_error("court: no evidence collected")

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

## the evidence row is used twice: once for the item the accusation rests on,
## then again for the second piece the judge asks for.
var awaiting_second := false

func _on_evidence(index: int) -> void:
	if index >= evidence_ids.size(): return
	$EvidenceLabel.text = "EVIDENCE (CHOSEN)"
	$EvidencePanel/Selector.enabled = false
	$EvidencePanel/Selector.chosen = true
	_refresh_selectors()

	if awaiting_second:
		awaiting_second = false
		presented.append(evidence_ids[index])
		await _trial()
		return

	selected_evidence = index
	evidence_id = evidence_ids[index]
	presented.clear()
	presented.append(evidence_id)
	await _ask_second()

## whoever was named, the court wants a second piece tying them to the crime
## before it rules, so nothing is thrown out on the first item alone.
func _ask_second() -> void:
	var rest: Array[String] = []
	for e_id in CaseState.evidence_held:
		if not presented.has(e_id): rest.append(e_id)

	if rest.is_empty():
		await Global.show_dialog(
			["No more evidence, your honor."], 0.02, [4.5, 6], true, "Detective")
		await _trial()
		return

	await Global.show_dialog(
		DialogueUtil.pages(CaseState.current.second_evidence_prompt), 0.02, [4.5, 6], true, "Judge")

	_build_evidence(rest)
	$EvidenceLabel.text = "SECOND EVIDENCE"
	$EvidencePanel/Selector.enabled = true
	$EvidencePanel/Selector.chosen = false
	awaiting_second = true
	_refresh_selectors()

var strength := 0
var accused_id := ""
var evidence_id := ""
## everything the player has actually put in front of the court this attempt:
## the item picked in the selector, plus whatever they answered the judge's
## request for a second piece with. reactions are scored on this, not on the
## whole evidence bag.
var presented: Array[String] = []

var attempt := 0

func _trial() -> void:
	if selected_npc >= npc_ids.size():
		push_error("court: selection out of range"); return
	accused_id = npc_ids[selected_npc]
	CaseState.accused = accused_id

	var r := _reaction(accused_id, evidence_id)
	# a second attempt costs reputation and score, not case strength: a case
	# argued perfectly still has to be winnable the second time round
	strength = r.base_strength

	if r.accusation_line != "":
		await Global.show_dialog(DialogueUtil.pages(r.accusation_line), 0.02, [4.5, 6], true, "Judge")
	if r.evidence_line != "":
		await Global.show_dialog(DialogueUtil.pages(r.evidence_line), 0.02, [4.5, 6], true, "Judge")

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
	awaiting_second = false
	CaseState.evidence_shown.clear()
	presented.clear()
	_build_evidence()
	_refresh_selectors()

## best reaction written for this pairing. "*" in either id matches anything,
## so a case can write one line for "accused the wrong person" and another for
## "right person, wrong evidence" without listing every combination.
## the most specific match wins: exact pair, then npc with any evidence, then any.
func _reaction(npc: String, ev: String) -> CourtReaction:
	var best: CourtReaction = null
	var best_score := -1
	for r: CourtReaction in CaseState.current.reactions:
		if r.npc_id != npc and r.npc_id != "*": continue
		if r.evidence_id != "*" and not presented.has(r.evidence_id): continue
		if not _shows_all(r.requires_evidence): continue
		if _shows_any(r.forbids_evidence): continue
		# a reaction that names the accused, the evidence, or more conditions on
		# what was put in front of the court is a better fit than one naming less
		var score := (100 if r.npc_id == npc else 0) + (50 if r.evidence_id != "*" else 0) \
			+ r.requires_evidence.size() + r.forbids_evidence.size()
		if score > best_score:
			best = r
			best_score = score
	if best != null:
		return best
	if CaseState.current.fallback_reaction != null:
		return CaseState.current.fallback_reaction
	# no reaction was written for this pairing, so score it off the evidence
	# alone: evidence that implicates the accused is worth the threshold.
	var r := CourtReaction.new()
	r.npc_id = npc
	r.evidence_id = ev
	r.base_strength = CaseState.current.convict_threshold if _implicates(ev, npc) else 0
	r.accusation_line = "You accuse %s." % _display_name(npc)
	r.evidence_line = "And you offer %s as proof." % CaseState.evidence_label(ev)
	return r

## what the court has been shown this attempt
func _shows_all(ids: Array[String]) -> bool:
	for e in ids:
		if not presented.has(e): return false
	return true

func _shows_any(ids: Array[String]) -> bool:
	for e in ids:
		if presented.has(e): return true
	return false

## what the player is carrying, shown or not
func _holds_all(ids: Array[String]) -> bool:
	for e in ids:
		if not CaseState.evidence_held.has(e): return false
	return true

func _holds_any(ids: Array[String]) -> bool:
	for e in ids:
		if CaseState.evidence_held.has(e): return true
	return false

func _implicates(ev: String, npc: String) -> bool:
	return EvidenceDB.get_item(ev).get("implicates", []).has(npc)

func _display_name(npc_id: String) -> String:
	for p: NPCProfile in CaseState.current.npcs:
		if p != null and p.id == npc_id:
			return p.display_name if p.display_name != "" else p.id
	return npc_id

func _challenge(c: CourtChallenge) -> void:
	await Global.show_dialog(DialogueUtil.pages(c.prompt), 0.02, [4.5, 6], true, c.speaker)

	var avail: Array[CourtResponse] = []
	for res: CourtResponse in c.responses:
		if not Knowledge.has_all(res.requires): continue
		if not _holds_all(res.requires_evidence): continue
		avail.append(res)

	if avail.is_empty():
		strength -= 10
		await Global.show_dialog(["The detective has nothing to say."], 0.02, [4.5, 6], true, "Clerk")
		return

	var labels: Array[String] = []
	for res in avail: labels.append(res.label)

	var picked_label: String = await Global.show_choices_paged(labels)
	await _apply_response(avail[labels.find(picked_label)], c.speaker)

## pays for one answer and asks whatever the court wants asked after it. a
## follow-up is a response like any other, so this recurses.
func _apply_response(res: CourtResponse, speaker: String) -> void:
	# an answer the player cannot back up is heard out and then thrown out
	if not res.proof.is_empty() and not _holds_any(res.proof):
		strength += res.strength_unproven
		await Global.show_dialog(DialogueUtil.pages(res.unproven_reply), 0.02, [4.5, 6], true, speaker)
		return

	strength += res.strength
	if res.reply != "":
		await Global.show_dialog(DialogueUtil.pages(res.reply), 0.02, [4.5, 6], true, speaker)

	if not res.followups.is_empty():
		if res.followup_prompt != "":
			await Global.show_dialog(DialogueUtil.pages(res.followup_prompt), 0.02, [4.5, 6], true, speaker)
		var labels: Array[String] = []
		for f: CourtResponse in res.followups: labels.append(f.label)
		var picked_label: String = await Global.show_choices_paged(labels)
		await _apply_response(res.followups[labels.find(picked_label)], speaker)

	if res.presents_evidence:
		var shown := await _present()
		if shown != "" and res.accepts.has(shown):
			strength += 20
			CaseState.evidence_shown.append(shown)
			await Global.show_dialog(["The court accepts this."], 0.02, [4.5, 6], true, speaker)
		else:
			strength += res.strength_wrong
			await Global.show_dialog(
				[res.reply_wrong if res.reply_wrong != "" else "That proves nothing."],
				0.02, [4.5, 6], true, speaker)

func _present() -> String:
	var labels: Array[String] = []
	var ids: Array[String] = []
	for e_id in evidence_ids:
		if e_id == evidence_id or CaseState.evidence_shown.has(e_id): continue
		labels.append(CaseState.evidence_label(e_id))
		ids.append(e_id)
	if labels.is_empty():
		await Global.show_dialog(["No more evidence, your honor."], 0.02, [4.5, 6], true, "Detective")
		return ""
	labels.append("Nothing further")
	var picked: String = await Global.show_choices_paged(labels)
	if picked == "Nothing further": return ""
	return ids[labels.find(picked)]


func _verdict(correct: bool, convicted: bool) -> void:
	Audio.play_sfx("verdict")
	await Global.show_dialog(
		DialogueUtil.pages(CaseState.current.verdict_guilty if convicted else CaseState.current.verdict_acquit),
		0.02, [4.5, 6], true, "Judge")

	CaseState.last_convicted = convicted
	CaseState.last_strength = strength
	CaseState.last_correct = correct
	CaseState.last_attempts = attempt + 1
	CaseState.reputation = clampi(
		CaseState.reputation + (15 if convicted else (-5 if correct else -20)) - attempt * 10,
		0, 100)
	GameFlow.go(GameFlow.State.RESULTS)
