# Case 1 — holes in the script

Everything below is **not in the dialogue script** and was left as a placeholder or
needs engine work. Nothing here was invented as story content.

## `data/case_1.tres`
| Field | State | Why |
|---|---|---|
| `title` | `"Just need the money"` | Filled in by hand — not from the script. |
| `briefing` | written by hand | Script gives no type / confront count / premise line. Only thing known from it: every confront response is about **drugs**, so type is drug dealing. |
| `max_confronts` | `8` (engine default) | Not in script. |
| `base_evidence_required` | `3` (engine default) | Not in script. |
| `convict_threshold` | `35` | Script: "at least 35 plus base strength". `base_strength` on the winning reaction is `0`, so the bar is 35. |
| `accuse_gate` | empty | Script defines no flags required before accusing. |
| `reactions` | written | Three: Mr. Ken + drugs (the two challenges), Mr. Ken + any other evidence, and anyone else. |
| `fallback_reaction` | empty | Not needed — the `*`/`*` reaction covers everything. |
| `verdict_guilty` / `verdict_acquit` | PLACEHOLDER | Not in script — the script stops at the second challenge, so the line the judge reads out at the end is still unwritten. |
| `culprit_id` | `mrken` | **Inferred**, not stated. Mr. Ken's 4th line is a confession ("I n-n-needed the money"). Confirm this is intended. Was `mrken_case1`, which matched no profile `id` — `court.gd` compares against `NPCProfile.id`, so no accusation could ever be correct. `data/case_2.tres` still has the same mismatch (`ace_case2` vs `ace`). |

## Engine gaps (need code, not data)

1. ~~**Grey's confront refunds a confrontation point.**~~ **Done.** `DialogueEntry` and
   `DialogueChoice` now have `refunds_confront: bool`; `npc.gd:_run` calls `Budget.refund()`
   when it is set on the entry it showed or the choice the player picked. Grey's
   `confront1` entry sets it, so confronting Grey costs nothing.

2. ~~**Mr. Ken's 4th option is gated on evidence that does not exist yet.**~~ **Done.**
   `scenes/evidence/drugs_money.tscn` (evidence id `drugs_and_money`) sits in
   `scenes/rooms/mart_back.tscn` and grants `searched_store_back`, so picking it up unlocks
   Mr. Ken's confession confront.

   Getting into that room is now gated too. `mart.tscn`'s back door needs `mart_lead`, and
   that flag is granted by the confront of every NPC whose line points at the convenience
   store: **End, Green, Mr. Leaf, Ms. Leaf, Rob Berr**. Any one of them is enough — the flag
   is a single boolean, so there is no "talk to N of them" counter. The NPCs who only say
   *"south side of the city"* (Ace, Officer Red, Jigsaw) and the Fortune Teller's *"a certain
   location"* grant nothing, since they never name the store; move them into the list if the
   lead is meant to be vaguer.

   The back door still uses the default `locked_text` of `"Locked."` — the script has no line
   for it, so a hint like "there must be a reason to go back there" is unwritten.

3. **Leave option text and leave response are not in the script.**
   `confront_options[0]` is `"See ya later"` (the default string from `npc_profile.gd`),
   and `leave_response` is empty for every NPC. Fill in per-NPC goodbyes when written.
   An empty array no longer flashes an empty dialog panel — `dialog_box.gd:show_dialog`
   returns straight away when there is nothing to say — so leaving is silent until then.

4. ~~**Ms. Leaf is in no room.**~~ **Done.** `scenes/npcs/msleaf.tscn` was never instanced
   anywhere, so nothing could grant `talked_msleaf` and Mr. Leaf's "Ask about their wife"
   option was dead. She is now in `scenes/rooms/ms_leafs_house.tscn` at (160, 104) — move her
   if she belongs somewhere else.

5. ~~**Nothing granted `can_enter_leafs_house`.**~~ **Done.** Mr. Leaf's "Ask about the place"
   option grants it — that is the line where he points out "me and my lovely wife's house".

## Flags this case defines

