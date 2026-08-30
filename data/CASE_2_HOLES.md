# Case 2 — what came from the script, and what did not

Everything in `data/npcs/*_case2.tres` and the court block of `data/case_2.tres` is the
case 2 script, verbatim. The earlier case 2 draft (Officer Skry interview lines, the
`searched_bar_back` / `confronted_ace` flags, the half-written profiles) was replaced.

## Straight from the script

- All 11 NPCs: passive line, every player option, every response, every confront.
- Refunding confronts: **Mr. Ken, Grey, Rob Berr, Ms. Leaf, Green, Ace** — the script marks
  each of these "(refunds 1 confrontation point)". They use the `refunds_confront` flag on
  the confront entry, so those confronts are free.
- Ace's 4th option ("after getting evidence from the back alley of the bar") is a second
  confront entry with `priority = 5` and `requires = ["searched_back"]`, so it replaces the
  denial once the player has been in the alley. It does **not** refund — only Ace's first
  confront does.
- Mr. Leaf's "Ask about their wife" keeps `requires = ["talked_msleaf"]`, granted by Ms.
  Leaf's passive line, as the script says.
- The whole court block: threshold, both questions, all six answers and replies.

Two typos in the script were fixed: "The curt does not like your reason" → "court", and
"The back of the bar lots of blood splatter" → "The back of the bar **has** lots of blood
splatter". Nothing else was reworded.

## Court

`convict_threshold = 50` with `base_strength = 0` on the winning reaction, so the bar is the
script's "50 plus base strength". **The judge always asks for a second piece of evidence**, whoever was accused and whatever was
picked first: the court says `CaseData.second_evidence_prompt` ("The court asks for a second
piece of evidence connecting the accused to the crime.", invented — the script has no line for
it) and **the evidence row reopens** with the first pick removed from it, so the second piece is
chosen the same way as the first. If the player is carrying nothing else, the detective says "No
more evidence, your honor." and the court rules on the one item. Only then does it rule, so a
case is never closed on the first item alone.

The ruling is scored on **what was actually put in front of the court** — the item from the
selector plus that second piece — not on the whole evidence bag. `CourtReaction` has
`requires_evidence` / `forbids_evidence` for that, and `court.gd:_reaction` picks the most
specific match. Order does not matter: knives first then blood reads the same as blood first
then knives.

| Accused | Shown the court | Line |
|---|---|---|
| anyone but Ace | anything | "The court says the person you have accused is innocent." |
| Ace | blood splatter, no knives | "The court does not have enough evidence to suggest that the person you selected is guilty." |
| Ace | knives, no blood splatter | same line |
| Ace | neither (red herrings, or nothing further) | "The court does not see why the person you selected is guilty." |
| Ace | blood splatter **and** knives | "The person you have accused could be guilty, however you must plead your case." + both challenges |

Only the last one has challenges; the rest fall through to the retry offer (-1 attempt) and the
verdict.

Answers pay -5 / -15 / +25 and -15 / -10 / +25, so **50 is exactly both top answers** — one
wrong answer loses the case. A second attempt no longer starts at a strength penalty: an
accusation argued perfectly on the retry still reaches 50 and wins. Attempts are still paid for,
in reputation (-10 each) and in `CaseState.score()` (-150 each), not in case strength.

**Every answer is always offered, proof or not.** `CourtResponse.proof` lists the evidence that
backs a claim (holding any one of them is enough). Pick an answer you cannot back up and the
court says `unproven_reply` — "The court has seen no such evidence." — and pays
`strength_unproven` (0), instead of the reply and the strength. Nothing is hidden from the
player; the claim just does not land.

| Answer | Proof |
|---|---|
| "There are knives around the bar" (-5) | `knives` |
| "The back of the bar has lots of blood splatter" (+25) | `blood_splatter_bar` |
| "There was blood splatter in the back alley of the bar" (+25) | `blood_splatter_bar` |
| "Blood splatter was on the walls of buildings" (-10) | none — see below |
| both "Trust me bro" | none |

