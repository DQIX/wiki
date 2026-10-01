# Level Tables

Thirteen loose files, `/data/prm/level0.bin` to `level12.bin`, one per vocation, giving experience and base stats for levels 1 to 99. Each is a [tagged data table](Tagged-Data-Table). The record structure is confirmed, and so is what every column but the first holds: a published strategy guide's own tables agree with the files, which settled both the stat columns and column 10. That column 0 is experience is INFERRED. Observations are from the European release (game code `YDQP`).

## Layout

Each file is 5,312 bytes: a tagged data table of 102 records.

| records | tag | contents |
|---|---|---|
| 1 | `0x65` | `0` |
| 1 | `0x64` | `20` |
| 99 | `0x66` | a level: eleven integers |
| 1 | `0x67` | 22 integers: seventeen `100`s, then `10 2 2 0 0` on eleven files; `level2` and `level10` carry some `75`s and `50`s among the hundreds |

The `0x64`, `0x65` and `0x67` records' meaning is not established.

### A level record (`0x66`)

The 99 records are levels 1 to 99.

| column | meaning |
|---|---|
| 0 | experience the level is reached at, INFERRED — 0 on the first record of every file and rising on every record after, to 4.3 million on `level1` and 6.9 million on `level0` |
| 1 | strength |
| 2 | resilience |
| 3 | agility |
| 4 | deftness |
| 5 | charm |
| 6 | magical might |
| 7 | magical mending |
| 8 | maximum HP |
| 9 | maximum MP |
| 10 | **the skill points gained by that level, all told** — 0 at level 1, 12 at level 10 and 200 at 99 on twelve files; 17 and 350 on `level0` |

Columns 1 to 9 were first INFERRED and are confirmed by a published guide — see Evidence.

## Files and vocations

The files are the thirteen vocations in the order the status screen's strings name them. `level6` is confirmed as the Minstrel's by a published guide; the rest are INFERRED from the order of the names.

| file | vocation |
|---|---|
| `level0` | Guardian |
| `level1` | Warrior |
| `level2` | Priest |
| `level3` | Mage |
| `level4` | Martial Artist |
| `level5` | Thief |
| `level6` | Minstrel |
| `level7` | Gladiator |
| `level8` | Armamentalist |
| `level9` | Paladin |
| `level10` | Sage |
| `level11` | Luminary |
| `level12` | Ranger |

This numbering (Guardian 0, then Warrior 1 to Ranger 12) is the vocation order used by the [spell table](Spell-Table), the [vocation skill trees](Vocation-Skill-Trees) and the items' "Used by" bits (see [Items](Items)).

## Evidence

**Ten columns, ten words.** The status screen's strings, `/data/bin/menu/str_sta.gp2/str_sta_en.bin` (see [System-Strings](System-Strings)), run `Lv` · `Exp.` · `Strength` · `Agility` · `Resilience` · `Deftness` · `Charm` · `Magical Mending` · `Magical Might` · `Max. HP` · `Max. MP` · `Attack` · `Defence`. Past `Lv`, that is experience and nine numbers — the table's first ten columns — with attack and defence, which come from equipment, after. Column 10 is none of them.

**Which is which, by vocation.** The same strings name thirteen vocations — `Guardian`, `Warrior`, `Priest`, `Mage`, `Martial Artist`, `Thief`, `Minstrel`, `Gladiator`, `Armamentalist`, `Paladin`, `Sage`, `Luminary`, `Ranger` — and there are thirteen files. Taken in that order, level 1 of each (columns 1 to 9):

| file | vocation | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|---|
| `level0` | Guardian | 10 | 9 | 8 | 8 | 9 | 8 | 8 | 30 | 10 |
| `level1` | Warrior | 18 | 18 | 4 | 5 | 4 | 0 | 0 | 26 | 4 |
| `level2` | Priest | 9 | 9 | 14 | 9 | 7 | 0 | 18 | 19 | 14 |
| `level3` | Mage | 4 | 7 | 18 | 14 | 7 | 18 | 0 | 18 | 16 |
| `level4` | Martial Artist | 18 | 11 | 23 | 11 | 5 | 0 | 0 | 24 | 2 |
| `level5` | Thief | 13 | 11 | 18 | 18 | 3 | 0 | 4 | 23 | 6 |
| `level6` | Minstrel | 9 | 8 | 8 | 12 | 9 | 6 | 7 | 20 | 6 |
| `level7` | Gladiator | 30 | 19 | 7 | 15 | 5 | 0 | 0 | 32 | 2 |
| `level8` | Armamentalist | 21 | 15 | 10 | 7 | 11 | 17 | 0 | 32 | 14 |
| `level9` | Paladin | 21 | 22 | 4 | 1 | 7 | 0 | 10 | 36 | 11 |
| `level10` | Sage | 12 | 12 | 13 | 3 | 14 | 14 | 12 | 29 | 30 |
| `level11` | Luminary | 9 | 12 | 22 | 16 | 18 | 5 | 19 | 31 | 13 |
| `level12` | Ranger | 18 | 14 | 16 | 30 | 4 | 0 | 12 | 31 | 14 |

