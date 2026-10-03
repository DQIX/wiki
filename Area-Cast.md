# Area-Cast

`<area>.npc` is a NARC beside the map data in `/data/scenario`. It says who stands in an area, where, and in which of its maps. It holds two files: `<map>npc.bin` names the cast, and `<map>place.bin` places them. There are 74 archives, with 1,385 names and 1,285 placements between them. The cast records, the placement block header, the map id and the positions are confirmed. **EU only:** how the game runs `place.bin`, the story span and the time of day included, has been read from the game's code (see [How the game runs `place.bin`](#how-the-game-runs-placebin--read-from-the-games-code)). Several words are not established. Counts are from the European release (game code `YDQP`).

## Layout

### The cast — `<map>npc.bin`

An ordinary [tagged data table](Tagged-Data-Table). Its `0x03` records are the characters, five values each.

| slot | meaning |
|---|---|
| 0 | `0xFFFFFF01` on every character record on the cartridge |
| 1 | the character's id, which is what a placement refers to |
| 2 | what it is drawn as (see below) |
| 3 | `0xFFFFFFFF`, unset |
| 4 | byte offset into the string table, or `0xFFFFFFFF` for no name |

**Slot 2 says whether a character is a model or a sprite.** Across the 33 distinct names in Angel Falls, the split is exact, and this value decides it:

| value | count | what it is |
|---|---|---|
| `0` | 901 | a 2D sprite: `/data/ani/<name>.spr` exists, and no 3D model of that name exists anywhere |
| `1` | 317 | carried only by records with no name. **EU only:** the game's talk code treats kind 1 as a thing to examine, which the Hero can talk to only from its talk box (see [Character-Dialogue](Character-Dialogue), how a talk runs) |
| `2` | 132 | a 3D model: `/data/chara_sub/<name>.chr` exists, and no `.spr` does |
| `5` | 35 | not established. The village's one example, `z015d`, has neither |

In the village, every value-0 character has a sprite and no model, and every value-2 character has a model and no sprite: 24 and 8 of the 33.

