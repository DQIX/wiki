# Character Dialogue (`/data/scenario/<area><letter>0.gp2`)

What characters say when spoken to is kept in talk files, one per character, grouped in [GPC2](GPC2) archives by area and story chapter. Each talk file is a [Tagged-Data-Table](Tagged-Data-Table) whose records carry three or four numbers and then a string offset. The file number is confirmed to be the character's id from the area's cast list. What the record numbers mean is read, not established. The readings below are consistent with the data, but not confirmed.

All counts on this page are from the European release (game code YDQP).

## Where the files are

Each area has a set of archives, one per letter. Angel Falls has fourteen, `M01A0.gp2` to `M01Q0.gp2`. Each archive holds numbered text files in the five languages.

**The file number is a character's id** from the area's cast list (see [Area-Cast](Area-Cast)). This holds for 7,974 of the 7,994 English talk files in areas that have a cast list.

**The letters follow the story.**

- Only Angel Falls has an `A`. Other areas start later: `C01` at `B`, and `D04` at `D`.
- 22 of Angel Falls' 46 talk characters change between letters. The rest say the same thing throughout.
- Villager 2 has five versions. Read in order, they move from the prologue, through the village chapter and its aftermath, to the end of the game.

## Layout

A talk file is a [Tagged-Data-Table](Tagged-Data-Table). Each record has three or four numbers, then a string offset.

| tag | records with three numbers | records with four numbers |
|---|---|---|
| 2 | 17,241 | 1,728 |
| 1 | 14,273 | 393 |
| 4 | 2,149 | 344 |
| 5 | 1,101 | 135 |

What the numbers mean is read, not established:

| number | reading | evidence |
|---|---|---|
| numbers 0 and 1, on tags 1, 4 and 5 | a range of sub-stages within the letter's chapter, with 99 meaning "to the end" | on **all** 19,779 records, the first number is at or below the second, or the second is 99 |
| the extra third number in the four-number form | always 1: the line for the night | all 2,600 of 2,600 are 1. On tag 1, **42.5%** of these lines use night words (night, late, evening, sleep …), against **9.2%** of tag 1's three-number lines. The effect is weaker on the counters' tags: 29.8% against 12.2% on tag 4, and 9.6% against 4.9% on tag 5 |
| the last number | a label: 16 is the plain line, 192–202 are alternatives, and 80, 81 and 96 appear at counters | [Triggers](Triggers) name these as labels |
| tag 2's first number | a condition, not a range, such as an errand or an item | values like 174–198. None of the 2,657 small-valued ones form a range |

Tags 4 and 5 appear at inn and shop counters.

Chapter B's own ranges run from 1 to 7. This matches the village cast's stages 2.1 to 2.7 (see [Area-Cast](Area-Cast)). Chapter B's sub-stage-1 lines speak of the Hero's fall as recent.

The text uses the same markup and prompts as event text. The English talk files hold 6,651 prompts. See [Text-Markup](Text-Markup) for the vocabulary and [Event-Text](Event-Text) for the files.

Two tags are far commoner in dialogue than in event text, and both are about
where a character is looking rather than what they say: **`<N_TURN>`** (208
uses) and **`<END_R_TURN>`** (133). Every message turns the speaker to face
the player by default, and these override that — `<N_TURN>` suppresses it
entirely. A reader of the talk files that ignores them will have characters
swivelling when the game leaves them still.

## Not established

- The meaning of every record number. All the readings above are consistent with the data but not confirmed.

## See also

- [Text-Markup](Text-Markup): the markup vocabulary, its compiler and its control codes
- [Event-Text](Event-Text): the `<YESNO>` / `<UKEYAME>` prompts in their own files
- [Area-Cast](Area-Cast): the cast ids and stages
- [Triggers](Triggers)
- [Tagged-Data-Table](Tagged-Data-Table)
- [GPC2](GPC2)
