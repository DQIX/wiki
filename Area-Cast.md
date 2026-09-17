# Area-Cast

`<area>.npc` is a NARC beside the map data in `/data/scenario`. It says who stands in an area, where, and in which of its maps. It holds two files: `<map>npc.bin` names the cast, and `<map>place.bin` places them. There are 74 archives, with 1,385 names and 1,285 placements between them. The cast records, the placement block header, the map id and the positions are confirmed. The story-span reading of the sub-records is **INFERRED**. Several words are not established. Counts are from the European release (game code `YDQP`).

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
| `1` | 317 | carried only by records with no name |
| `2` | 132 | a 3D model: `/data/chara_sub/<name>.chr` exists, and no `.spr` does |
| `5` | 35 | not established. The village's one example, `z015d`, has neither |

In the village, every value-0 character has a sprite and no model, and every value-2 character has a model and no sprite: 24 and 8 of the 33.

### The placements — `<map>place.bin`

**This is not a tagged table**, although it passes a tagged-table check: its string offset happens to equal its length. It is a stream of **variable-length** blocks, found by a two-word signature. The gaps between blocks run from 76 to 924 bytes.

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
| `+0x08` | `u32[7]` | a span of the story, INFERRED: words 0, 1 and 2 are its first stage and step, words 3, 4 and 5 its last. Word 6 is not established (see below) |
| `+0x24` | `u32` | the map, by its own id |
| `+0x28` | `u32` | the character's id |
| `+0x2C` | `f32[4]` | x, y, z and facing (60-byte form only) |

| check, across the cartridge | result |
|---|---|
| sub-records | 1,977, in 1,289 blocks |
| map in the block's own area | 1,976 |
| id the block's own | 1,876, so a record names its own character |
| header repeats the first positioned record | 485 of the 636 blocks that have one |
| words 3-4, read as a pair, at or after words 0-1 | **1,977 of 1,977** |
| word 6 | 2 on 1,227, 1 on 378, 0 on 371, one other |
| bytes between blocks that are neither form | 91,652, not read |

## The story span — INFERRED

The seven words read as a **span of the story**. The two pairs never run backwards, which is what a span from one stage to another would look like. Words 2 and 5 are **steps** within the first and last stage: the steps the trigger records move the story to (see [Triggers](Triggers)).

- Within one sub-stage, word 2 is at or before word 5 on **362 of 362**.
- Where a character's next record begins in the sub-stage the last one ends in, it begins one step on (word 2 is one more than the last record's word 5) **121 times of 179**, against 17 for two steps on.
- On the Hexagon's first floor, character `202`'s first record ends at 2.4 step 4. Its next record, 3.47 units along, begins at step 5, the step the switch's event moves the story to (see [Doors](Doors), sliding pieces).

Word 6 is not established.

## Who stands where — INFERRED

These rules are INFERRED from which characters the [trigger](Triggers) records talk to, at a given map, stage and step:

| a character's records in the map, at the stage and step | stands | measure |
|---|---|---|
| one covers it and has a position | there | 1,245 character trigger records talk to someone placed this way |
| one covers it, without a position | not here | if the header's place were used instead, Angel Falls would have **27** more characters at every stage, such as Patty's model in the village at 2.1, and a second Ivor at 2.3 while he follows the Hero |
| none covers it | not here | a "none covers it, so use the header" rule would put Ivor in the village at 2.1 |
| none at all | at the header's place, at every stage | **596** trigger records talk to such a character in the header's map. In Angel Falls this adds one thing to examine; in the Hexagon, its switch, `201` |
| a gap between two of them inside one sub-stage | at the header's place | thin evidence: only **19** such gaps on the cartridge. See below |

The one gap examined: the Hexagon's figure, `204`, has a gap over steps 2 and 3 of 2.4, when it is talked to. `ev02500`, which opens step 2, stands the figure on the header's spot to within 0.01. `ev02510` then walks it to (−11.74, 11.23). Event script function `566(5, 204, 1)` says which of the cast is the event's character 1 (see [Event-Scripts](Event-Scripts)), and the figure walks to the statue room, as a let's play video shows. It then waits there over step 3, despite the gap's header place. What the game does with a gap is not settled.

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

## Not established

- Cast slot 2 value `5`, and value `1` beyond "only on records with no name".
- Placement sub-record word 6.
- The story-span reading of words 0 to 5 (INFERRED).
- What the game does with a gap between two sub-records inside one sub-stage.
- The 91,652 bytes between blocks that match neither sub-record form.
- The rules in "Who stands where" (INFERRED).

## Earlier readings

**Sorting characters into maps by collision does not work.** Before the map word was found, characters were sorted by which map's floor lay under them. Outdoor characters miss the village's ground by 0.006 to 0.030, and the rest by 0.156 to 0.175, so a threshold in that gap sorts the *village* correctly. It cannot sort the interiors, and nothing in that measurement shows it. Every interior is its own small map about its own origin, so a character standing at (0.1, −0.1) in one room is over the floor of every other room too. The stable drew **fifteen** of the area's characters; it has seven. The village outdoors was right the whole time, which is why this reading survived.

## See also

- [Triggers](Triggers)
- [Map-List](Map-List)
- [Sprites](Sprites)
- [Event-Scripts](Event-Scripts)
- [Character-Dialogue](Character-Dialogue)
- [Map-Collision](Map-Collision)
- [Doors](Doors)
