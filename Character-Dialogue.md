# Character Dialogue (`/data/scenario/<area><letter>0.gp2`)

What characters say when spoken to is kept in talk files, one per character, grouped in [GPC2](GPC2) archives by area and story chapter. Each talk file is a [Tagged-Data-Table](Tagged-Data-Table) whose records carry three or four numbers and then a string offset. The file number is confirmed to be the character's id from the area's cast list. **EU only:** the game runs a talk file as a script, and what its records mean has been read from the game's code (see [A talk file is a script](#a-talk-file-is-a-script--read-from-the-games-code)).

All counts on this page are from the European release (game code YDQP).

## Where the files are

Each area has a set of archives, one per letter. Angel Falls has fourteen, `M01A0.gp2` to `M01Q0.gp2`. Each archive holds numbered text files in the five languages.

**The file number is a character's id** from the area's cast list (see [Area-Cast](Area-Cast)). This holds for 7,974 of the 7,994 English talk files in areas that have a cast list.

**The letters follow the story.**

- Only Angel Falls has an `A`. Other areas start later: `C01` at `B`, and `D04` at `D`.
- 22 of Angel Falls' 46 talk characters change between letters. The rest say the same thing throughout.
- Villager 2 has five versions. Read in order, they move from the prologue, through the village chapter and its aftermath, to the end of the game.
- **EU only:** the letter is the live major stage's, in the order `ABCDEFGHIJSTKLMNOPQ` from stage 1 (`func_ov017_0218d2c4`, USA overlay 17). So majors 11 and 12 are `S` and `T`, and 13 to 19 are `K` to `Q`. It is not the alphabet's order.

## Layout

A talk file is a [Tagged-Data-Table](Tagged-Data-Table). Each record has three or four numbers, then a string offset. **EU only:** there are 8,461 English talk files, and the counts below include the 41 once read as empty.

| tag | records with three numbers | records with four numbers |
|---|---|---|
| 2 | 17,739 | 347 |
| 1 | 14,357 | 1,733 |
| 4 | 2,167 | 395 |
| 5 | 1,113 | 137 |

**EU only: 41 English talk files begin with the word 16**, the table header's own size. A reader that tries every file as an LZ77 stream first will take them for empty streams; the king's file for chapter C, `C01C0.gp2/045_en.bin`, is one. See [Tagged-Data-Table](Tagged-Data-Table).

Tags 4 and 5 appear at inn and shop counters.

The text uses the same markup and prompts as event text. The English talk files hold 6,651 prompts. See [Text-Markup](Text-Markup) for the vocabulary and [Event-Text](Event-Text) for the files.

Two tags are far commoner in dialogue than in event text, and both are about
where a character is looking rather than what they say: **`<N_TURN>`** (208
uses) and **`<END_R_TURN>`** (133). Every message turns the speaker to face
the player by default, and these override that — `<N_TURN>` suppresses it
entirely. A reader of the talk files that ignores them will have characters
swivelling when the game leaves them still.

## A talk file is a script — read from the game's code

> **EU only.** Code addresses are the USA release's, from the decomp; the files were read on the European release and are not yet checked on the US one. Read on 28 September 2026.

**The talk opens `data/scenario/<area><letter>0.gp2` and the character's `<id>_<lang>.bin` in it** (overlay 17, `func_ov017_021b8e8c`), the letter being the live major stage's. **It then runs the file as a script** (`func_ov017_021ba810`, opcode table `0x021d7c58`): a record's tag is its opcode, and every record is visited in turn. A line that holds is kept, so **the last line that holds is said**. With none, nothing is said and the talk ends.

| tag | handler | holds when |
|---|---|---|
| 1 | `func_ov017_021b9d00` | numbers 0 and 1 are a range of sub-stages holding the live minor stage (`GameState` `+0x5cb4`). A first number below 0 holds always. With four numbers, the third is the time: not 0, only by night. By night, once such a line is in range, no three-number line after it holds. Then the label (below) |
| 2 | `func_ov017_021b9e30` | a quest's line: its number, then a test of its state (see below), then as tag 1 from the time on. One that holds silences every tag-1 line, and the first quest with one silences the others' unless their own states say otherwise |
| 3, 4 | `func_ov017_021ba124`, `func_ov017_021ba280` | in a game played together (`func_0202b7d8`), by whether `func_0202c1a4` holds. No tag 3 is on the cartridge |
| 5, 6 | `func_ov017_021ba3dc`, `func_ov017_021ba524` | as 1 and 2, only while `func_0202c540` does not hold and a value of the Hero's is 0 or below. That the value is their HP is **INFERRED**. One that holds silences tags 1 to 4 |

**A quest's line** (tag 2) tests the quest's two bits of state (`func_0206e120`; see [Quests](Quests)). The test value −1 holds for state 0, 0 for state 2, 2 for state 3 and 3 for state 1. 1 and 4 test the two flags kept beside the state. The trigger action `129 : q` sets a quest's state to 1. **INFERRED** from the lines: 0 is untouched, 1 open, 2 taken and 3 done. Sister Cindy's line at 0 reads "THIS IS A BUG!", at 1 she introduces herself, and at 2 her lines carry `<QUEST=109>`.

### A line's label

**A line's label holds by the one the talk asks with** (`func_ov017_021b9bcc`). Both must be in the same group of 80. Within the group, it depends on the line's place:

| place in the group | holds while |
|---|---|
| 0–15 | its count is within the character's talks since the Hero came into this area |
| 16–31 | its count is within their talks since the Hero came into this map |
| 32–63 | it is the label asked, exactly |
| 64–79 | its count is within the live step (`+0x5cb8`); the highest such is kept |

