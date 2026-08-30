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


## the dialog box fits three lines of about 41 monospace characters, and court
## lines are authored as one long string rather than pre-split pages, so break
## them on sentence ends (then on words) into pages the box can actually show.
const PAGE_CHARS := 41
const PAGE_LINES := 3

static func _line_count(text: String) -> int:
	var lines := 1
	var used := 0
	for word in text.split(" ", false):
		var w := word.length()
		if used == 0:
			used = w
		elif used + 1 + w <= PAGE_CHARS:
			used += 1 + w
		else:
			lines += 1
			used = w
		while used > PAGE_CHARS:
			lines += 1
			used -= PAGE_CHARS
	return lines

static func pages(text: String) -> Array[String]:
	var out: Array[String] = []
	if text.strip_edges() == "": return out
	if _line_count(text) <= PAGE_LINES: return [text]

	var sentences: Array[String] = []
	var cur := ""
	for c in text:
		cur += c
		if c in [".", "!", "?"]:
			sentences.append(cur.strip_edges())
			cur = ""
	if cur.strip_edges() != "": sentences.append(cur.strip_edges())

	var page := ""
	for sentence in sentences:
		var joined := (page + " " + sentence).strip_edges()
		if _line_count(joined) <= PAGE_LINES:
			page = joined
			continue
		if page != "":
			out.append(page)
			page = ""
		# one sentence longer than a page: keep filling by word
		for word in sentence.split(" ", false):
			var trial := (page + " " + word).strip_edges()
			if page != "" and _line_count(trial) > PAGE_LINES:
				out.append(page)
				page = word
			else:
				page = trial
	if page != "": out.append(page)
	return out