### The placements — `<map>place.bin`

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`). The code it cites is the USA release's, from the decomp.

**It is a tagged data table, and the game runs it as a script** (see [How the game runs `place.bin`](#how-the-game-runs-placebin--read-from-the-games-code)). It was first read as a stream of **variable-length** blocks found by a two-word signature, with gaps of 76 to 924 bytes between them. That reading misses **89 of 1,378** blocks and **40 of 2,017** spans: 72 blocks with no place at all, and records whose coordinates are written as integers. The tables below describe the two record shapes the signatures do find: the block is what the game's code reads as tag 3, and each sub-record a tag-5 span.

Block header:

| offset | type | meaning |
|---|---|---|
| `+0x00` | `u32` | `0xA5060003` |
| `+0x04` | `u32` | `0xFFFFFF0A` |
| `+0x08` | `u32` | the map's own id (see below). `0x44C` (1100) on only 1 of the 74 archives |
| `+0x0C` | `u32` | the id of the character this places |
| `+0x10` | `f32` | x, in the units map placements use |
| `+0x14` | `f32` | y, likewise |
| `+0x18` | `f32` | z, likewise |
| `+0x1C` | `f32` | facing, in radians |

After the header come sub-records. Each is one character in one map over a span of the story. Two forms are known, each found by its own marker:

| offset | type | meaning |
|---|---|---|
| `+0x00` | `u32[2]` | `0x550D0005 0xFF02A955`: 60 bytes. `0x55090005 0xFFFF0155`: 44 bytes, without a position |
| `+0x08` | `u32[7]` | a span of the story: words 0, 1 and 2 are its first stage, sub-stage and step, words 3, 4 and 5 its last. Word 6 is the time of day (see below) |
| `+0x24` | `u32` | the map, by its own id |
| `+0x28` | `u32` | the character's id |
| `+0x2C` | `f32[4]` | x, y, z and facing (60-byte form only) |

| check, across the cartridge | result |
|---|---|
| sub-records | 1,977, in 1,289 blocks, by the signatures |
| blocks and spans read as a tagged table | 1,378 blocks and 2,017 spans |
| map in the block's own area | 1,976 |
| id the block's own | 1,876, so a record names its own character |
| header repeats the first positioned record | 485 of the 636 blocks that have one |
| words 3-4, read as a pair, at or after words 0-1 | **1,977 of 1,977** |
| word 6 | 2 on 1,227, 1 on 378, 0 on 371, one other |
| bytes between blocks that are neither form | 91,652, not read |

## How the game runs `place.bin` — read from the game's code

> **EU only.** Code addresses are the USA release's, from the decomp; the files were read on the European release and are not yet checked on the US one. Read on 28 September 2026.

The field's cast loader, `func_ov017_021a2c14` in overlay 17, opens `data/scenario/<area>.npc`. It runs each `npc.bin` through `0x02064e2c`, and **runs each `place.bin` as a script**: `func_0206da80` sets a context of the story's step, sub-stage and stage, the map's id and an output (at `0x02108cec`), and runs the file with the opcode table at `0x020f0994`, tags 3 to 22. A record's tag is its opcode. Each record places a character or takes them away, **in the file's order**.

| tag | handler | values | what it does |
|---|---|---|---|
| 3, a block | `func_0206c010` | map, character, then where (x, y, z, facing, and a byte on some) | for this map only: places them. With no place, takes them away |
| 5, a span | `func_0206c2c0` | from and to (stage, sub-stage and step each), then **the time of day**, map, character, then where | counts only while `from ≤ now ≤ to`, each weighed `major × 1000 + minor × 10 + step`, and only at its time. Then: **for another map, it takes the character away from this one**. With no place, it takes them away. Otherwise it places them |
| 17, while flags | `func_0206d4e0` | pairs of a condition and whether it must be set (1) or clear (0), then time, map, character, where | a condition whose high half is 1 is a game-wide flag by its bit; 2 is one by its number, displaced from `0x400` as the script function `603` displaces (`func_0206eb98`). Any other high half and the record does not count. Otherwise as a span, and **before all others** |
| 4, at one point | `func_0206c0f8` | stage, sub-stage and step, then time, map, character, where | counts only when all three are now's, and at its time. Another map takes the character away, as a span's does. Otherwise it places them, ordered as a span that ends at a sub-stage 0 |
| 6, a talk box | `func_0206c4e8` | character, four floats, a label | a box on the ground (see below) |

**Word 6 of a span is the time of day**: 0 by day (morning, day or evening), 1 by night, 2 either. The test is `GameState::IsMorningDayOrEvening`. On the cartridge, 1,227 spans are for either, 378 by night and 371 by day. Angel Falls' `15` is in the stable by day and in the village by night. Erinn is upstairs at 2.6 only by night.

**Tag 17** places a character while game-wide flags hold. Its flags are the same bank the event scripts' `603` reads. Drak, at 11.2, stands while game-wide flag 322 is set; a Clap in area 10 sets it (see [Triggers](Triggers)).

**Tag 4** places a character at one point of the story only. Coffinwell's `26` is placed only so: in the scholar's house (1311) at 4.1 steps 1 and 2, and outdoors at step 3.

### The order a character's placements keep

`func_0206db48` adds each placement to its character's ordered chain, and the head of the chain stands. There are six classes, in this order:

1. tag 17's (bit `0x04` of `+0xa`);
2. one with another bit, `0x40` (perhaps tag 14's; not read);
3. one whose `+0x46` is set (not read);
4. a span whose to-stage has a sub-stage of 0 but whose from-stage does not, and a tag-4 point;
5. any other span;
6. a block.

Between placements of class 4 (and class 1), **the one that starts earliest** goes first, and then the first in the file. Otherwise the first in the file goes first. One that comes after all the others is dropped. Taking a character away (`func_0206dd68`) clears where they stand, and a later record can place them again.

### Talk boxes — tag 6

A tag-6 record is a box on the ground: its four floats are x and z at most, then x and z at least, in a placement's units (×4096 in the code). Its label is the one a talk from inside the box asks with. The box is kept on the character's first placement in this map at the time (`+0x40`, in nodes of `0x18` bytes). So a box read before the character is placed, or after they are taken away, is none.

**The Hero talks to whoever's box holds them**, and to a thing to examine only so (see [Character-Dialogue](Character-Dialogue)). There are 570 boxes on the cartridge. Yggdrasil's is `199, 3.24, 1.27, −3.36, −2.52, 80`, and the village shopkeeper's three are over his counter. Trigger condition `41` tests whether the Hero stands in one of a character's boxes (see [Triggers](Triggers)).

**A box can belong to a character with no name.** At the Quester's Rest the keepers are talked to across their counters through such stand-ins: kind 0, no name, a box of label 80 on the near side — Erinn's counter is 208, the bank 212 (see [The Quester's Rest](Questers-Rest)). A reader that drops unnamed entries loses both.

### Not read

- **Tag 14**, which places a character by a quest's state (`func_0206cbcc`, using `func_0206e120`; see [Quests](Quests)).
- **Tag 7** (`func_0206c614`), which keeps four floats on the placement (`+0x24` to `+0x30`) and sets a mode byte at `+0x1f` to 7. A wander box, perhaps.
- **Tags 8, 11, 15 and 18 to 22**, which name a character and carry what looks like a path, a facing, flags and a model with its motion.

A character placed only by these stands nowhere, as far as the rules read go.

## The story span

> **EU only.** Read on the European release (`YDQP`); not yet checked on the US release (`YDQE`). The span test is the USA release's code, from the decomp.

The seven words are a **span of the story**, now read from the game's code: a span counts while `from ≤ now ≤ to`, each side weighed `major × 1000 + minor × 10 + step`. Words 2 and 5 are **steps** within the first and last stage: the steps the trigger records move the story to (see [Triggers](Triggers)). Word 6 is the time of day.

The data agree with the code:

- The two pairs never run backwards: words 3-4 are at or after words 0-1 on 1,977 of 1,977.
- Within one sub-stage, word 2 is at or before word 5 on **362 of 362**.
- Where a character's next record begins in the sub-stage the last one ends in, it begins one step on (word 2 is one more than the last record's word 5) **121 times of 179**, against 17 for two steps on.
- On the Hexagon's first floor, character `202`'s first record ends at 2.4 step 4. Its next record, 3.47 units along, begins at step 5, the step the switch's event moves the story to (see [Doors](Doors), sliding pieces).

## Who stands where

> **EU only.** Code addresses are the USA release's, from the decomp; the files were read on the European release and are not yet checked on the US one.

This follows from the rules above. It replaces a set of rules once INFERRED from the trigger records (see [Earlier readings](#earlier-readings)).

- **A record for another map is what takes a character away from this one.** A reader that looks only at this map's records cannot see it. Ivor is not in the village at 2.1 because his record for the mayor's house at 2.1 takes him out of it.
- **A character whose records do not cover now is left at their block's place.** That is why the king, `45`, stands in the throne room at 3.1.
- **A span without a position takes the character away.**
- **By day and by night**, a different span can hold, so the same character can stand in two places in one sub-stage.

## Positions and maps

**Positions are in the units map placements use.** Taken as world units directly, only 23 of the village's 49 characters fall inside its collision. Scaled into world units the same way as the map (÷ 8), **49 of 49** do. An earlier reading, that the positions "do not stand on the village's collision", was measuring against a map whose doorway markers were being read as walls.

**The facing angle is established beyond reasonable doubt.** Across all 1,285 blocks it lies within 0 to 2π, and 71% sit on an exact multiple of 90°.

### A cast list covers the whole area, and the file says which map is which

`M01.npc` holds **49** characters: the village outdoors and everyone inside its houses. Each is placed in the coordinates of the map it stands in. So five copies of `s097a` sit inside a circle 0.8 units across: a room, in that room's own coordinates.

**The word at `+0x08` of a placement block is the map's own id**, the one `maplist9.bin` carries in slot 0 of each entry (see [Map-List](Map-List)). The join is exact: all **1,289** placement blocks on the cartridge name a value that is some entry's id. So `1104` is `M01M04`, which the index calls the Stable, and that is where the five `s097a` and `s001` stand.

Angel Falls runs 1100 for the village and 1101 to 1112 for its interiors, and `S07` runs 5700 to 5707. So within an area, ids read as `area × 100 + sub-map`. That is a habit of the numbering, not a rule: ids elsewhere run to 20001, and 3.4% of placements do not match a code spelled that way. Use the index instead of taking the number apart.

The map id is the same in every 60-byte record of a block, so it belongs to the character rather than to one of their placements.

| check | result |
|---|---|
| areas whose placements all share one `x / 100` | 73 / 73 |
| placements whose word is an id in `maplist9.bin` | **1,289 / 1,289** |
| placements tagged 1100 with floor under them in `M01` | **all of them** |
| placements tagged anything else with floor under them in `M01` | **none** |

## Evidence

| check | result |
|---|---|
| archives holding both files | 74 |
| cast lists read | 73 / 74 (one is zero bytes) |
| placement blocks read | 1,285 |
| **every block's id is an id in the cast list** | **73 / 74** |
| placements joined to a character | 1,283 of 1,285 |
| archives with fewer placements than names | 26 |
| archives with as many placements as names | 45 |
| archives with **more** placements than names | 1 (`R01`, by one) |
| village characters inside its collision, raw | 23 / 49 |
| **characters drawn in more than one map of the village** | **none**, once the map word is read |
| **village characters inside its collision, ÷ 8** | **49 / 49** |
| facing within 0 to 2π | 1,285 / 1,285 |
| slot 2 = 0 with a sprite and no model (village) | 24 / 24 |
| slot 2 = 2 with a model and no sprite (village) | 8 / 8 |
| **EU only:** talk boxes (tag 6) on the cartridge | 570 |

**EU only:** the code is the USA release's ARM9 and overlay 17, from the decomp: the cast loader `func_ov017_021a2c14`; the script runner `func_0206da80`, opcode table `0x020f0994`; tags 3, 4, 5, 6, 7, 14 and 17 at `func_0206c010`, `func_0206c0f8`, `func_0206c2c0`, `func_0206c4e8`, `func_0206c614`, `func_0206cbcc` and `func_0206d4e0`; the chain `func_0206db48`, its removal `func_0206dd68` and its lookup by id `func_0206db20`; a placement's initialiser `func_0206bf2c` (`0x78` bytes, `+0x46` = −1).

## Not established

- Cast slot 2 value `5`, and value `1` beyond "only on records with no name" and, **EU only**, the talk code's "thing to examine".
- **EU only:** tags 7, 8, 11, 14, 15 and 18 to 22 of `place.bin`.
- **EU only:** placement classes 2 and 3: which record sets bit `0x40` of `+0xa` (tag 14's, perhaps), and which sets `+0x46`.
- The 91,652 bytes between blocks that match neither sub-record form, counted under the byte-pattern reading.

## Earlier readings

**`place.bin` was read as "not a tagged table"**: a stream of blocks found by a two-word signature, which passed a tagged-table check only because its string offset happens to equal its length. The game's code runs it as a tagged table, and the signature reading misses 89 blocks and 40 spans.

**Word 6 of a span was not established**, and the span itself was INFERRED. Both are now read from the code.

**"Who stands where" was INFERRED** from which characters the trigger records talk to, at a given map, stage and step. It read only the records for this map, and took "has records, none covering" as "not here". The code shows both wrong. Its rules were: one covering record with a position, there (1,245 character trigger records talk to someone so); one without a position, not here (taken as the header's place instead, Angel Falls would have **27** more at every stage); none covering, not here; none at all, at the header's place (**596** trigger records talk to such a character); a gap inside one sub-stage, at the header's place, on thin evidence (**19** gaps). What the game does with a gap was left unsettled.

**Sorting characters into maps by collision does not work.** Before the map word was found, characters were sorted by which map's floor lay under them. Outdoor characters miss the village's ground by 0.006 to 0.030, and the rest by 0.156 to 0.175, so a threshold in that gap sorts the *village* correctly. It cannot sort the interiors, and nothing in that measurement shows it. Every interior is its own small map about its own origin, so a character standing at (0.1, −0.1) in one room is over the floor of every other room too. The stable drew **fifteen** of the area's characters; it has seven. The village outdoors was right the whole time, which is why this reading survived.

## See also

- [Triggers](Triggers)
- [Character-Dialogue](Character-Dialogue): the talk files, and how a talk picks whom
- [Quests](Quests)
- [Map-List](Map-List)
- [Sprites](Sprites)
- [Event-Scripts](Event-Scripts)
- [Map-Collision](Map-Collision)
- [Doors](Doors)
- [Tagged-Data-Table](Tagged-Data-Table)
