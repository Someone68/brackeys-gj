# Case 3 — what came from the script, and what did not

All 11 profiles in `data/npcs/*_case3.tres` and the court block of `data/case_3.tres` are the
case 3 script, verbatim. Everything visual is recycled: the same NPC scenes, the same house
interior art, the same blood and knife sprites as case 2.

## Straight from the script

- All 11 NPCs: passive line, every player option, every response, every confront.
- Refunding confronts: **Grey, Rob Berr, Mr. Leaf, Ms. Leaf** — the four the script marks
  "(refunds 1 confrontation point)".
- Ms. Leaf's 4th option ("after getting evidence of her room") is a second confront entry with
  `priority = 5` and `requires = ["searched_leaf_room"]`, so her denial is replaced by the
  breakdown once the player has been in that room. It does not refund.
- Mr. Leaf's "Ask about their wife" keeps `requires = ["talked_msleaf"]` from her passive line.
- Ace has three non-confront options here ("Ask for a drink" is new), Ms. Leaf has two
  ("Get closer" is gone). Both match the script, not case 2.
- The whole court block: both questions, every answer, every reply, and the two branching
  follow-ups.

## Court

`culprit_id = "msleaf"`. **The script's court section says "If player accuses anyone else except
for Ace"** — that line is left over from case 2; every other line in the same section names Ms.
Leaf, so it is read as "anyone except Ms. Leaf". Change it if that guess is wrong.

Same five-reaction shape as case 2, scored on what was actually put in front of the court (the
selector pick plus the second piece the judge asks for):

| Accused | Shown the court | Line |
|---|---|---|
| anyone but Ms. Leaf | anything | "The court says the person you have accused is innocent." |
| Ms. Leaf | blood, no knives | "The court does not have enough evidence to suggest that the person you selected is guilty." |
| Ms. Leaf | knives, no blood | same line |
| Ms. Leaf | neither | "The court does not see why the person you selected is guilty." |
| Ms. Leaf | blood **and** knives | "The person you have accused could be guilty, however you must plead your case." + both challenges |

A second attempt costs nothing in case strength — losing the first accusation cannot doom the
case. Both best answers reach 15 on attempt one or attempt two alike; attempts are paid for in
reputation (-10 each) and `CaseState.score()` (-150 each) only.

**The strength numbers do not add up as written.** The script asks for "at least 15 plus base
strength", but the best answers pay +5 and +5 — 10 in total, so 15 is unreachable. The winning
reaction is therefore given `base_strength = 5` and `convict_threshold = 15`: playing both best
answers lands on exactly 15 and convicts, the same "one wrong answer loses it" shape as case 2.
Change `base_strength` if the intended reading was different.

Unlisted numbers, invented to keep the two branches symmetrical:

| Answer | Strength | Source |
|---|---|---|
| "There were knives spread around some buildings" | 0 | script gives none — it only sets up the follow-up |
| "There were blood splatter on buildings" | 0 | same |
| follow-up "Convenience store" | -10 | script gives none; mirrors the knives follow-up's "Bar" (-10) |

**Branching follow-ups are new.** `CourtResponse.followups` is now an array of `CourtResponse`,
so each follow-up carries its own label, reply and strength, and `court.gd:_apply_response`
recurses into it. Case 3 uses it for both "explain yourself" questions; case 2's "which
buildings" question was migrated to the same shape (both of its options still lead to the same
reply and pay nothing, as its script has it).

Answers are never hidden. `proof` gates only whether a claim is *accepted*: pick one the player
cannot back up and the court says "The court has seen no such evidence." and pays nothing.

## Evidence and the map

| id | where | what it does |
|---|---|---|
| `blood_splatter_leaf` | `ms_leafs_room` | real. grants `searched_leaf_room`, half the accusation |
| `knives_leaf` | `right_branch`, (212, 62) | real. the other half — "small knives close-ish to her house" |
| `blood_spatter_green` | `lefter_branch` | red herring, recycled from case 2 (its `cases` now lists case 2 and 3) |
| `blood_splatter_cs` | `bottom_branch` | red herring, recycled the same way |

- **Green and Grey are on the left** (`lefter_branch`, `left_branch`) and **Ms. Leaf's house is
  on the right** (`right_branch`) already, from the earlier cases. Nothing moved.
- **Her house stays tidy; her room is the mess.** `scenes/rooms/ms_leafs_room.tscn` is a copy of
  the house scene using the same `house-interior.png`, reached through the door drawn on the
  right wall of the house art (`RoomDoor` at (219, 110), spawn `room_door` below it). The gore —
  17 recycled blood splatters — hangs off a `CaseObject` with `cases = ["case_3"]`, so cases 1
  and 2 see the same room empty and clean.
- **The kill counter is on the wall**, `sprites/killcounter.png` at (160, 52), built on
  `scenes/interactables/interactable.tscn` so it reads out three lines when the player walks up
  to it (invented text — the script has none). It hangs off the same case 3 `CaseObject` as the
  blood, so it only exists in case 3.
- **No body pile.** The script asks for one; there is no sprite for it, so the room is dressed
  with blood and the counter instead.
- **`leaf_lead` gates her room.** Granted by the confronts that point right or at her — Mr. Ken,
  Officer Red, Rob Berr, Green and Jigsaw — so the player has to ask around before the room
  opens, which is what "make the blood and the knives not too obvious" asks for. Getting into
  the house itself still needs `can_enter_leafs_house` from Mr. Leaf's "Ask about the place".
  Rob Berr's confront refunds, so the lead is reachable inside the 5-confront budget.

## Not in the script

1. **`title`, `briefing`, `max_confronts = 5`, `base_evidence_required = 4`** are the ones that
   were already on `case_3.tres` ("5 missing", 5 civilians missing). The script gives none of
   them.
2. **`verdict_guilty` / `verdict_acquit`** are still placeholders.
3. **Mr. Leaf's second confront.** The script's evidence summary says "Confront Mr Leaf and he
   will break and say that the killer is nearby", but no line is written for it, so only his one
   written confront exists. The same summary describes Ace, Jigsaw and the Fortune Teller
   differently from the dialogue section; the dialogue section was used.
4. **Leave option text** is the default "See ya later" with an empty `leave_response`, as in the
   other two cases.
5. **Locked-door text** ("Her room. No reason to go through her things yet.") is invented.