So, asked 0, a character's lines labelled 0 and 16 are their plain lines, and 17 holds once they have been talked to in this map. Asked 192, only 192 holds. A signpost's box asks 80, and its line is 96.

**The two counts** are nibbles kept per character (`func_0206ec1c`). Both go up, to at most 15, each time a line is said (`func_0206ec64`).

- A new sub-stage clears them (`func_020703c8`).
- The trigger action `106 : c` clears one character's.
- Entering a map clears the second (the map's) count.
- Entering a map the game counts as another area clears the first. This is decided by three bytes of each map's record, in a table `GameState` keeps at `+0x468` (overlay 17, `func_ov017_0219d250`). Which file that table comes from is not read.

## How a talk runs — read from the game's code

> **EU only.** Code addresses are the USA release's, from the decomp; the files were read on the European release and are not yet checked on the US one. Read on 28 September 2026.

**Whom the Hero talks to** (overlay 17, `func_ov017_021a4e88`, over 32 characters):

- anyone whose talk box (the cast's tag 6, see [Area-Cast](Area-Cast)) holds the Hero, strictly, on the ground;
- anyone within 1.5 across and 1.75 away (`0x1800` and `0x1c00` in fx32). A thing to examine (the cast's kind 1) is talked to only from a box, never so.

Of those, the one most nearly faced is chosen (by `func_ov017_021a4700`, under `0x3244`). That `0x3244` is π, if it is fx32 radians, is not established. **The talk's label is the box's**, or 0.

**Then three steps** (`func_ov017_021a4cf0`, then the talk's own machine, `func_ov017_021b8e8c`):

1. **Kind 0, the character's own [trigger](Triggers) records**, with who is talked to and the label. The first that holds runs, with every action and its queue. A `118` starts the talk with its own label, a `119` plays an event, and a record with neither runs and says nothing. With none holding, the talk starts with the label asked.
2. **The line**, from the talk file (above). With none, the talk ends and nothing more runs.
3. **Kind 1, the talk records**, once the line's window has closed, with who, the label the talk was asked with, and the prompt's answer (0 with no prompt). The first that holds runs, its queue with it: a `119`, a hand-on, a stage move, or another `118`, and the talk goes round again with the new label.

Examples:

- Ivor at the landslide: `6:7 118:7 192:0`, then `6:7 11:192 119:2350`. His own record asks 192, his line for 192 is said, and the talk record for 192 plays `ev2350`.
- Yggdrasil has no record of its own. Talked to from its box, it asks 80. Its line 96 asks "Offer the benevolessence up to Yggdrasil?", and on Yes `6:199 11:80 16:0 119:21510` plays.
- Stornway's #11 asks 192 only once mark 4 is set, which talking to #4 from its box sets.

## Evidence

| check | result |
|---|---|
| English talk files | 8,461 |
| **EU only:** tag 1's numbers 0 and 1 in order, on tags 1, 4 and 5 | **19,902 of 19,902** records |
| **EU only:** the four-number form's third number | 1 on **all 2,612** |
| **EU only:** a signpost's box label and line | asks 80, line 96: the Hexagon's inscription and Yggdrasil both |

Before the code was read, the time-of-day reading of the third number rested on the words. On tag 1, **42.5%** of four-number lines use night words (night, late, evening, sleep …), against **9.2%** of tag 1's three-number lines. The effect is weaker on tags 4 and 5: 29.8% against 12.2%, and 9.6% against 4.9%. Chapter B's own ranges run from 1 to 7, which matches the village cast's stages 2.1 to 2.7 (see [Area-Cast](Area-Cast)), and chapter B's sub-stage-1 lines speak of the Hero's fall as recent.

## Not established

- **EU only:** what `func_ov017_021a4700` measures for the talk target's angle, and whether `0x3244` is π.
- **EU only:** what `func_0202c540` is (tags 5 and 6), and whether the Hero's value they test is HP (INFERRED).
- **EU only:** which file the maps' records at `GameState` `+0x468` come from.
- **EU only:** the meaning of quest states 1 to 3 (INFERRED from the lines), and what the quest system does to states 2 and 3.

## Earlier readings

- **The record numbers were "read, not established"**, from the data alone. Numbers 0 and 1 were read as a range of sub-stages with 99 as "to the end"; the code confirms the range. The four-number form's third number was read as "the line for the night"; the code confirms it. The last number was read as a label, with 16 the plain line, 192–202 alternatives, and 80, 81 and 96 at counters; the code gives the label groups above. Tag 2's first number was read as a condition, "such as an errand or an item"; it is a quest's number.
- **The counts were lower** (19,779 records in order, 2,600 four-number lines), because 41 English files were read as empty. The four-number counts were then given as 1,728, 393, 344 and 135 against tags 2, 1, 4 and 5. Counted again by tag, tag 1 has 1,733 and tag 2 has 347.
- **The chapter letters were read in the alphabet's order.** The game's order puts `S` and `T` at majors 11 and 12.

## See also

- [Text-Markup](Text-Markup): the markup vocabulary, its compiler and its control codes
- [Event-Text](Event-Text): the `<YESNO>` / `<UKEYAME>` prompts in their own files
- [Area-Cast](Area-Cast): the cast ids, stages and talk boxes
- [Triggers](Triggers): the character and talk records
- [Quests](Quests): the quest states a tag-2 line tests
- [Tagged-Data-Table](Tagged-Data-Table)
- [GPC2](GPC2)
