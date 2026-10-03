# Triggers

`trigger<area>.bin` says what happens in an area's maps as the story goes on: what a character says, which event plays when you talk to someone, enter a map or walk into a box, and how the story stage and flags move. There are 75 files, one per area. Each is a [tagged data table](Tagged-Data-Table) whose records all have tag 1. The record head's shape is observed. The words were first read by measure, **every reading INFERRED**, each with the measure behind it. Several operations are not decoded. Counts are from the European release (game code `YDQP`).

**EU only:** Since 28 September 2026 much of the file has been read from the game's code. It is a script the game runs. Each record is kept only for the current map and stage, has a **kind** (value 5) that says when the game asks for it, and splits into conditions and actions. The game takes the first record of a kind whose conditions hold, and runs every action of it. The story it moves is five threads, each with its own stage, flags and marks: see [Story threads](Story-Threads). Code addresses on this page are the USA release's (`YDQE`), from the decomp. The files were read on the European release; every trigger file has since been checked byte for byte the same on the US release.

## Layout

5,805 tag-1 records in all, 352 of them in Angel Falls. Each record is:

1. a **map id** (the id from [Map-List](Map-List) slot 0). Angel Falls' records name the village, 1100, on 156, and its interiors 1101 to 1112 on the rest.
2. **four numbers** in the shape of the cast's stage span (see [Area-Cast](Area-Cast)). **EU only:** Read from the code, they are from-major, to-major, from-minor, to-minor. The game keeps a record only if `from ≤ now ≤ to`, each taken as `major × 1000 + minor`, against the live story thread's stage.
3. **one small number** (0, 1, 11, 3, 20 …), called "value 5" below. **EU only:** It is the record's **kind**. The game asks for records by kind; see [Kinds](#kinds).
4. **words**, each an integer: its high half an operation, its low half an argument. Some records also carry floats, which are not words. **EU only:** The game's parser gives each operation a fixed number of the values after it as its own. So some values that look like words are arguments: the three `0 : n` after `132` are its stage, the `event : 0` after `133` is its event (the parser keeps `value >> 16`), and the six floats and an integer after `143` are its box.

**EU only:** The record the game keeps is `u16` map, `u8` from-major, to-major, from-minor, to-minor, `u8` kind, then its words.

### Characters and events

| check | result |
|---|---|
| records with a high half of 6 or 118 whose low half is a character of the area | 4,067 of 5,805 |
| that character placed in the record's own map | **3,433 of 5,200 (66%)**, against 945 (18%) for another character of the same area |
| the same, in records that also carry a high half of 119 | 233 of 306 (76%), against 81 (26%) |
| Angel Falls words with a high half of 119 whose low half is an event number | **58 of 64**: 2110, 2370, 2420, 2620 and more |

So a record plausibly reads: in this map, over this span of the story, this character; and some records go on to name an event. That was **INFERRED**, as were the readings below until some were read from the code.