| Flag | Granted by | Used by |
|---|---|---|
| `talked_msleaf` | Ms. Leaf's passive/idle entry, in her house | Mr. Leaf's "Ask about their wife" option — the script says it *"only unlocks after talking to Ms. Leaf"*. |
| `searched_store_back` | picking up `drugs_and_money` in `mart_back` | Mr. Ken's 4th confront. |
| `mart_lead` | confronting End, Green, Mr. Leaf, Ms. Leaf or Rob Berr | the back door in `mart.tscn`. |
| `can_enter_leafs_house` | Mr. Leaf's "Ask about the place" option | the `ms_leafs_house` door in `right_branch.tscn`. |

## Structure used

Passive line = the idle `DialogueEntry` text. Non-confront player options = that entry's
`choices` (label = the option wording from the script, response = "Dialogue after N").
Confront = the `confront` entry array, reached through `confront_options[1] = "Confront"`,
so it spends a Budget point. Same shape as `data/npcs/ace_case2.tres`.

Note the choice picker (`scripts/choice_picker.gd`) shows a **maximum of 4 options**.
Ms. Leaf, Mr. Leaf and Ace each have 3 non-confront options, so they fit, but there is no
room to add more without changing the picker.

## Dialog box capacity

`scenes/dialog_box.tscn`'s `Text` label is 290x45 with DepartureMono-Regular @ 11px. That
font is monospace at a 7px advance, so one page holds **3 lines of 41 characters**. Any
line longer than that ran off the panel, so long script lines are split across several
entries in the `text` / `response` array — each array entry is one page the player advances
with the interact key. The wording is unchanged; only the page breaks were added, and they
fall on sentence boundaries.

Choice labels are single-line, no wrap, no clipping: `Choice1..4` start at x=20 inside a
panel that ends at x=312, so a label must stay under about **40 characters** or it runs off
the panel. The longest one here is "Ask about their sleep schedule" (30).

## Court

The trial screen now builds both selectors from real data — `CaseState.current.npcs` for
the accusation row and `CaseState.evidence_held` for the evidence row — so what is on
screen is whatever the case defines and whatever the player actually picked up. Still
missing before a trial can be *won*:

1. ~~**No `CourtReaction` data exists for either case.**~~ **Both cases done** — case 2's are
   in `data/case_2.tres`, see `data/CASE_2_HOLES.md`.

   `court.gd:_reaction` now matches on wildcards: `"*"` in `npc_id` or `evidence_id` matches
   anything, and the most specific match wins (exact pair > npc + any evidence > any). That is
   what lets case 1 write four reactions instead of one per pairing:

   | Accusation | Line |
   |---|---|
   | anyone but Mr. Ken | "The court says the person you have accused is innocent." |
   | Mr. Ken, wrong or no evidence | "The court does not see why the person you selected is guilty." |
   | Mr. Ken + `drugs` | "The person you have accused could be guilty, however you must plead your case." + two challenges |
   | Mr. Ken + `drugs_and_money` | same line, same two challenges |

   Only the two "could be guilty" rows have challenges, so the others fall straight through to the retry offer
   (`attempt` +1) and then the verdict — that is the script's "(-1 attempt)".

   Before any of that, the court asks for a **second piece of evidence** (`CaseData.second_evidence_prompt`,
   asked on every accusation, right or wrong) by reopening the evidence row with the first pick
   removed, and the reaction is matched against both pieces the player showed rather than
   against the one in the selector. Case 1 needs only one of the two drug finds, so either slot
   can carry it.

   Scoring: strength starts at `base_strength` (0). Challenge 1 pays -15 / -10 / +5 / +30,
   challenge 2 pays -10 / +5 / +25 / -15, and `convict_threshold` is 35. So the top answer to
   either question plus the good-but-partial answer to the other is exactly a conviction (30+5,
   5+25 is 30 and fails); both top answers give 55. A second attempt carries no strength
   penalty — the retry is winnable on its own merits, and attempts are paid for in reputation
   (-10 each) and score (-150 each) instead.

   **Answers are never hidden, but they have to be backed up.** `CourtResponse.proof` lists the
   evidence that supports a claim — holding any one of them is enough. An answer with proof the
   player does not have is still offered; picking it gets `unproven_reply` ("The court has seen
   no such evidence.") and `strength_unproven` (0) instead of the reply and the strength.

   | Answer | Proof |
   |---|---|
   | "traces of methamphetamine near the store" (+5) | `drugs` or `drugs_and_money` |
   | "lots of splattered drugs behind the store" (+30) | `drugs` or `drugs_and_money` |
   | "methamphetamine near the exterior of the store" (+5) | `drugs` or `drugs_and_money` |
   | "methamphetamine inside the back of the store" (+25) | `drugs_and_money` |
   | "The people have told me to check the convenience store" (-10), both "Trust me bro", "near some houses" | none |

   So the case is winnable from either find: with only `drugs` the best pair that actually lands
   is 30+5 = 35 (exactly the bar), with `drugs_and_money` it is 30+25 = 55. A challenge where
   nothing is available costs 10 and prints "The detective has nothing to say" — that cannot
   happen here, since every answer is always on the list.

   Prompts and replies are single strings and some are longer than the three lines the dialog
   box shows, so `court.gd` pages them through `DialogueUtil.pages()`.

2. **Evidence names and icons are authored on the item scene.** `evidence_item.gd` has
   `display_name` and `court_sprite` exports; fill them in on the placed scene next to
   `evidence_id` and `pickup_text` (see `scenes/evidence/drugs.tscn`). On pickup they are
   copied into `CaseState.evidence_meta`, which is what the court reads — the world scene
   is gone by then, so the item node cannot be asked directly.

   Order of fallback for both fields: the item scene, then `EvidenceDB.ITEMS`, then the
   raw id as the name and `sprites/scroll_ui.png` as the icon. So an item with nothing
   filled in still shows up, just as its id string.

   `EvidenceDB.ITEMS` is now only a fallback registry and still holds just
   `placeholder_evidence`. It is the one place that carries `implicates` (array of npc
   ids), which is what the synthesised court reaction scores on — so evidence still needs
   an entry there until real `reactions` are written.

   Selector captions use Tiny5 @ 8px across a 306px panel: keep evidence names under
   about 50 characters. "Drugs" is 20px.

   **Choice labels now auto-shrink.** The court answers run up to 56 characters, well past the
   ~40 that fit at 11px, so `choice_picker.gd` measures each label and steps the font size down
   (to a floor of 7px) until it fits the 284px of panel to the right of the arrow. Wording no
   longer has to be cut to fit, but a very long label will be small.

3. **`mart_back` and `ms_leafs_house` were not in `RoomManager.ROOMS`.** Both scenes exist and
   both had doors pointing at them, so `goto` would `push_error("no room: ...")` and the door
   would do nothing. Both are registered now.

4. ~~**`res://scenes/ui/results.tscn` does not exist.**~~ **Done.** `scenes/ui/results.tscn` +
   `scripts/results.gd` show the case title, who was accused, the verdict, strength against
   `convict_threshold`, attempts used, confronts left, reputation and `CaseState.score()`, with
   Retry Case / Case Select / Menu buttons. Retry re-runs `CaseState.start` on the same case,
   which clears evidence, flags and the confront budget but keeps reputation. Layout copies
   `case_select.tscn` (Tiny5 on the shared panel). None of its wording comes from the script,
   and the verdict line above it is still the `PLACEHOLDER` from `case_1.tres`.

5. **Two parallel evidence systems.** `scripts/evidence_data.gd` (`EvidenceData` resource,
   has `implicates`) and `data/evidence_db.gd` (`EvidenceDB` const dictionary) both
   describe evidence; only `EvidenceDB` is actually read. Pick one.

6. **Case 2 npc list was empty.** `data/case_2.tres` had `npcs = [null]`, so there was
   nobody to accuse. It now lists the nine existing case 2 profiles.
   `green_case2.tres` was a blank resource — it was given `id = "green_case2"` and
   `display_name = "Green"` to match its siblings. Confirm that is right.
   Its `culprit_id` was `ace_case2`, which matched no profile `id`; it is now `ace`.
   **All of this is superseded**: case 2 was rewritten from its own script — 11 profiles
   (Mr. Leaf and the Fortune Teller included), court reactions, a back alley and its evidence.
   See `data/CASE_2_HOLES.md`.
