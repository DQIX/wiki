# Spell Table

A loose file, `/data/prm/spelltable.bin`, listing the spells in order and which vocation learns which spell at which level. It is a [tagged data table](Tagged-Data-Table). The spell-list records are confirmed against action names; the learning records' (vocation, place, level) reading is INFERRED. Observations are from the European release (game code `YDQP`).

## Layout

2,576 bytes.

| records | tag | contents |
|---|---|---|
| 1 | `0x65` | `0` |
| 1 | `0x64` | `20` |
| 65 | `0x66` | two integers: a place in the spell list, and an action |
| 108 | `0x67` | three integers: vocation, place, level — INFERRED |
| | | then the date and version the loose tables carry: `2010/04/09 00:18:34`, `100203` |

The `0x65` and `0x64` records open the file as the [level tables](Level-Tables) do.

## The spell list (`0x66`)

**A `0x66` record is a place in the spell list and the action there** (see [Actions](Actions)):

| place | action |
|---|---|
| 0 | 9, Frizz |
| 1 | Frizzle |
| 2 | Kafrizz |
| 3 | 779 |
| 26 | 30, Heal |

The list runs a family at a time, each family's last member one of actions 779 to 784. Places run 0 to 65, and 25 is missing.

## Learning records (`0x67`)

**A `0x67` record is a vocation learning a spell**, INFERRED: (vocation, place, level), with vocations numbered as the [level tables](Level-Tables) are (0 Guardian, 1 Warrior … 12 Ranger).

| value | meaning |
|---|---|
| 0 | vocation — 2, 3, 5, 6 and 8 to 12 occur; never 0, 1, 4 or 7 |
| 1 | place in the spell list |
| 2 | level learned — never passes 99 |

## Evidence

- The third value never falls within a vocation's records and never passes 99.
- The Priest, 2, learns Heal at 1, Squelch at 3 and Zing at 18; the Mage, 3, Frizz at 1 and Crack at 6; the Sage, 10, spells of both kinds.
- The Warrior, the Martial Artist and the Gladiator — 1, 4 and 7 — learn nothing, and they are the three whose magical might and magical mending are both 0 at level 1 (see [Level-Tables](Level-Tables)). The Guardian, 0, learns nothing either.
- The Minstrel, 6, learns Heal at 3, Crack at 8, Evac at 10, Woosh at 12, Crackle at 16, Midheal at 21, Zing at 24, Swoosh at 30 and Kaswoosh at 36.
- The Hero's vocation names itself three ways at number 6: `level6`, `str_tm` 2106 `Minstrel` (see [System-Strings](System-Strings)), and the spell table's 6.

## Not established

- Place 25's absence.
- The `0x65` and `0x64` records.

## See also

- [Actions](Actions)
- [Level-Tables](Level-Tables)
- [Vocation-Skill-Trees](Vocation-Skill-Trees)
- [Tagged-Data-Table](Tagged-Data-Table)
