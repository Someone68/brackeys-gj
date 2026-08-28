extends Node

static func ok(requires: Array, forbids: Array) -> bool:
	if not Knowledge.has_all(requires): return false
	for f in forbids:
		if Knowledge.has(f): return false
	return true

static func pick(entries: Array) -> DialogueEntry:
	var best: DialogueEntry = null
	for e: DialogueEntry in entries:
		if e.once and CaseState.used_entries.has(e.entry_id): continue
		if not ok(e.requires, e.forbids): continue
		if best == null or e.priority > best.priority: best = e
	return best

static func avail(cs: Array) -> Array:
	var out := []
	for c: DialogueChoice in cs:
		if c.once and CaseState.used_entries.has(c.choice_id): continue
		if ok(c.requires, c.forbids): out.append(c)
	return out
