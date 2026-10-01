# Event Battles

`/data/event/eventbattle.bin`, 4,336 bytes, lists the set battles the story starts — bosses, and a few others. Each record names up to three monsters. The header, the record size, the index and the monster slots are read; that a slot's second word is a count is INFERRED. **EU only:** the last two words are INFERRED to be the battle's track and the stage it is fought on.

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
| `+0x24` | `u32` | **EU only:** **the track**, INFERRED — below |
| `+0x28` | `u32` | **EU only:** **the stage**, a map id, or 0 for the one the ground names — INFERRED; below |

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

## The track and the stage

> **EU only.** The values were read on the European release (`YDQP`) and are not yet checked on the US release (`YDQE`). Code addresses are the USA release's, from the decomp.

**`+0x24` is the track**, INFERRED: it runs 23 to 38 — 23 is the ordinary battles' track and 24 the bosses', on 46 records — and on 75 of the 82 records with a stage it is that stage's own track in the [map list](Map-List).

**`+0x28` is the stage**, INFERRED: a map id, or 0 on a record that leaves the battle to the stage the ground names, as an [encounter](Encounters) does. A battle is fought on a map of its own, a stage; see [Battle stages](Battle-Stages). Overlay 0, switching to the stage, takes the battle request's `+0x20` over its `+0x02` when `+0x20` is not 0 and the request's `+0x0C` is not negative (`0x021668c8`–`0x021668dc`). That a set battle's stage is what fills `+0x20` is not read.

## In the battle

> **USA only.** Read from the USA release's code, through the decomp; not compared with the European release's code.

A battle's setup carries a number at `+0x0C` that is −1 for an ordinary battle — INFERRED: a set battle's number. Where it is not −1, **the party cannot flee**, and **the monsters come with the HP their [monster data](Monsters) gives** rather than a drawn fraction of it. A set battle also carries its own value for how the fight opens, a byte in its data, where an encounter decides it as the two sides meet. Which byte is not established. See [Battle resolution](Battle-Resolution).

The story learns the outcome through its [triggers](Triggers): the end of a set battle asks for a record of kind 15 when it is won and 16 when it is lost (overlay 17, `0x021b7c54` and `0x021b7c3c`), which name the battle with `12 : n` — 46 of the 47 won records open so, and all 33 lost ones.

Script function 547, the scripted battle's transition, takes a record index into this file and reads the transition's music from it. See [Engine functions](Engine-Functions).

## Not established

- **EU only:** that `+0x24` is the track and `+0x28` the stage are INFERRED; what fills the battle request's `+0x20` is not read.
- **EU only:** the music script function 547 reads is given as the record's `+0x0E`, which in the layout above falls inside the first slot's monster word. How it relates to `+0x24` is not established.
- **USA only:** which byte of a set battle's data holds how its fight opens.

## Earlier readings

- **EU only:** `+0x24` and `+0x28` were carried as not established — 23 to 38, and 0 to 30,903.

## See also

- [Triggers](Triggers) — the battle word 120
- [Monsters](Monsters) — monster numbers
- [Encounters](Encounters)
- [Battle-Stages](Battle-Stages) — the stage at `+0x28`
- [Battle-Resolution](Battle-Resolution) — fleeing, HP and the opening in a set battle
- [Engine-Functions](Engine-Functions) — function 547