- **Columns 6 and 7** are the pair only some vocations have: both 0 on the Warrior, the Martial Artist and the Gladiator; the Mage and the Armamentalist have only 6, the Priest, the Paladin and the Ranger only 7. So 6 is taken for magical might — attack spells — and 7 for magical mending, the reverse of the screen's order.
- **Column 8** is the largest on every file at level 1 and 390 to 600 at 99: maximum HP.
- **Column 9**, highest on the Mage and the Sage: maximum MP.
- **Column 5**, highest on the Luminary: charm.
- **Columns 2 and 3** are also taken in the reverse of the screen's order — 2 resilience, 3 agility — because the Paladin (22 against 4) and the Gladiator (19 against 7) are high in 2 and low in 3, and the Martial Artist (11 against 23) and the Thief (11 against 18) the other way about.
- **Column 4**, highest on the Ranger and the Thief: deftness.

The [spell table](Spell-Table) agrees: the Warrior, the Martial Artist and the Gladiator, whose columns 6 and 7 are both 0, learn no spells.

### Confirmed by a guide

- **Confirmed by a guide, 22 September 2026.** The *Dragon Quest IX* Signature Series guide prints an attribute table for each vocation, at levels 1, 5, 15, 25, 40, 60, 80 and 99. Its Minstrel table agrees with `level6` at **all 72** of those values; no other file agrees at more than 2. That settles columns 1 to 9 — including the two taken against the status screen's order, 2 resilience and 3 agility, and 6 might against 7 mending — and that `level6` is the Minstrel's.
- **Column 10 is skill points.** The same guide's table of the points gained at each vocation level, summed, is column 10 at every level from 1 to 99 on all twelve vocations' files, 200 at 99. The cartridge bears it out: `str_bres` 13, among the battle's result messages, is "`<val_1>` skill point(s) earned". `level0`, the Guardian's, does not fit — it hands points out a level earlier than the guide's walkthrough sees them, which is one more reason to think it is not a playable vocation's.
- **EU only:** the guide's skill-point table gives 3 points at vocation levels 5, 6, 8, 9 and on, rising to 6 a level in the thirties, then 2 a level on two levels of every three from 50. Its walkthrough has the Hero first gaining skill points at level 5 (page 59). `level0` has them from level 4 and agrees with the table at 3 of the 99 levels; against the Minstrel's attribute table it agrees at 2 of the 72 values.
- **EU only:** the guide has an attribute table for every vocation. Only the Minstrel's has been checked against the files.

## How the game keeps a level

> **EU only.** Code addresses are the USA release's, from the decomp; the files were read on the European release and are not yet checked on the US one.

**Level and experience are kept per vocation.** A character's record (`0x23C` bytes; see [Party](Party)) holds thirteen level bytes at `+0x02` to `+0x0E` and thirteen experience words at `+0x1C` to `+0x4F`, one of each per vocation, with the current vocation at `+0x50` choosing among them. The initialiser's thirteen-step loop at `0x02086450` sets every vocation's experience to 0 and level to 1 together, and `GetExperience` (overlay 23, `0x021eea98`) reads the current vocation's word. So changing vocation changes an index: what the old vocation had waits until the character changes back.

**The numbering is borne out by the Abbey.** Its list offers vocations 1 to 6, Warrior to Minstrel — the six a game begins with — with no condition, and 7 to 12 each behind an event flag, `0x113F` plus the vocation's number. It refuses 0, the Guardian, which the game writes when it creates the Hero. That the ungated six are the starting vocations and the gated six the advanced ones is a check on the files' order that does not rest on the status screen.

## Not established

- Column 0: that it is experience is INFERRED; the guide does not print it.
- The `0x64`, `0x65` and `0x67` records.
- **EU only:** that the files other than `level6` are the vocations the order of the names gives them.

## See also

- [Tagged-Data-Table](Tagged-Data-Table)
- [Spell-Table](Spell-Table)
- [Vocation-Skill-Trees](Vocation-Skill-Trees)
- [Attending-Characters](Attending-Characters) — stats in the same column order
- [Party](Party) — the character record, and changing vocation
- [Battle-Text](Battle-Text) — `str_bres` 13, skill points earned
- [System-Strings](System-Strings)
