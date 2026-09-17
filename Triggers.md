# Triggers

`trigger<area>.bin` says what happens in an area's maps as the story goes on: what a character says, which event plays when you talk to someone, enter a map or walk into a box, and how the story stage and flags move. There are 75 files, one per area. Each is a [tagged data table](Tagged-Data-Table) whose records all have tag 1. The record head's shape is observed. **Every reading of the words is INFERRED**, each with the measure behind it. Several operations are not decoded. Counts are from the European release (game code `YDQP`).

## Layout

5,805 tag-1 records in all, 352 of them in Angel Falls. Each record is:

1. a **map id** (the id from [Map-List](Map-List) slot 0). Angel Falls' records name the village, 1100, on 156, and its interiors 1101 to 1112 on the rest.
2. **four numbers** in the shape of the cast's stage span (see [Area-Cast](Area-Cast))
3. **one small number** (0, 1, 11, 3, 20 …), called "value 5" below
4. **words**, each an integer: its high half an operation, its low half an argument. Some records also carry floats, which are not words.

### Characters and events

| check | result |
|---|---|
| records with a high half of 6 or 118 whose low half is a character of the area | 4,067 of 5,805 |
| that character placed in the record's own map | **3,433 of 5,200 (66%)**, against 945 (18%) for another character of the same area |
| the same, in records that also carry a high half of 119 | 233 of 306 (76%), against 81 (26%) |
| Angel Falls words with a high half of 119 whose low half is an event number | **58 of 64**: 2110, 2370, 2420, 2620 and more |

So a record plausibly reads: in this map, over this span of the story, this character; and some records go on to name an event. That is **INFERRED**, and so are the readings below.

**Some words choose what a character says.**

- In records that name a character, the argument of operation 11 is one of that character's talk labels on **707 of 793**, against 221 for a control.
- Operation 36 with argument 1 goes with a word whose high half is one of the character's labels and whose low half is 0, **338 of 519** times, against none.
- Where a record names an event instead, the event's text is that character's own talk for the sub-stage. In Angel Falls, one villager's records at 2.1 to 2.5 name `ev02110`, `ev02370`, `ev02420`, `ev02570` and `ev02620`, one for each sub-stage, and each opens with her line for it (see [Event-Text](Event-Text), [Character-Dialogue](Character-Dialogue)).

**Story stage 2.1 in Erinn's house.** A record for map 1107, Erinn's house, over 2.1 alone, names her and `2130`, the event in which she greets the Hero in the morning. It names map 1110, the floor above.

### Which record decides a line — INFERRED

The first of the character's own records in the map, over a span covering the stage, that names one of these operations with its conditions holding, decides a label or an event. Without one, the character says their plain line. A talk record (value 5 = 1) decides only for a character who has no record of their own there. Otherwise it makes an event of the label that character's record chooses.

The reasoning: **116** talk records with no condition sit before a record of the same character, map and span. Taking the first record in the file would leave **269** of those records dead. Patty's is among them: her first-time event would play every time she was talked to.

Read this way, across chapter B, 17 to 20 of the 20 to 22 characters placed in the village at each of 2.1 to 2.5 have something to say. The rest have only paired labels, and nothing found chooses between them.

## The operations — INFERRED

A word's high half is an operation and its low half an argument. Every reading below is **INFERRED**, with its measure. Measured across all 75 files (5,761 records read).

