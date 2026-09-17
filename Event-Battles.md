# Event Battles

`/data/event/eventbattle.bin`, 4,336 bytes, lists the set battles the story starts — bosses, and a few others. Each record names up to three monsters. The header, the record size, the index and the monster slots are read; that a slot's second word is a count is INFERRED; the last two words of each record are not established.

All observations were made on the European release (game code `YDQP`).

## Layout

| offset | type | meaning |
|---|---|---|
| `+0x00` | `u32` | the record count, 98 |
| `+0x04` | `u32` | the file's size |
| `+0x08` | 8 bytes | zero |
| `+0x10` | 44 bytes each | the records |

### Record

| record offset | type | meaning |
|---|---|---|
| `+0x00` | `u32[2]` | `0x55090064 0xFFFF0155`, on every record |
| `+0x08` | `u32` | its index: what a trigger's battle word, 120, names |
| `+0x0C` | `(u32, u32)` ×3 | a monster, by its number in the monster data, and how many (INFERRED); `0xFFFFFFFF` for an empty slot |
| `+0x24` | `u32` | not established: 23 to 38, 24 on 46 of them |
| `+0x28` | `u32` | not established: 0 to 30,903 |

## Evidence

| check | result |
|---|---|
| indices | 98, every one different, 0 to 143 — not the records' order |
| slots filled | one on 91, three on 7 |
| monsters | all 112 in the monster data |
| counts | 1 on 106, 2 on 2, 3 on 2, 5 and 8 once |
| trigger battle words | all **40** arguments on the cartridge are indices here |

Index 2 is **Hexagoon alone** — monster 300, `b003a`. The Hexagon's last room, 7105, has the trigger `8:22510 120:2`, which Patty's talk plays once she has asked to be freed. Index 0 is the Wight Knight, 1 Morag, 3 the Ragin' Contagion.

That a slot's second word is a count is INFERRED: it sits beside every monster, and is 1 on all but six.

## Not established

- `+0x24`: 23 to 38, 24 on 46 records.
- `+0x28`: 0 to 30,903.

## See also

- [Triggers](Triggers) — the battle word 120
- [Monsters](Monsters) — monster numbers
- [Encounters](Encounters)