**EU only:** The code bears it out. `6` is a condition that holds when the character the game asks with is its argument, and `119` an action that starts the event (see [Conditions](#conditions-read-from-the-code), [Actions](#actions-read-from-the-code)).

**Some words choose what a character says.**

- In records that name a character, the argument of operation 11 is one of that character's talk labels on **707 of 793**, against 221 for a control.
- Operation 36 with argument 1 goes with a word whose high half is one of the character's labels and whose low half is 0, **338 of 519** times, against none.
- Where a record names an event instead, the event's text is that character's own talk for the sub-stage. In Angel Falls, one villager's records at 2.1 to 2.5 name `ev02110`, `ev02370`, `ev02420`, `ev02570` and `ev02620`, one for each sub-stage, and each opens with her line for it (see [Event-Text](Event-Text), [Character-Dialogue](Character-Dialogue)).
- **EU only:** Read from the code: `11` is a condition that holds when the label the talk was asked with is its argument. `118 : c`, with a value whose high half is a label, is an action that starts a talk with character *c* and that label. In `6:7 118:7 192:0`, `192:0` is `118`'s value: label 192. `36` is a condition on a value INFERRED to be the Hero's HP (see [Conditions](#conditions-read-from-the-code)).

**Story stage 2.1 in Erinn's house.** A record for map 1107, Erinn's house, over 2.1 alone, names her and `2130`, the event in which she greets the Hero in the morning. It names map 1110, the floor above.

### Which record decides a line

> **EU only.** Code addresses are the USA release's (`YDQE`) overlay 17 and ARM9, from the decomp. The trigger files were read on the European release (`YDQP`) and have been checked byte for byte the same on the US one; the cast's talk boxes were read on the European release only.

Read from the game's code on 28 September 2026. It replaces an INFERRED reading (see [Earlier readings](#earlier-readings)).

**Whom the Hero talks to** (`func_ov017_021a4e88`): of the cast, anyone whose talk box (the cast's tag 6, see [Area-Cast](Area-Cast)) holds the Hero, strictly, on the ground; and anyone within 1.5 across and 1.75 away (`0x1800` and `0x1c00` in fx32). A thing to examine (the cast's kind 1) is talked to only from a box. Of those, the game takes the one most nearly faced (by `func_ov017_021a4700`, under `0x3244`; whether that is π in fx32 radians is not established). **The talk's label is the box's**, or 0.

**Then three steps** (`func_ov017_021a4cf0`, then the talk's own machine, `func_ov017_021b8e8c`):

1. **Kind 0, the character's own records**, with who is talked to at context `+0` and the label at `+0x14`. The first that holds runs, every action, and its queue. A `118` starts the talk with its label, a `119` plays an event, and a record with neither runs and says nothing. With none holding, the talk starts with the label asked.
2. **The line** (see [Character-Dialogue](Character-Dialogue)). With none, the talk ends and nothing more runs.
3. **Kind 1, the talk records**, once the line's window has closed, with who and the label the talk was asked with. The prompt's answer is tested by condition `16`, and is 0 after a line with no prompt. The first record that holds runs, its queue with it: a `119`, a hand-on, a stage move, or another `118`, and the talk goes round again with the new label.

Examples:

- Ivor at the landslide, `6:7 118:7 192:0` then `6:7 11:192 119:2350`. His own record asks 192, his line for it is said, and the talk record for 192 plays `ev2350`.
- Yggdrasil has no record of its own. Talked to from its box, it asks 80. Its line 96 asks "Offer the benevolessence up to Yggdrasil?", and on Yes `6:199 11:80 16:0 119:21510` plays.
- Stornway's #11 asks 192 only once mark 4 is set, which talking to #4 from its box sets.

So a talk record's event plays after the line, not instead of it, as the let's play shows (see operation `16` below). A character's own record that names an event plays it only when the character is talked to: kind 0 is asked for by the field's talk.

## The operations

A word's high half is an operation and its low half an argument. Every reading in the first table was first **INFERRED**, with its measure. Measured across all 75 files (5,761 records read).

**EU only:** Many have since been read from the game's code, and the row says so where they have. Operations below 100, and from 500, are **conditions**, tested by `func_0205faf4`, a switch on the operation. Operations 100 to 499 are **actions**, run by `func_02061c04`, a switch on `op − 100` (read for 100 to 233). Operations not in the first table are in [Conditions read from the code](#conditions-read-from-the-code) and [Actions read from the code](#actions-read-from-the-code). The value 5 rows are the record's kind; [Kinds](#kinds) says when the game asks for each. Trigger operation numbers are not the event scripts' function numbers (see [Engine-Functions](Engine-Functions)).

| operation | reading | measure |
|---|---|---|
| value 5 = 11 | the record belongs to an event: what follows it. **EU only:** The game asks for kind 11 at the end of an event (`func_ov017_021bc77c`, at `0x021bcab8`), and takes the first whose conditions hold, not merely the first: that settles the Observatory's two at 15.3 | 646 records, **every one** naming its event with operation 8 |
| 8 : event | the event the record is about. **EU only:** A condition: the event the game asks with is the argument (context `+8`) | as above |
| 132, then three words of operation 0 | the story moves to stage *a.b*, step *c*, the three arguments. **EU only:** Read from the code (`0x02062644`): it queues a move of the **live thread's** stage, the three values its own, applied after the record's actions and **only forward** (see [Story threads](Story-Threads)). It moves the story whatever the record's kind: a talk, entry or battle record's `132` runs with its record | 170 records. **166** go to the record's own stage (81), the next minor stage (74) or the next major (11). Under one stage the steps run without a gap in **96 of 99** |
| 104 : n | sets flag *n*. **EU only:** Confirmed: bit *n* of the live thread's flags (`0x02061f9c`, through `func_0206df6c`). `105` clears it | — |
| 4 : n | holds only if flag *n* is set. **EU only:** Confirmed | **518 of 664** 4s and 5s have a 104 of the same *n* in the same area and stage |
| 5 : n | holds only if flag *n* is not set. **EU only:** Confirmed | as above |
| 133 : map, then *event* : 0 | goes on to that map (by id) and plays that event. **EU only:** Read from the code: one case of the queue with `138` and `226`, a map change and the event played there. The parser takes one value as `133`'s own, the event, as `value >> 16` | **16 of 29** name an event whose own record is in that map |
| 118 : character | **EU only:** Read from the code: an action that starts a talk. With a value whose high half is a label, it has the Hero talk to that character with that label (queue case `0x0206fa98`). 3,340 records | seen in character records beside their talk labels |
| value 5 = 1, with 6 : character, 11 : label and 119 : event | talking to the character, when their chosen label is that one, plays that event instead. **EU only:** Read from the code: kind 1 runs once the label's line is read; see [Which record decides a line](#which-record-decides-a-line) | of the 179 talk records with a label and an event, **97** have the same character's own record choosing that label in the same map and span, first in the file on all 97. Example: Ivor's at the landslide, `6:7 118:7 192:0` then `6:7 11:192 119:2350`. The other 82 are not established |
| value 5 = 3, with 9 : map and 119 : event | entering that map plays that event. **EU only:** Read from the code: the field asks kind 3 on arriving in a map and runs the first that holds **whole**: its `119`, `124`, `143` and every other action | 244 of the 249 open with 9, naming their own map every time. 49 play an event, 24 only while a flag holds. Example: the pass at 2.2, `9:5101 5:2 203:1 119:2300`, "Finally! We're here at last." |
| 104 : n on an entry record | sets flag *n* as its event plays. **EU only:** Confirmed: an entry record runs every action | of the 49 entry records that play an event, **7** set a flag themselves, and **every one** holds only while that flag is unset, so it plays once. Only one of their events has a record of its own, and it does not set the flag. The village's at 2.1 plays the Guardian statue scene, `ev22590`, and sets flag 0 |
| 86 : 0 | holds when the Hero has no companion with them. **EU only:** Partly read from the code: `86 : 1` holds when someone of a kind the game marks (`func_02061bd8`) in the party is up, or failing one, its object `0xce` is there; `86 : 0` otherwise. That the marked one is whoever goes along, Ivor, is INFERRED | all 7 in Angel Falls have argument 0, and each sits before a character's first-time event, giving the label that follows instead. Ivor speaks in every one of those events (2222, 2230, 2240, 2250, 2430, 2440, 2450). An earlier guess, day or night, fails: only 2 of 13 across the cartridge have a twin record |
| 102, 2, 3 | a second set of flags, "marks": 102 sets one, 2 holds if it is set, 3 if it is not. **EU only:** Confirmed: bit *n* of the live thread's marks (`0x02061ee4`); `103` clears one. Marks last the major stage: a new minor stage clears flags but not marks | of the 57 sets, **31** sit in a record that also tests 3 of the same mark (the first time a character is talked to), and 24 of those have a partner record for the same character, map and span testing 2 of it. Example: Hugo's `3:7 119:2430 102:7`, then `2:7 118:8 193:0`. Tests (280 and 298) far outnumber sets, so something else sets marks too. An earlier measure, 145 of 566, counted every test against any set |
| 35 : n | holds only at step *n* of the stage. **EU only:** Confirmed | of the 128 records testing it, **94** name a step that some event in the same file moves the story to at that stage, against **20** for the step three on. The Hexagon's switch, `201`: nothing at steps 1 to 3, `ev02530` at 4 ("There's a noise of something moving somewhere!"), its after-line at 5 |
| 120 : n | starts set battle *n* (see [Event-Battles](Event-Battles)) | all **40** arguments are indices there. **65 of the 66** records carrying one have a value 5 = 15 record in the same map naming the same *n* |
| 205 : n on an event's own record | brings the attending character at place *n* (from 0) of `attnpc` into the party (see [Attending-Characters](Attending-Characters)) | the three events whose own text says who joins carry that character's place: `ev02210`, "Ivor joins the party", `205:1`; `ev04080`, Dr Phlegming, `205:2`; `ev28991`, Sterling, `205:3`. 6 event records carry it, all with 1 to 3. On a character's record (31 of them) not read |
| 204 : 1 on an event's own record | sends whoever goes along with the Hero away | all **6** event records carrying it have 1, in Ivor's stretch, Dr Phlegming's and Sterling's alike, so the 1 does not name who. Ivor's two, `ev22591` and `ev02400`, are where a let's play video shows him leave (on ahead to the landslide; home with his father), and he joins again at the landslide, `ev02350`, `205:1`. On a character's record (35 of them) not read. `203`, on two entry records (the pass's `203:1`, the mayor's `203:0`) and 71 characters' records, is not read either |
| 16 : n on a talk record with a label and an event | the event plays once the label's line is read, and only on the prompt's answer *n*, from 0 (0 is Yes). **EU only:** Confirmed: the text system's last answer (`func_020457e0`, `+0x954`). A talk's window sets it to 0 as it opens (`func_0204500c`), so after a line with no prompt `16 : 0` holds. 432 records | in Angel Falls, the pass and the Hexagon, 7 of the 9 such records carrying it have a line that asks a question (one more is the inn's welcome, one has no line found), against 3 of the 17 without it. The Hexagon's switch, `6:201 11:194 16:0 119:2530`, asks "Press the button?". In a let's play video, answering No, the Hero decides not to, and nothing moves. A talk record's event is played after its label's line, not instead of it: the video reads the inscription, "Path ahead sealed…", before `ev02500` |
| value 5 = 15, opening with 12 : n | once set battle *n* is won: plays the event, sets the flags. **EU only:** Read from the code: the end of a set battle asks kind 15 when won and 16 when lost (ov017 `0x021b7c54`, `0x021b7c3c`), and `12` holds when the set battle asked with is the argument (context `+0x18`) | 46 of the 47 open with 12. The Hexagon's `12:2 119:2550` plays Patty's thanks |
| value 5 = 16, opening with 12 : n | once set battle *n* is lost. **EU only:** Confirmed as the lost outcome, above | all 33 open with 12. INFERRED as the other outcome: the Hexagon's `12:2 104:4 197:10` sets the flag under which Patty offers the fight again |
| value 5 = 20, with 143 : n and six floats | defines area *n*: a box, its greater corner then its lesser, x y z, in the units placements use. **EU only:** Then an integer, the box's **angle in degrees** about the vertical, read from the code (see [Areas](#areas)). `143` is an action that adds its area whenever its record runs; kind 20 is run as the file loads | all **108** area words have six floats, and the first three are at or above the last three on every axis on **108 of 108**. The boxes sampled lie inside their maps |
| value 5 = 2, with 7 : n | walking into area *n* plays the record's event. **EU only:** Read from the code: the field asks kind 2 on entering an area, with its number as the context, which `7` tests | **102 of the 110** name an area defined in their map. **EU only:** The rest are the map's own areas, in its link table (see [Areas](#areas)). The mayor's house at 2.1, `7:15 5:1 119:2120`, plays his scene with Ivor, whose record sets flag 1 |
| 133 on a talk record | once the line is read, goes on to that map and event. *Corrected 4 October 2026*: this row read the `177` beside it as "if the prompt's answer was *n*"; `177` is the [day's clock](Time-Of-Day), and the answer is `16`'s. Erinn's at 2.1, `6:98 11:193 16:0 177:0 1:0 133:1110 2130:0`: on the answer Yes (`16:0`), the clock started at morning (`177:0`, its word `1:0`), then on to the morning's map and event |
| 145 : n on a character's record | talking to the character opens facility *n* | **Read** (USA only, `func_0206f81c` case 31, table `0x02070134`): 0, 1, 3 and 4 nothing; **2 the Rapportal**; **5 DQVC**; **6 DQVC without connecting**; **7 the mini medals** ([Mini-Medals](Mini-Medals)); 8 `memory2.stb` — see [The Quester's Rest](Questers-Rest). **58** occurrences, always beside `6` on a character's record. The numbering is not the line-tag facility codes' |
| 17 : n | **EU only:** Read from the code: `17 : 1` holds by night, any other argument by morning, day or evening (`GameState::IsMorningDayOrEvening`) | never paired with anything that sets or tests it |

**Flags belong to the stage.** They are cleared when the story moves on to another stage. The tests find their setter in the same stage. **EU only:** Confirmed from the code, with a correction for marks: flags are cleared when the major or minor stage changes, marks only when the major does. Both belong to the live story thread (see [Story threads](Story-Threads)).

### Conditions read from the code

> **EU only, checked in part.** Code addresses are the USA release's (`YDQE`), from the decomp, read on 28 September 2026. The records counted were read on the European release (`YDQP`); every trigger file has since been checked byte for byte the same on the US release.

All are cases of `func_0205faf4`. The game-wide flags, the thread's flags and marks are described on [Story threads](Story-Threads).

| op | holds when |
|---|---|
| 0, 1 | a game-wide flag (the bank at `+0x8c` of the trigger object) is set, clear |
| 6, 7, 9, 12 | the context's character, area, map, set battle is the argument (context `+0`, `+4`, `+0xc`, `+0x18`). `8`, the event, is the same test at `+8` |
| 11 | the context's label (`+0x14`) is the argument: the label the talk was asked with |
| 13, 14, 15 | the party's size, the filled slots of four with the Hero among them (`func_02010890`), is at least, at most, exactly the argument. Gortress's captain at 14.3 speaks one way to two or more (`13:2`) and another to the Hero alone (`15:1`) |
| 18, 19 | the bag holds the item, holds none (`func_02086aec`) |
| 20, 21, 22 | a quest is taken, has its first flag, is cleared (see [Quests](Quests)) |
| 23 | a test of a session object's first word and one more state: 0 with no session, 1 with one, 2 with none or one kind of player, 3 only the other. INFERRED multiplayer, from the flag actions using the same test to decide whether to send a change over the link. Played alone, 0 and 2 hold |
| 26, 27 | a game-wide flag named by its number is set, clear (`func_0206eb98`): below `0x400` the bit itself, from there displaced by 1,786, the rule the cast's placement script uses too. 427 records |
| 32, 33 | the party tricks performed; see [Party tricks](#party-tricks--kind-19) |
| 36 | a value of game object 0 (`+0x130`, then `+4`) is above 0 for `36 : 0`, at or below 0 otherwise. **INFERRED, the Hero's HP**: the same block holds another value beside it at `+6`, the block at `+0x134` two more at `+0x30` and `+0x32`, and the field copies all four from a packet together (ov017 `0x021c9fac`): HP, MP and their maximums. 545 records |
| 41 | the Hero stands in one of the context character's talk boxes (`41 : n`, n not 0) or in none (`41 : 0`); see the cast's tag 6 on [Area-Cast](Area-Cast). 72 records, all characters' own, at the Quester's Rest and Stornway's counters |
| 52 to 63 | **composites**. Each names a character (as `6`, its argument) and tests more, taking each of its values as a high and a low half in turn. 52 is `6`, `5` (a flag clear) and `23`: Stornway's lobby at 2.7, `52:205 3:2 119:2940 104:3`, is talking to 205 with flag 3 clear. 62 and 63 are `6`, a game-wide flag set (`0`) or clear (`1`), and `23`. 53 to 61 also test a quest named by their first value (`func_0206474c`; see [Quests](Quests)). 53 adds `11` and `16`, 54 an `18`, 56 a `36`, 57, 58 and 61 a `23`. 1,495 records carry one |
| 81 | `81 : 0` holds with no session (`func_0202b7d8`), `81 : n` never. INFERRED multiplayer, as `23` |
| 88, 89 | a game-wide flag of the block from bit 830 is set, clear: `88 : n` tests bit `830 + n`, for n below 73 (from 73, `88` fails and `89` holds). The Quarantomb's records test 71 and 72, which action `220` sets |

### Actions read from the code

> **EU only, checked in part.** Code addresses are the USA release's (`YDQE`), from the decomp, read on 28 September 2026. The records counted were read on the European release (`YDQP`); every trigger file has since been checked byte for byte the same on the US release.

All are cases of `func_02061c04` unless the row says otherwise. Some only queue an entry (`func_0206445c`), which the queue applies once the record's actions have run (`func_0206f81c`; see [How the game runs the file](#how-the-game-runs-the-file)).

| op | what |
|---|---|
| 100, 101 | set, clear a game-wide flag: a bit of the bank at `+0x8c` of the trigger object, outside any thread, so no stage move clears it (`func_0206df6c`) |
| 103, 105 | clear a mark, a flag of the live thread |
| 106 | clears a character's talk counts |
| 108 | run alone, without the rest of its record, by map loading and a doorway transition (see [Kinds](#kinds)). What it does is not established |
| 110 : n | `GameState::SetTimeOfDay(n)`: the [day's clock](Time-Of-Day) to phase *n*'s start |
| 177 : a, v | the [day's clock](Time-Of-Day) **running when *a* is 0**, stopped otherwise, and at phase *v*'s start — *v* the high half of the next word (case 77, read 4 October 2026) |
| 114 : i, 115 : i | give and take item *i*, both queued (queue cases `0x0206fcc0`, `0x0206fd74`). **Which is which is INFERRED** from the items they carry: `114` the fygg, the party popper and Sterling's whistle, `115` the Drunken Dragon and the Gittish seal handed back. The whistle is given at 19.1 by `114:22256`, on the record for winning set battle 27 (see [Starflight Express](Starflight-Express)) |
| 119 : e | **starts event *e*** (queued). The scene plays in the map its event-list entry names: if that is another map, the game changes map first (see [Event lists](Event-Lists)). Of the 620 scenes the records start, 47 play in a map other than the one whose record starts them |
| 124 : c | **takes character *c* out of the map** (queue case `0x0206fca0`): the object is found by its id (`func_0203df78`) and bit `0x8000` of its first word set, which every lookup of the map's objects skips from then on (`func_0203df78`, `func_0203dce4`). Gone until the map is next placed. Gleeba's Drak leaves so after his talk at 11.2, `124:200` |
| 125, 127, 129, 130, 131, 144, 176, 190, 191 | a quest's actions: accept, clear, put on offer, set and clear its flags, its progress, and a taken quest's own numbers (see [Quests](Quests)) |
| 128 | queued, as `118` and `119` are. What it does is not established |
| 138, 226 | map changes, one case of the queue with `133`, each setting one flag on the move that `133` does not. What the flags do is not established. `ev2910`'s `138` is how Angel Falls hands on to Stornway |
| 142 : n | teaches party trick *n* (`0x02062a80` → `func_0206e348`); see [Party tricks](#party-tricks--kind-19) |
| 143 | adds an area; see [Areas](#areas) |
| 148 | moves **all five threads'** stage, with three values as `132`. `ev28800` at 13.1 brings the threads back together at 13.2; winning set battle 25 at 17.2 plays `ev29300` and sets all five to 19.2 (see [Story threads](Story-Threads)) |
| 149, 150 | set a map piece on, off (`func_02019508`, `func_02013380`), or, for a piece not in the map, a bit of the thread's bank at `+0x08` or `+0x14` (`func_0206ea8c`) |
| 155 : e | with a value `f : 0`, sets flag *f* (it runs `104` with its value) and plays event *e* (queued, as a `119`). All 14 are Gortress's, on its characters at 14.4: `52:203 7:2 155:28991 7:0` |
| 197 : n | **sets the [Story So Far](Story-So-Far)'s number**, `GameState+0x5CBC` (`func_02010810`): the page the Y Button shows is message *n* of `str_ol`. Set at once, forwards or back; a 40-byte block is cleared when the old and new fall in different ranges of a table (`0x020636b4`), the continue screen's comment groups. On nearly every event's own record |
| 214 : n | moves **thread *n*'s** stage, with three values as `132` (`0x02063e40`); see [Story threads](Story-Threads) |
| 215, 216 | start the Starflight Express, and set the stop it is at (`0x02063e80`, `0x02063eac`); see [Starflight Express](Starflight-Express) |
| 220 | **the Quarantomb's switches** (`func_020aee04`). Parsed as two bytes: which switch (1 or 0) in the high, whether it is on in the low. It does nothing outside map 7402. There it turns the map's pieces `0x4e`–`0x58` (which 1) or `0x37`–`0x4b` (which 0) on, and **sets game-wide flag 830 + 71 or 830 + 72 to it** (`func_020ae4ec`), the block that `88` and `89` test. `220:257` sets 901, `220:1` sets 902, and `ev24590`'s record clears both with `220:256 220:0`. Talking to `107` and `108`, in either order, sets both and plays `ev24590`. All 14 records with it are the Quarantomb's |
| 225 : map | queued, and not read. It sits on records that end in a new map (`ev29004`'s `225:4301`) |

## Kinds

> **EU only, checked in part.** Code addresses are the USA release's (`YDQE`) ARM9 and overlays, from the decomp, read on 28 September 2026. The records counted were read on the European release (`YDQP`); every trigger file has since been checked byte for byte the same on the US release.

Value 5 is the record's **kind**. The only way a record runs whole is `func_020649b0`: the first record of the kind whose conditions hold, then every action. Every call to it in the ARM9 and the overlays was found, so the list below is **every kind that is ever asked for**. Three callers go through a thunk that fixes the kind: `func_020649f4` is kind 3, `func_02064a08` kind 15, `func_02064a24` kind 16.

| kind | asked for by |
|---|---|
| 0, 1 | the field's talk (`func_ov017_021a4cf0`, `func_ov017_021b8e8c`): 0 before the line, 1 after it. See [Which record decides a line](#which-record-decides-a-line) |
| 2, 5 | the field, on entering and leaving an area (`func_ov017_0219814c`, `func_ov017_02198e30`, and at `0x02198f48`). **No record on the cartridge is of kind 5** |
| 3 | **the field, whole, on arriving in a map** (ov017 `0x0219f3a0` and `0x0219fd80`) |
| 6 | the field's frame update, every frame (`0x0219cd7c`); see below |
| 9 | `func_02064a40`, from the protagonist's area byte. **No record on the cartridge is of kind 9** |
| 10 | a script function (ov001 `0x021551dc`) |
| 11 | the end of an event (`func_ov017_021bc77c`, at `0x021bcab8`) |
| 12 | ov003 `0x02159f58` |
| 15, 16 | the end of a set battle, won and lost (ov017 `0x021b7c54`, `0x021b7c3c`) |
| 17 | the field's doorways (`func_ov017_02198f84`, at `0x02198fe4`) |
| 18 | ov017 `0x02199280` |
| 19 | **a party trick performed** (`func_02053634`, through `func_02064a9c`); see [Party tricks](#party-tricks--kind-19) |
| 20 | loading the trigger file (`func_02064574`), which takes the areas. The Bowhole's plays `ev13500` at 13.5 |
| 22 | ov002 `0x02155b30` |
| 23, 24 | ov017 `0x02199190`, `0x021ac9bc` |
| 25 | ARM9 `0x0208b1cc` |
| 26 | ov017 `0x021b9b34`, `0x021b9ba0` |
| 27 | ov004 `0x021648c4`, ov017 `0x021a9f04` |
| 29, 30 | ov017 `0x02199608` and `0x02199660`, `0x0219e720` |

Map loading and a doorway transition also run kinds 3, 20 and 17 **for their `108` alone** (`func_02017a94`, `func_02018300`, through `func_02064b24`, which runs one operation of the first holding record).

**Kind 6 runs every frame in the field.** The field's frame update (`func_ov017_0218cbd4`, which reads the tick count and updates everything) calls `func_ov017_0219ca88`. Once the map's doorways, fades and transitions have had their turn, that asks for the first kind-6 record whose conditions hold, with the map's id as the context, and runs it. The table only ever holds the current map's records, so kind 6 is "while the Hero is in this map and these conditions hold, do this". Angel Falls' church and stable at 1.2, `4:4 4:5 … 132:0 0:1 0:3 0:1`, move the story on the moment both flags are set.

## How the game runs the file

> **EU only, checked in part.** Code addresses are the USA release's (`YDQE`) ARM9, from the decomp, read on 28 September 2026. The files were read on the European release (`YDQP`); every trigger file has since been checked byte for byte the same on the US release.

**Loading.** `func_0206461c` builds the name with `data/scenario/trigger%s.bin` (`0x020f05dc`) from the area's three letters, with the second blanked for an `F` area. It loads the file and hands it to `func_02064574` with the map id and the current stage. That runs the file as a `Script`, with the opcode table at `0x020f05bc`: tags `0x64` and `0x65` do nothing (they return 1), and **tag 1 is the record** (`func_0205f9cc`). Then it runs the first holding kind-20 record whole.

**Only the current map's records are kept.** `func_0205f9cc` reads value 0 and drops the record unless it is the map being entered. It reads values 1 to 4 as a span and keeps the record only if the stage lies within it (see [Layout](#layout)). A kept record is allocated `0x18` bytes, its words are parsed (`func_0205ec70`), and it is added to the table (`func_020643fc`).

**The parser** (`func_0205ec70`) makes a word whose operation is below 100 or from 500 a **condition**, and one from 100 to 499 an **action**. Each then takes a fixed number of the values after it as its own: `132`, `148` and `214` take three, `133` one (an event, `value >> 16`), `143` six floats and an integer, `220` two bytes, `32` and `33` a word. The composites take values whose high and low halves are tested in turn.

**Which record runs.** Records are kept grouped by kind (the kind byte at `+6`). The game asks for a kind with a context: who is talked to, the map, the area, the event, the set battle. It takes **the first record of that kind, in the file's order, whose conditions all hold** (`func_02064490`). It then runs **every one of that record's actions** (`func_020649b0` → `func_02064530` → `func_02061c04`) with a fresh queue, and applies what they queued (`func_0206f81c`).

**The queue.** `118`, `119`, `128` and `155` queue an entry (`func_0206445c`), and so do the stage moves `132`, `148` and `214`. The queue starts talks and events, changes map for `133`, `138` and `226`, takes characters away for `124`, and moves the story through `func_020703c8`, only forward (see [Story threads](Story-Threads)). Flags, marks and game-wide flags change as each action runs; stage moves are applied after. So a flag a record sets on its way into a new sub-stage is cleared by the move.

## Areas

> **EU only.** Code addresses are the USA release's (`YDQE`), from the decomp, read on 28 September 2026. The trigger files were read on the European release (`YDQP`) and have been checked byte for byte the same on the US one. The maps' link tables (`.bmbl`) were read on the European release only and are not yet checked on the US one.

**An area is a box turned about the vertical through its centre.** Two things define them, and the field tests the Hero against each on its own.

- **A trigger's `143`.** The parser takes six floats and an integer as `143`'s own. The integer is the **angle in degrees**: the action (`0x02062a94`) multiplies it by π and divides by 180. It keeps the box, its centre, the angle and a squared radius for a quick refusal, in a list on the trigger object (`+0x494`, through `func_02064af8`). **That radius is made from the box's width and height, not its width and depth**, and the test compares it with the distance across the ground, so a deep, low box is refused short of its far end. 31 of the cartridge's 113 are turned. `143` is on 80 kind-20 records, and also on 3 entry, 3 talk and one event's own record: it adds its area when its record runs. Batsureg's areas 72 and 73 at 10.6 are an entry record's, with no event.
- **A map's own link table**, the `.bmbl` (see [Map-Textures](Map-Textures)): a `0x73` region of **type 3**, its first value (2 is a doorway). The handler for `0x73` (`func_0201d530`) reads a type, a centre, a size (width, height, depth), an angle in radians and one more angle, and makes its squared radius from the width and depth. The handler for `0x74` (`func_0201d638`) gives a type-3 region its number from its first value. Their table is at `0x020ef3d8`, tags `0x64` to `0x7e`. There are 22 on the cartridge, in 15 maps. Stornway's throne room has areas 0 and 1, the only definitions of the areas its records at 3.1 and 3.3 name; walking into area 0 at 3.1 plays `ev3040`. Zere's one is turned 45°.

**The test** (`func_020321e0`). For a turned box, refuse a point further across the ground from the centre than the squared radius allows. Otherwise turn it back about the centre by the angle (`RotationMatrixY(−angle)` applied as a row vector: `x' = x cos a − z sin a`, `z' = x sin a + z cos a`) and test it against the corners, edges included, on all three axes (`func_02031118`). The point is the Hero's own position. An unturned box skips the radius.

**Walking into one** (`func_ov017_02198e30` for a trigger's areas, `func_ov017_0219814c` for the map's own). Each source keeps the first area that holds the Hero (a trigger's at `+0x491`). On a new one it runs kind 5 for the one left, then kind 2 for the one entered, with the area's number as the context. A map region also carries flags that can make it hold once and then no more (`func_02094b9c`); what sets them for an area is not read.

## Party tricks — kind 19

> **EU only, checked in part.** Code addresses are the USA release's (`YDQE`), from the decomp, read on 28 September 2026. Every trigger file and every file under `data/chara` has been checked byte for byte the same on the US release. The trick names were read from `str_tm` on the European release only.

**The game asks kind 19 when a party trick has been performed.** The field object that plays one (`func_02053634`) loads `data/chara/sg<nn><m|w>.chr` (`func_0205308c`). Each holds a `sigusa.nsbca` (仕草, a gesture), for a man or a woman by a bit of `func_02052e2c`'s record. For tricks 12 to 16 and 30 it also loads a sprite, `sg%02d_<LG>.spr`. When its tricks are done and it is the leader's, its update (at `0x020539ac`) copies the up to four it performed to the context's `+0x2a` and asks for the first kind-19 record whose conditions hold. The context's `+4` is the Hero's area, which `7` reads.

**Condition `33`** (`0x02060214`) takes the next word as four bytes, and holds when each nonzero one is among the four performed, no two the same. **`32`** takes a word too and is not read. INFERRED, the same four in order: the quest "We Like to Party" has `32:0 4866:2307`.

**The tricks are numbered as the field menu's strings are**, `str_tm` 4509 + *n*: Bow 1, Clap 2, Air Punch 3, Bye Bye 4, Weep, Despair, Tantrum, Surprised, Jump 9, Sit, Recline, Hello! 12, Thanks!, Goodbye!, Eek!, Hmm... 16, Pray 17, Dive, Pirouette 19, Belly Dance, Royal Regards, Swinedimples Salute 22, Cap'n's Curtsy, Sultry Dance, Weird Dance, Wallop, Cheer, Provoke, Salute 29, Inspiration, Professor's Pose 31.

**Action `142 : n` teaches one** (`0x02062a80` → `func_0206e348`). The game orders the tricks by a table at `0x020e87c0`: `0, 3, 2, 4, …, 11, 18, 12, …, 17, 19, 1, 20, …, 31`. **The first seventeen places are known from the start**: the setter refuses them, and `func_0206e384` reads the rest as a mask. The others are learnt as a bit each of the game-wide bank, from `0xbf1` + place (`func_0206e3e8` gives a trick's place).

11 records use it. Gleeba's Drak answers a Clap in area 10 at 11.2 (`7:10 33:0 512:0 1:322 5:1 23:2 119:11200`). Porth Llaffan wants a Bow in area 34 at 6.4, taught at 6.3 by `142:1`. The Quester's Rest's two quests want an Air Punch and the sequence.

## Story threads

> **EU only, checked in part.** Code addresses are the USA release's (`YDQE`), from the decomp. Every trigger file has been checked byte for byte the same on the US release.

A record's span is checked against the **live thread's** stage, not one stage for the whole game. The game keeps five story threads, and the map the Hero is in decides which is live. `132` moves the live thread, `214 : n` thread *n*, and `148` all five. Stage moves only go forward. See [Story threads](Story-Threads).

## Worked example: the opening

The morning's record, in map 1110: `8:2130 132:0 0:2 0:2 0:1 197:6`. After it the story is at 2.2, step 1.

At 2.2, a character record in 1107, Erinn's house, names Ivor and his event: `6:7 119:2200`. The cast places him there at 2.2 and not at 2.1.

His event's record is `8:2200 133:1100 2210:0`: on to the village, 1100, and `ev02210`, his call on her doorstep. That event's own record is `8:2210 104:0 132:0 0:2 0:2 0:2 197:7 205:1 141:1`: flag 0 set, story to 2.2 step 2, and Ivor into the party.

A villager's record then holds only with flag 0 set and flag 1 not: `6:8 4:0 5:1 119:2220`.

**EU only:** As the game's parser reads them, `0:2 0:2 0:1` is `132`'s own stage, not three conditions, and `2210:0` is `133`'s own event. `197:6` and `197:7` set the [Story So Far](Story-So-Far)'s page.

## Evidence

- The counts in the tables above are across all 75 files (5,805 records; 5,761 read for the operation measures).
- Event numbers are checked against `ev#####` event files (see [Event-Text](Event-Text), [Event-Scripts](Event-Scripts)).
- Story-order and prompt readings are checked against a let's play video.
- **EU only:** The readings marked as read from the code come from the USA release's ARM9 and overlays 1 to 4 and 17, disassembled from the decomp's extract (`dqix_usa.nds`), on 28 September 2026. The functions are named here by their decomp addresses; upstream has not named them.
- **EU only:** Every trigger file was compared between the US and European releases and found byte for byte the same. That check counted 76 trigger files, against the 75 measured here; the difference is not established.

## Not established

- Operation 141.
- Operation 203.
- Operations 204 and 205 on a character's record (as opposed to an event's).
- Operation `1 : 0` on talk records. **EU only:** condition 1 is now read in general (a game-wide flag clear); its use here, beside `177`, is not.
- The other 82 talk records with a label and an event.
- The high halves not listed above.
- What sets marks other than operation 102.
- **EU only:** Action `108`, which map loading and doorways run alone.
- **EU only:** Action `128`, and the flags `138` and `226` set on a map change.
- **EU only:** Action `225`, and what reads the stop `216` stores.
- **EU only:** Condition `32` (INFERRED above as the tricks in order), and the tricks the game puts in the four places of the B Button by default.
- **EU only:** That conditions `23` and `81` are multiplayer tests (INFERRED), and that `36` tests the Hero's HP (INFERRED).
- **EU only:** Condition `86`, beyond what is read above: which kind of party member the game marks.
- **EU only:** What the contexts of kinds 10, 12, 18, 22 to 27, 29 and 30 hold. Who asks for them is read; what they are asked with is not.
- **EU only:** What sets a map region's once-only flags for an area.
- **EU only:** What `func_ov017_021a4700` measures for the talk target, and whether `0x3244` is π.
- **EU only:** Whether the game applies each chained script's record (kind 11) or only the last's.

## Earlier readings

- **Which record decides a line** was first INFERRED from 116 talk records with no condition that sit before a record of the same character, map and span: the first of the character's own records decided, and a talk record (value 5 = 1) decided only for a character with no record of their own there. Taking the first record in the file instead would have left **269** of those records dead, Patty's first-time event among them. Read so, 17 to 20 of the 20 to 22 characters placed in the village at each of 2.1 to 2.5 had something to say. The code keeps the first-holding rule, but runs the talk records after every line, own records or not.
- **`118`** was read as "a label for that character follows, as with 11". The code makes it an action that starts a talk with that label.
- **The word after an area's six floats** was read as an operation-0 word whose argument was not established. It is `143`'s own integer, the angle in degrees.
- **The four numbers after the map id** were read as a stage span by their shape only. The code confirms it.
- **Whether a character record that names an event plays it when the Hero comes near** was listed as not established. It plays when the character is talked to: kind 0 is asked for by the field's talk.
- **Operations 17 and 197** were listed as not established.

## See also

- [Story-Threads](Story-Threads)
- [Area-Cast](Area-Cast)
- [Map-List](Map-List)
- [Map-Textures](Map-Textures)
- [Event-Scripts](Event-Scripts)
- [Engine-Functions](Engine-Functions)
- [Event-Text](Event-Text)
- [Event-Lists](Event-Lists)
- [Character-Dialogue](Character-Dialogue)
- [Event-Battles](Event-Battles)
- [Attending-Characters](Attending-Characters)
- [Quests](Quests)
- [Starflight-Express](Starflight-Express)
- [Doors](Doors)
- [Tagged-Data-Table](Tagged-Data-Table)