| operation | reading | measure |
|---|---|---|
| value 5 = 11 | the record belongs to an event: what follows it | 646 records, **every one** naming its event with operation 8 |
| 8 : event | the event the record is about | as above |
| 132, then three words of operation 0 | the story moves to stage *a.b*, step *c*, the three arguments | 170 records. **166** go to the record's own stage (81), the next minor stage (74) or the next major (11). Under one stage the steps run without a gap in **96 of 99** |
| 104 : n | sets flag *n* | — |
| 4 : n | holds only if flag *n* is set | **518 of 664** 4s and 5s have a 104 of the same *n* in the same area and stage |
| 5 : n | holds only if flag *n* is not set | as above |
| 133 : map, then *event* : 0 | goes on to that map (by id) and plays that event | **16 of 29** name an event whose own record is in that map |
| 118 : character | a label for that character follows, as with 11 | seen in character records beside their talk labels |
| value 5 = 1, with 6 : character, 11 : label and 119 : event | talking to the character, when their chosen label is that one, plays that event instead | of the 179 talk records with a label and an event, **97** have the same character's own record choosing that label in the same map and span, first in the file on all 97. Example: Ivor's at the landslide, `6:7 118:7 192:0` then `6:7 11:192 119:2350`. The other 82 are not established |
| value 5 = 3, with 9 : map and 119 : event | entering that map plays that event | 244 of the 249 open with 9, naming their own map every time. 49 play an event, 24 only while a flag holds. Example: the pass at 2.2, `9:5101 5:2 203:1 119:2300`, "Finally! We're here at last." |
| 104 : n on an entry record | sets flag *n* as its event plays | of the 49 entry records that play an event, **7** set a flag themselves, and **every one** holds only while that flag is unset, so it plays once. Only one of their events has a record of its own, and it does not set the flag. The village's at 2.1 plays the Guardian statue scene, `ev22590`, and sets flag 0 |
| 86 : 0 | holds when the Hero has no companion with them | all 7 in Angel Falls have argument 0, and each sits before a character's first-time event, giving the label that follows instead. Ivor speaks in every one of those events (2222, 2230, 2240, 2250, 2430, 2440, 2450). An earlier guess, day or night, fails: only 2 of 13 across the cartridge have a twin record |
| 102, 2, 3 | a second set of flags, "marks": 102 sets one, 2 holds if it is set, 3 if it is not | of the 57 sets, **31** sit in a record that also tests 3 of the same mark (the first time a character is talked to), and 24 of those have a partner record for the same character, map and span testing 2 of it. Example: Hugo's `3:7 119:2430 102:7`, then `2:7 118:8 193:0`. Tests (280 and 298) far outnumber sets, so something else sets marks too. An earlier measure, 145 of 566, counted every test against any set |
| 35 : n | holds only at step *n* of the stage | of the 128 records testing it, **94** name a step that some event in the same file moves the story to at that stage, against **20** for the step three on. The Hexagon's switch, `201`: nothing at steps 1 to 3, `ev02530` at 4 ("There's a noise of something moving somewhere!"), its after-line at 5 |
| 120 : n | starts set battle *n* (see [Event-Battles](Event-Battles)) | all **40** arguments are indices there. **65 of the 66** records carrying one have a value 5 = 15 record in the same map naming the same *n* |
| 205 : n on an event's own record | brings the attending character at place *n* (from 0) of `attnpc` into the party (see [Attending-Characters](Attending-Characters)) | the three events whose own text says who joins carry that character's place: `ev02210`, "Ivor joins the party", `205:1`; `ev04080`, Dr Phlegming, `205:2`; `ev28991`, Sterling, `205:3`. 6 event records carry it, all with 1 to 3. On a character's record (31 of them) not read |
| 204 : 1 on an event's own record | sends whoever goes along with the Hero away | all **6** event records carrying it have 1, in Ivor's stretch, Dr Phlegming's and Sterling's alike, so the 1 does not name who. Ivor's two, `ev22591` and `ev02400`, are where a let's play video shows him leave (on ahead to the landslide; home with his father), and he joins again at the landslide, `ev02350`, `205:1`. On a character's record (35 of them) not read. `203`, on two entry records (the pass's `203:1`, the mayor's `203:0`) and 71 characters' records, is not read either |
| 16 : n on a talk record with a label and an event | the event plays once the label's line is read, and only on the prompt's answer *n*, from 0 (0 is Yes) | in Angel Falls, the pass and the Hexagon, 7 of the 9 such records carrying it have a line that asks a question (one more is the inn's welcome, one has no line found), against 3 of the 17 without it. The Hexagon's switch, `6:201 11:194 16:0 119:2530`, asks "Press the button?". In a let's play video, answering No, the Hero decides not to, and nothing moves. A talk record's event is played after its label's line, not instead of it: the video reads the inscription, "Path ahead sealed…", before `ev02500` |
| value 5 = 15, opening with 12 : n | once set battle *n* is won: plays the event, sets the flags | 46 of the 47 open with 12. The Hexagon's `12:2 119:2550` plays Patty's thanks |
| value 5 = 16, opening with 12 : n | once set battle *n* is lost | all 33 open with 12. INFERRED as the other outcome: the Hexagon's `12:2 104:4 197:10` sets the flag under which Patty offers the fight again |
| value 5 = 20, with 143 : n and six floats | defines area *n*: a box, its greater corner then its lesser, x y z, in the units placements use. A word of operation 0 follows; its argument is not established | all **108** area words have six floats, and the first three are at or above the last three on every axis on **108 of 108**. The boxes sampled lie inside their maps |
| value 5 = 2, with 7 : n | walking into area *n* plays the record's event | **102 of the 110** name an area defined in their map. The mayor's house at 2.1, `7:15 5:1 119:2120`, plays his scene with Ivor, whose record sets flag 1 |
| 133 on a talk record, with 177 : n | once the line is read, goes on to that map and event, if the prompt's answer was *n*, from 0 | thin: two records carry 177 beside a 133. Erinn's at 2.1, `6:98 11:193 16:0 177:0 1:0 133:1110 2130:0`, goes on to the morning. Her line's first answer, Yes, is dinner, and in a let's play video answering it, the Hero wakes to the morning. `1 : 0` is not read |
| 17 : n | not established | never paired with anything that sets or tests it |

**Flags belong to the stage — INFERRED.** They are cleared when the story moves on to another stage. The tests find their setter in the same stage.

## Worked example: the opening

The morning's record, in map 1110: `8:2130 132:0 0:2 0:2 0:1 197:6`. After it the story is at 2.2, step 1.

At 2.2, a character record in 1107, Erinn's house, names Ivor and his event: `6:7 119:2200`. The cast places him there at 2.2 and not at 2.1.

His event's record is `8:2200 133:1100 2210:0`: on to the village, 1100, and `ev02210`, his call on her doorstep. That event's own record is `8:2210 104:0 132:0 0:2 0:2 0:2 197:7 205:1 141:1`: flag 0 set, story to 2.2 step 2, and Ivor into the party.

A villager's record then holds only with flag 0 set and flag 1 not: `6:8 4:0 5:1 119:2220`.

## Evidence

- The counts in the tables above are across all 75 files (5,805 records; 5,761 read for the operation measures).
- Event numbers are checked against `ev#####` event files (see [Event-Text](Event-Text), [Event-Scripts](Event-Scripts)).
- Story-order and prompt readings are checked against a let's play video.

## Not established

- Whether a character record that names an event plays it when the Hero comes near, or only when talked to.
- Operations 141 and 197.
- Operation 17.
- Operation 203.
- Operations 204 and 205 on a character's record (as opposed to an event's).
- Operation `1 : 0` on talk records.
- The argument of the operation-0 word after an area definition.
- The other 82 talk records with a label and an event.
- The high halves not listed above.
- What sets marks other than operation 102.
- The four numbers after the map id: they are read as a stage span by their shape only.

## See also

- [Area-Cast](Area-Cast)
- [Map-List](Map-List)
- [Event-Scripts](Event-Scripts)
- [Event-Text](Event-Text)
- [Character-Dialogue](Character-Dialogue)
- [Event-Battles](Event-Battles)
- [Attending-Characters](Attending-Characters)
- [Doors](Doors)
- [Tagged-Data-Table](Tagged-Data-Table)