"Blood splatter was on the walls of buildings" is the red-herring answer and uses the new
follow-up fields: after its reply the court asks which buildings, the player picks "The
convenience store" or "Green's house", and either way it answers "The picture taken does not
show blood splatter corresponding to what you said. The court thinks this evidence is
unreasonable." The -10 is already paid, so the choice is flavour — as the script has it.

Court prompts and replies are single strings in the data, and some run past the three lines the
dialog box shows, so `court.gd` runs them all through `DialogueUtil.pages()`, which breaks a
string into pages on sentence ends (then on words). Authoring stays one line per reply.

## Not in the script (engine or level work)

1. **`title` and `briefing`** are still the earlier draft's — "murder lmao", and the Officer
   Skry / "3 Confrontations" briefing. The script gives no title, premise or confront count.
   `max_confronts = 3` comes from that briefing line, not from the script. It is enough: only
   Fortune Teller, Officer Red, Mr. Leaf, End, Jigsaw and Ace's confession cost a point, and
   the intended route (one lead + Ace's confession) spends two.
2. **`verdict_guilty` / `verdict_acquit`** are placeholders. The script stops at the second
   challenge.
3. **The back alley.** `scenes/rooms/bar_back.tscn` is new — a copy of `mart_back.tscn`, which
   was already using `sprites/bar-backroom.png`, with `scenes/evidence/blood_splatter.tscn`
   in it (evidence id `blood_splatter_bar`, grants `searched_back`). The way in is a new
   `BackDoor` in `bar.tscn` at (33, 56), the door drawn in the top left of the bar interior art,
   with a `back_entrance` spawn below it. Positions were eyeballed against the art — move them
   if they sit wrong in game.

   **Evidence in case 2**, four pieces:

   | id | where | what it does |
   |---|---|---|
   | `blood_splatter_bar` | `bar_back` | real. grants `searched_back`, half the accusation |
   | `knives` | `bar`, at (196, 62) | real. the other half. `scenes/evidence/knives.tscn`, new |
   | `blood_spatter_green` | `lefter_branch` | red herring (note the id spells it "spatter") |
   | `blood_splatter_cs` | `bottom_branch` | red herring |

   All three blood splatters draw at `z_index = 2` on their `CaseObject`. `evidence_item.tscn`
   sets `z_index = -1` on itself, which puts it under the floor tilemap, so every placement has
   to lift it back up — the alley one was still at -1 and invisible.

   The red herrings are scored nowhere: carrying them is the "neither" row of the table above,
   and no answer takes them as proof. They only exist to be picked in the evidence selector and
   to make the "walls of buildings" answer tempting.
4. **`bar_lead` gates that door**, the same shape as case 1's `mart_lead`. It is granted by
   the three confronts that point somewhere: **Officer Red** ("check near the buildings"),
   **Mr. Leaf** ("the left side of the city") and **End** ("the mid left area of the map").
   The bar is in `left_branch`, so all three point at it. Locked text ("The back door. No
   reason to go through it yet.") is invented — the script has no line for it.
5. **Ms. Leaf stands outside**, next to Mr. Leaf in `right_branch` at (124, 128), in both cases
   — her passive line is what unlocks his "Ask about their wife" option, and the player has no
   reason to be inside her house. `ms_leafs_house` is now empty; Mr. Leaf's "Ask about the
   place" still grants `can_enter_leafs_house`, so it can be walked into, but nothing is in it.
6. **Leave option text** is the default "See ya later" and `leave_response` is empty for every
   NPC, same as case 1. The script has no goodbyes.
7. **NPC placement** reuses case 1's spots: every room now holds both a case 1 and a case 2
   copy of its NPC at the same position, and `npc.gd` frees whichever does not match the
   running case. Ms. Leaf is in `ms_leafs_house` for both cases — the copy of her that stood
   next to Mr. Leaf in `right_branch` had no `case` set, so it was freed on every load and
   never appeared; it was removed.
